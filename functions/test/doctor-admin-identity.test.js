const assert = require('node:assert/strict');
const test = require('node:test');

const { DoctorAdminError } = require('../src/doctor-admin/errors');
const {
  requireAdminActor,
  resolveDoctorProfile,
} = require('../src/doctor-admin/identity');
const { createFakeFirestore } = require('./helpers/fake-firestore');

async function resolve(db, uid, userData) {
  return db.runTransaction((transaction) =>
    resolveDoctorProfile(transaction, db, uid, userData),
  );
}

test('requires the actor user document to have the Firestore admin role', async () => {
  const db = createFakeFirestore({
    'users/admin-1': { role: 'admin' },
    'users/patient-1': { role: 'patient' },
  });
  await db.runTransaction(async (transaction) => {
    await requireAdminActor(transaction, db, 'admin-1');
  });
  await assert.rejects(
    db.runTransaction((transaction) =>
      requireAdminActor(transaction, db, 'patient-1'),
    ),
    (error) => error instanceof DoctorAdminError && error.code === 'permission-denied',
  );
});

test('resolves a valid explicit doctorProfileId and checks for duplicates', async () => {
  const db = createFakeFirestore({
    'users/doctor-1': { role: 'doctor', doctorProfileId: 'profile-1' },
    'doctors/profile-1': { uid: 'doctor-1' },
  });
  const result = await resolve(db, 'doctor-1', db.read('users/doctor-1'));
  assert.equal(result.doctorRef.id, 'profile-1');
  assert.deepEqual(result.doctorData, { uid: 'doctor-1' });
});

test('rejects explicit links that are missing, malformed, or mismatched', async () => {
  const db = createFakeFirestore({
    'doctors/profile-1': { uid: 'another-user' },
  });
  for (const userData of [
    { role: 'doctor', doctorProfileId: 'missing' },
    { role: 'doctor', doctorProfileId: 'profile-1' },
    { role: 'doctor', doctorProfileId: ' ' },
    { role: 'doctor', doctorProfileId: 'invalid/profile' },
    { role: 'patient', doctorProfileId: 'profile-1' },
  ]) {
    await assert.rejects(
      resolve(db, 'doctor-1', userData),
      DoctorAdminError,
    );
  }
});

test('resolves a single uid-linked profile without an explicit user link', async () => {
  const db = createFakeFirestore({
    'doctors/profile-1': { uid: 'doctor-1' },
  });
  const result = await resolve(db, 'doctor-1', { role: 'doctor' });
  assert.equal(result.doctorRef.id, 'profile-1');
});

test('supports the legacy document-id fallback only when unambiguous', async () => {
  const db = createFakeFirestore({
    'doctors/doctor-1': { fullName: 'Legacy doctor' },
  });
  const result = await resolve(db, 'doctor-1', { role: 'doctor' });
  assert.equal(result.doctorRef.id, 'doctor-1');
  assert.equal(result.doctorData.fullName, 'Legacy doctor');

  const nullUidLegacy = createFakeFirestore({
    'doctors/doctor-2': { uid: null },
  });
  const nullUidResult = await resolve(
    nullUidLegacy,
    'doctor-2',
    { role: 'doctor' },
  );
  assert.equal(nullUidResult.doctorRef.id, 'doctor-2');

  const missing = createFakeFirestore();
  await assert.rejects(
    resolve(missing, 'doctor-1', { role: 'doctor' }),
    (error) => error instanceof DoctorAdminError && error.code === 'not-found',
  );
});

test('rejects duplicate and conflicting doctor profiles', async () => {
  const duplicate = createFakeFirestore({
    'doctors/profile-1': { uid: 'doctor-1' },
    'doctors/profile-2': { uid: 'doctor-1' },
  });
  await assert.rejects(
    resolve(duplicate, 'doctor-1', { role: 'doctor' }),
    (error) => error instanceof DoctorAdminError && error.code === 'failed-precondition',
  );

  const conflict = createFakeFirestore({
    'doctors/profile-1': { uid: 'doctor-1' },
    'doctors/doctor-1': { fullName: 'Conflicting legacy record' },
  });
  await assert.rejects(
    resolve(conflict, 'doctor-1', { role: 'doctor' }),
    (error) => error instanceof DoctorAdminError && error.code === 'failed-precondition',
  );
});
