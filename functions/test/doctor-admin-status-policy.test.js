const assert = require('node:assert/strict');
const test = require('node:test');

const { DoctorAdminError } = require('../src/doctor-admin/errors');
const {
  readApprovalStatus,
  readAdministrativeStatus,
  readDoctorStatus,
  transitionDoctorStatus,
} = require('../src/doctor-admin/status-policy');

function expectCode(code, operation) {
  assert.throws(operation, (error) => {
    assert.ok(error instanceof DoctorAdminError);
    assert.equal(error.code, code);
    return true;
  });
}

test('applies the approved defaults only when the status fields are missing', () => {
  assert.equal(readApprovalStatus({}), 'pending');
  assert.equal(readAdministrativeStatus({}), 'active');
  assert.deepEqual(readDoctorStatus({}), {
    approvalStatus: 'pending',
    administrativeStatus: 'active',
  });
});

test('rejects explicit null, blank, malformed, and unknown status values', () => {
  expectCode('failed-precondition', () => readApprovalStatus(null));
  expectCode('failed-precondition', () => readAdministrativeStatus(null));
  for (const value of [null, '', ' ', 'APPROVED', 'other', 7]) {
    expectCode('failed-precondition', () =>
      readApprovalStatus({ approvalStatus: value }),
    );
    expectCode('failed-precondition', () =>
      readAdministrativeStatus({ administrativeStatus: value }),
    );
  }
});

test('accepts only structurally valid status combinations', () => {
  for (const status of [
    { approvalStatus: 'pending', administrativeStatus: 'active' },
    { approvalStatus: 'approved', administrativeStatus: 'active' },
    { approvalStatus: 'rejected', administrativeStatus: 'active' },
    { approvalStatus: 'approved', administrativeStatus: 'suspended' },
  ]) {
    assert.deepEqual(readDoctorStatus(status), status);
  }
  for (const status of [
    { approvalStatus: 'pending', administrativeStatus: 'suspended' },
    { approvalStatus: 'rejected', administrativeStatus: 'suspended' },
  ]) {
    expectCode('failed-precondition', () => readDoctorStatus(status));
  }
});

test('allows every approved transition without changing unrelated status', () => {
  assert.deepEqual(
    transitionDoctorStatus('approve', {
      approvalStatus: 'pending',
      administrativeStatus: 'active',
    }),
    { approvalStatus: 'approved', administrativeStatus: 'active' },
  );
  assert.deepEqual(
    transitionDoctorStatus('reject', {
      approvalStatus: 'pending',
      administrativeStatus: 'active',
    }),
    { approvalStatus: 'rejected', administrativeStatus: 'active' },
  );
  assert.deepEqual(
    transitionDoctorStatus('suspend', {
      approvalStatus: 'approved',
      administrativeStatus: 'active',
    }),
    { approvalStatus: 'approved', administrativeStatus: 'suspended' },
  );
  assert.deepEqual(
    transitionDoctorStatus('restore', {
      approvalStatus: 'approved',
      administrativeStatus: 'suspended',
    }),
    { approvalStatus: 'approved', administrativeStatus: 'active' },
  );
});

test('rejects forbidden transitions and no-op requests', () => {
  const cases = [
    {
      status: { approvalStatus: 'pending', administrativeStatus: 'active' },
      allowed: ['approve', 'reject'],
    },
    {
      status: { approvalStatus: 'approved', administrativeStatus: 'active' },
      allowed: ['suspend'],
    },
    {
      status: { approvalStatus: 'rejected', administrativeStatus: 'active' },
      allowed: [],
    },
    {
      status: { approvalStatus: 'approved', administrativeStatus: 'suspended' },
      allowed: ['restore'],
    },
  ];
  for (const { status, allowed } of cases) {
    for (const action of ['approve', 'reject', 'suspend', 'restore']) {
      if (allowed.includes(action)) {
        assert.doesNotThrow(() => transitionDoctorStatus(action, status));
      } else {
        expectCode('failed-precondition', () =>
          transitionDoctorStatus(action, status),
        );
      }
    }
  }
  expectCode('failed-precondition', () =>
    transitionDoctorStatus('approve', {
      approvalStatus: 'approved',
      administrativeStatus: 'active',
    }),
  );
  expectCode('invalid-argument', () =>
    transitionDoctorStatus('delete', {
      approvalStatus: 'pending',
      administrativeStatus: 'active',
    }),
  );
});
