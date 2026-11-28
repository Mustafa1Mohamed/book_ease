const assert = require('node:assert/strict');
const test = require('node:test');

const {
  createDoctorApplicationCallable,
} = require('../src/doctor-application/callable');
const { DoctorAdminError } = require('../src/doctor-admin/errors');

class FakeHttpsError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

test('requires auth and passes only the verified caller UID to submit', async () => {
  let invocation;
  const handler = createDoctorApplicationCallable({
    service: {
      submit: async (request) => {
        invocation = request;
        return { applicationStatus: 'pending' };
      },
    },
    operation: 'submit',
    HttpsError: FakeHttpsError,
  });

  await assert.rejects(
    handler({ data: {} }),
    (error) => error instanceof FakeHttpsError && error.code === 'unauthenticated',
  );
  await handler({
    auth: { uid: 'verified-patient' },
    data: { applicantUid: 'forged-patient' },
  });
  assert.equal(invocation.actorUid, 'verified-patient');
  assert.equal(invocation.payload.applicantUid, 'forged-patient');
});

test('maps expected application service errors and masks unexpected details', async () => {
  const handler = createDoctorApplicationCallable({
    service: {
      review: async () => {
        throw new DoctorAdminError('permission-denied', 'Not allowed.');
      },
    },
    operation: 'review',
    action: 'approve',
    HttpsError: FakeHttpsError,
  });
  await assert.rejects(
    handler({ auth: { uid: 'admin-1' }, data: {} }),
    (error) => error instanceof FakeHttpsError && error.code === 'permission-denied',
  );

  const unexpected = createDoctorApplicationCallable({
    service: { submit: async () => { throw new Error('private data'); } },
    operation: 'submit',
    HttpsError: FakeHttpsError,
    logger: { error() {} },
  });
  await assert.rejects(
    unexpected({ auth: { uid: 'patient-1' }, data: {} }),
    (error) =>
      error instanceof FakeHttpsError &&
      error.code === 'internal' &&
      !error.message.includes('private data'),
  );
});
