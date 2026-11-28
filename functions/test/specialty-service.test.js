const assert = require('node:assert/strict');
const test = require('node:test');

const { DoctorAdminError } = require('../src/doctor-admin/errors');
const { createSpecialtyService } = require('../src/specialties/service');
const { createFakeFirestore } = require('./helpers/fake-firestore');

const specialtyPayload = {
  name: 'Cardiology',
  nameAr: 'أمراض القلب',
  description: 'Heart care',
  descriptionAr: 'رعاية القلب',
  iconName: 'heart',
  isActive: true,
  clearImage: false,
};

function fixture(initial = {}) {
  const db = createFakeFirestore({
    'users/admin-1': { uid: 'admin-1', role: 'admin' },
    'users/patient-1': { uid: 'patient-1', role: 'patient' },
    ...initial,
  });
  const service = createSpecialtyService({
    db,
    serverTimestamp: () => ({ serverTimestamp: true }),
  });
  return { db, service };
}

test('creates a specialty with normalized fields and server timestamps', async () => {
  const { db, service } = fixture();
  const result = await service.save({
    actorUid: 'admin-1',
    payload: specialtyPayload,
  });

  const created = db.read(`specialties/${result.specialtyId}`);
  assert.equal(created.name, 'Cardiology');
  assert.equal(created.nameAr, 'أمراض القلب');
  assert.equal(created.isActive, true);
  assert.equal(created.imageUrl, '');
  assert.deepEqual(created.createdAt, { serverTimestamp: true });
  assert.deepEqual(created.updatedAt, { serverTimestamp: true });
});

test('edits in place, preserves existing images, and can clear an old image', async () => {
  const { db, service } = fixture({
    'specialties/heart': {
      name: 'Heart',
      nameAr: 'القلب',
      imageUrl: 'https://images.example.test/heart.png',
      isActive: true,
    },
  });
  const result = await service.save({
    actorUid: 'admin-1',
    payload: {
      ...specialtyPayload,
      specialtyId: 'heart',
      name: 'Cardiology',
    },
  });
  assert.equal(result.specialtyId, 'heart');
  assert.equal(
    db.read('specialties/heart').imageUrl,
    'https://images.example.test/heart.png',
  );

  await service.save({
    actorUid: 'admin-1',
    payload: {
      ...specialtyPayload,
      specialtyId: 'heart',
      clearImage: true,
    },
  });
  assert.equal(db.read('specialties/heart').imageUrl, '');
  assert.equal(db.paths().filter((path) => path.startsWith('specialties/')).length, 1);
});

test('prevents case-, whitespace-, and cross-language duplicate names', async () => {
  const { service } = fixture({
    'specialties/heart': {
      name: 'Cardiology',
      nameAr: 'أمراض القلب',
      isActive: false,
    },
  });
  await assert.rejects(
    service.save({
      actorUid: 'admin-1',
      payload: { ...specialtyPayload, name: '  CARDIOLOGY  ' },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'already-exists',
  );
  await assert.rejects(
    service.save({
      actorUid: 'admin-1',
      payload: { ...specialtyPayload, name: 'New Name', nameAr: 'cardiology' },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'already-exists',
  );
});

test('requires a Firestore admin and validates all management fields', async () => {
  const { service } = fixture();
  await assert.rejects(
    service.save({ actorUid: 'patient-1', payload: specialtyPayload }),
    (error) => error instanceof DoctorAdminError && error.code === 'permission-denied',
  );
  for (const payload of [
    { ...specialtyPayload, nameAr: '' },
    { ...specialtyPayload, name: 'x'.repeat(101) },
    { ...specialtyPayload, iconName: 'untrusted-icon' },
    { ...specialtyPayload, isActive: 'true' },
    { ...specialtyPayload, unexpected: 'field' },
  ]) {
    await assert.rejects(
      service.save({ actorUid: 'admin-1', payload }),
      (error) => error instanceof DoctorAdminError &&
        error.code === 'invalid-argument',
    );
  }
});

test('activation is an admin-only soft update that preserves other records', async () => {
  const doctor = {
    specialtyId: 'heart',
    administrativeStatus: 'active',
  };
  const { db, service } = fixture({
    'specialties/heart': {
      name: 'Cardiology',
      nameAr: 'أمراض القلب',
      isActive: true,
    },
    'doctors/doctor-1': doctor,
  });
  const result = await service.setActive({
    actorUid: 'admin-1',
    payload: { specialtyId: 'heart', isActive: false },
  });

  assert.deepEqual(result, { specialtyId: 'heart', isActive: false });
  assert.equal(db.read('specialties/heart').isActive, false);
  assert.deepEqual(db.read('doctors/doctor-1'), doctor);
  await assert.rejects(
    service.setActive({
      actorUid: 'patient-1',
      payload: { specialtyId: 'heart', isActive: true },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'permission-denied',
  );
});
