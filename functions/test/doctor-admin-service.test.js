const assert = require('node:assert/strict');
const test = require('node:test');

const { DoctorAdminError } = require('../src/doctor-admin/errors');
const {
  createDoctorAdminService,
} = require('../src/doctor-admin/doctor-admin-service');
const { createFakeFirestore } = require('./helpers/fake-firestore');

function createFixture(doctorData = {
  uid: 'doctor-1',
  approvalStatus: 'pending',
}) {
  const db = createFakeFirestore({
    'users/admin-1': { role: 'admin' },
    'users/patient-1': { role: 'patient' },
    'users/doctor-user': { role: 'doctor' },
    'users/doctor-1': { role: 'doctor', doctorProfileId: 'profile-1' },
    'doctors/profile-1': doctorData,
    'appointments/appointment-1': { status: 'confirmed' },
    'doctors/profile-1/availabilitySlots/slot-1': { isAvailable: false },
  });
  const service = createDoctorAdminService({
    db,
    serverTimestamp: () => ({ serverTimestamp: true }),
  });
  return { db, service };
}

test('authorizes only the Firestore admin role and ignores claimed role input', async () => {
  const { service } = createFixture();
  for (const actorUid of ['patient-1', 'doctor-user']) {
    await assert.rejects(
      service.execute({
        actorUid,
        action: 'approve',
        payload: { targetDoctorUid: 'doctor-1', operationId: `op-${actorUid}` },
      }),
      (error) =>
        error instanceof DoctorAdminError &&
        error.code === 'permission-denied',
    );
  }
  await assert.rejects(
    service.execute({
      actorUid: 'admin-1',
      action: 'approve',
      payload: {
        actorUid: 'patient-1',
        targetDoctorUid: 'doctor-1',
        operationId: 'op-2',
      },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'invalid-argument',
  );
});

test('validates payloads and requires bounded reasons for rejection and suspension', async () => {
  const { service } = createFixture({
    uid: 'doctor-1',
    approvalStatus: 'pending',
  });
  for (const [action, payload] of [
    ['approve', null],
    ['approve', { targetDoctorUid: 'doctor-1', operationId: 'bad/id' }],
    ['approve', { targetDoctorUid: 'doctor/1', operationId: 'bad-target' }],
    ['approve', { targetDoctorUid: 'doctor-1', operationId: 'ok', extra: true }],
    ['reject', { targetDoctorUid: 'doctor-1', operationId: 'reject-1' }],
    ['suspend', {
      targetDoctorUid: 'doctor-1',
      operationId: 'suspend-1',
      reason: '  ',
    }],
  ]) {
    await assert.rejects(
      service.execute({ actorUid: 'admin-1', action, payload }),
      (error) => error instanceof DoctorAdminError && error.code === 'invalid-argument',
    );
  }

  await assert.rejects(
    service.execute({
      actorUid: 'admin-1',
      action: 'reject',
      payload: {
        targetDoctorUid: 'doctor-1',
        operationId: 'reject-long',
        reason: 'x'.repeat(501),
      },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'invalid-argument',
  );
});

test('commits status and audit atomically using server-derived identity and state', async () => {
  const { db, service } = createFixture();
  const result = await service.execute({
    actorUid: 'admin-1',
    action: 'approve',
    payload: { targetDoctorUid: 'doctor-1', operationId: 'approve-1' },
  });

  assert.deepEqual(result, {
    operationId: 'approve-1',
    action: 'approve',
    targetDoctorUid: 'doctor-1',
    doctorProfileId: 'profile-1',
    approvalStatus: 'approved',
    administrativeStatus: 'active',
  });
  assert.deepEqual(db.read('doctors/profile-1'), {
    uid: 'doctor-1',
    approvalStatus: 'approved',
    administrativeStatus: 'active',
  });
  assert.deepEqual(db.read('doctor_admin_audit/approve-1'), {
    actorUid: 'admin-1',
    action: 'approve',
    targetDoctorUid: 'doctor-1',
    doctorProfileId: 'profile-1',
    previousApprovalStatus: 'pending',
    newApprovalStatus: 'approved',
    previousAdministrativeStatus: 'active',
    newAdministrativeStatus: 'active',
    operationId: 'approve-1',
    schemaVersion: 1,
    createdAt: { serverTimestamp: true },
  });
  assert.deepEqual(db.read('appointments/appointment-1'), { status: 'confirmed' });
  assert.deepEqual(
    db.read('doctors/profile-1/availabilitySlots/slot-1'),
    { isAvailable: false },
  );
});

test('replays identical operation IDs without a second event and rejects mismatches', async () => {
  const { db, service } = createFixture();
  const payload = {
    targetDoctorUid: 'doctor-1',
    operationId: 'approve-replay',
  };
  const first = await service.execute({
    actorUid: 'admin-1',
    action: 'approve',
    payload,
  });
  const replay = await service.execute({
    actorUid: 'admin-1',
    action: 'approve',
    payload,
  });
  assert.deepEqual(replay, first);
  assert.equal(
    db.paths().filter((path) => path.startsWith('doctor_admin_audit/')).length,
    1,
  );

  await assert.rejects(
    service.execute({
      actorUid: 'admin-1',
      action: 'reject',
      payload: { ...payload, reason: 'Different action' },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'already-exists',
  );
});

test('rejects no-op requests without writing duplicate audit events', async () => {
  const { db, service } = createFixture({
    uid: 'doctor-1',
    approvalStatus: 'approved',
    administrativeStatus: 'active',
  });
  await assert.rejects(
    service.execute({
      actorUid: 'admin-1',
      action: 'approve',
      payload: { targetDoctorUid: 'doctor-1', operationId: 'already-approved' },
    }),
    (error) => error instanceof DoctorAdminError && error.code === 'failed-precondition',
  );
  assert.equal(db.read('doctor_admin_audit/already-approved'), undefined);
});

test('serializes conflicting concurrent actions so only one transition succeeds', async () => {
  const { db, service } = createFixture();
  const results = await Promise.allSettled([
    service.execute({
      actorUid: 'admin-1',
      action: 'approve',
      payload: { targetDoctorUid: 'doctor-1', operationId: 'concurrent-approve' },
    }),
    service.execute({
      actorUid: 'admin-1',
      action: 'reject',
      payload: {
        targetDoctorUid: 'doctor-1',
        operationId: 'concurrent-reject',
        reason: 'Not eligible',
      },
    }),
  ]);
  assert.equal(results.filter((result) => result.status === 'fulfilled').length, 1);
  assert.equal(results.filter((result) => result.status === 'rejected').length, 1);
  assert.equal(
    db.paths().filter((path) => path.startsWith('doctor_admin_audit/')).length,
    1,
  );
});

test('rolls back status changes when audit creation fails', async () => {
  const { db, service } = createFixture();
  const originalRunTransaction = db.runTransaction;
  db.runTransaction = (callback) =>
    originalRunTransaction(async (transaction) => {
      const originalCreate = transaction.create;
      transaction.create = () => {
        throw new Error('audit write failed');
      };
      try {
        return await callback(transaction);
      } finally {
        transaction.create = originalCreate;
      }
    });

  await assert.rejects(
    service.execute({
      actorUid: 'admin-1',
      action: 'approve',
      payload: { targetDoctorUid: 'doctor-1', operationId: 'audit-fails' },
    }),
    /audit write failed/,
  );
  assert.deepEqual(db.read('doctors/profile-1'), {
    uid: 'doctor-1',
    approvalStatus: 'pending',
  });
  assert.equal(db.read('doctor_admin_audit/audit-fails'), undefined);
});

test('writes rejection and suspension reasons, and restoration preserves rejection state', async () => {
  const rejectedFixture = createFixture();
  await rejectedFixture.service.execute({
    actorUid: 'admin-1',
    action: 'reject',
    payload: {
      targetDoctorUid: 'doctor-1',
      operationId: 'reject-reason',
      reason: 'Incomplete credentials',
    },
  });
  assert.equal(
    rejectedFixture.db.read('doctor_admin_audit/reject-reason').reason,
    'Incomplete credentials',
  );

  const suspendedFixture = createFixture({
    uid: 'doctor-1',
    approvalStatus: 'approved',
    administrativeStatus: 'active',
  });
  await suspendedFixture.service.execute({
    actorUid: 'admin-1',
    action: 'suspend',
    payload: {
      targetDoctorUid: 'doctor-1',
      operationId: 'suspend-reason',
      reason: 'Policy review',
    },
  });
  await suspendedFixture.service.execute({
    actorUid: 'admin-1',
    action: 'restore',
    payload: { targetDoctorUid: 'doctor-1', operationId: 'restore-1' },
  });
  assert.deepEqual(suspendedFixture.db.read('doctors/profile-1'), {
    uid: 'doctor-1',
    approvalStatus: 'approved',
    administrativeStatus: 'active',
  });
  assert.equal(
    suspendedFixture.db.read('doctor_admin_audit/suspend-reason').reason,
    'Policy review',
  );
});
