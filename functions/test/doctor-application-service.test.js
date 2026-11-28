const assert = require('node:assert/strict');
const test = require('node:test');

const { DoctorAdminError } = require('../src/doctor-admin/errors');
const {
  createDoctorApplicationService,
} = require('../src/doctor-application/service');
const { createFakeFirestore } = require('./helpers/fake-firestore');

const applicationPayload = {
  fullName: 'Patient One',
  phoneNumber: '+1 555 0100',
  specialtyId: 'cardiology',
  qualification: 'MD',
  experienceYears: 8,
  bio: 'A professional biography.',
  consultationFee: 80,
  clinicAddress: 'Main Street clinic',
};

function fixture(initial = {}) {
  const db = createFakeFirestore({
    'users/patient-1': {
      uid: 'patient-1',
      role: 'patient',
      fullName: 'Patient One',
      email: 'PATIENT@example.com',
      phoneNumber: '100',
      profileImageUrl: '',
    },
    'users/admin-1': { uid: 'admin-1', role: 'admin' },
    'specialties/cardiology': { name: 'Cardiology', isActive: true },
    ...initial,
  });
  const service = createDoctorApplicationService({
    db,
    serverTimestamp: () => ({ serverTimestamp: true }),
  });
  return { db, service };
}

test('submission uses the authenticated UID and creates a pending application', async () => {
  const { db, service } = fixture();
  const result = await service.submit({
    actorUid: 'patient-1',
    payload: applicationPayload,
  });

  assert.deepEqual(result, {
    applicationId: 'patient-1_1',
    applicationStatus: 'pending',
  });
  assert.equal(db.read('doctor_applications/patient-1_1').applicantUid, 'patient-1');
  assert.equal(db.read('doctor_applications/patient-1_1').applicantEmail, 'patient@example.com');
  assert.equal(db.read('doctor_applications/patient-1_1').applicationStatus, 'pending');
  assert.equal(db.read('users/patient-1').role, 'patient');
});

test('prevents a second pending application', async () => {
  const { service } = fixture();
  await service.submit({ actorUid: 'patient-1', payload: applicationPayload });

  await assert.rejects(
    service.submit({ actorUid: 'patient-1', payload: applicationPayload }),
    (error) => error instanceof DoctorAdminError && error.code === 'already-exists',
  );
});

test('rejection preserves history and permits a new application revision', async () => {
  const { db, service } = fixture();
  await service.submit({ actorUid: 'patient-1', payload: applicationPayload });
  await service.review({
    actorUid: 'admin-1',
    action: 'reject',
    payload: {
      applicationId: 'patient-1_1',
      operationId: 'reject-1',
      reason: 'Please provide more experience details.',
    },
  });

  const resubmission = await service.submit({
    actorUid: 'patient-1',
    payload: applicationPayload,
  });

  assert.equal(resubmission.applicationId, 'patient-1_2');
  assert.equal(db.read('doctor_applications/patient-1_1').applicationStatus, 'rejected');
  assert.equal(db.read('doctor_applications/patient-1_2').applicationStatus, 'pending');
});

test('approval atomically provisions linked doctor and updates application', async () => {
  const { db, service } = fixture();
  await service.submit({ actorUid: 'patient-1', payload: applicationPayload });

  const result = await service.review({
    actorUid: 'admin-1',
    action: 'approve',
    payload: {
      applicationId: 'patient-1_1',
      operationId: 'approve-1',
    },
  });

  assert.equal(result.applicationStatus, 'approved');
  assert.equal(result.doctorProfileId, 'doctor_patient-1_1');
  assert.equal(db.read('users/patient-1').role, 'doctor');
  assert.equal(db.read('users/patient-1').doctorProfileId, 'doctor_patient-1_1');
  assert.equal(db.read('doctors/doctor_patient-1_1').approvalStatus, 'approved');
  assert.equal(db.read('doctors/doctor_patient-1_1').administrativeStatus, 'active');
  assert.equal(db.read('doctor_applications/patient-1_1').applicationStatus, 'approved');
  assert.equal(db.read('doctor_application_audit/approve-1').actorUid, 'admin-1');
});

test('review operations are idempotent and only pending applications can be reviewed', async () => {
  const { db, service } = fixture();
  await service.submit({ actorUid: 'patient-1', payload: applicationPayload });
  const payload = {
    applicationId: 'patient-1_1',
    operationId: 'approve-once',
  };
  const first = await service.review({
    actorUid: 'admin-1',
    action: 'approve',
    payload,
  });
  const replay = await service.review({
    actorUid: 'admin-1',
    action: 'approve',
    payload,
  });

  assert.deepEqual(replay, first);
  await assert.rejects(
    service.review({
      actorUid: 'admin-1',
      action: 'approve',
      payload: { ...payload, operationId: 'approve-again' },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'failed-precondition',
  );
  assert.equal(
    db.paths().filter((path) => path.startsWith('doctor_application_audit/')).length,
    1,
  );
});

test('rejects invalid roles, fields, specialties, and existing doctor identities', async () => {
  const { service } = fixture({
    'users/other-1': {
      uid: 'other-1',
      role: 'doctor',
      fullName: 'Doctor',
      email: 'doctor@example.com',
      phoneNumber: '200',
    },
  });
  for (const [actorUid, payload] of [
    ['patient-1', { ...applicationPayload, applicantUid: 'other-1' }],
    ['patient-1', { ...applicationPayload, experienceYears: -1 }],
    ['patient-1', { ...applicationPayload, specialtyId: 'missing' }],
    ['other-1', applicationPayload],
  ]) {
    await assert.rejects(
      service.submit({ actorUid, payload }),
      (error) => error instanceof DoctorAdminError,
    );
  }
});

test('allows legacy specialties without status but rejects explicit inactive or malformed status', async () => {
  const { service } = fixture({
    'specialties/legacy': { name: 'Legacy specialty' },
    'specialties/inactive': { name: 'Inactive specialty', isActive: false },
    'specialties/malformed': { name: 'Malformed specialty', isActive: 'active' },
  });
  const legacy = await service.submit({
    actorUid: 'patient-1',
    payload: { ...applicationPayload, specialtyId: 'legacy' },
  });
  assert.equal(legacy.applicationStatus, 'pending');

  for (const specialtyId of ['inactive', 'malformed']) {
    await assert.rejects(
      service.submit({
        actorUid: 'patient-1',
        payload: { ...applicationPayload, specialtyId },
      }),
      (error) => error instanceof DoctorAdminError &&
        error.code === 'invalid-argument',
    );
  }
});

test('requires a Firestore admin for review and a reason for rejection', async () => {
  const { service } = fixture();
  await service.submit({ actorUid: 'patient-1', payload: applicationPayload });

  await assert.rejects(
    service.review({
      actorUid: 'patient-1',
      action: 'approve',
      payload: { applicationId: 'patient-1_1', operationId: 'forged' },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'permission-denied',
  );
  await assert.rejects(
    service.review({
      actorUid: 'admin-1',
      action: 'reject',
      payload: { applicationId: 'patient-1_1', operationId: 'missing-reason' },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'invalid-argument',
  );
});
