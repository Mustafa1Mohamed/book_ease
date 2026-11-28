const assert = require('node:assert/strict');
const test = require('node:test');

const { DoctorAdminError } = require('../src/doctor-admin/errors');
const { createSpecialtyCallable } = require('../src/specialties/callable');

class FakeHttpsError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

test('requires authentication and passes the verified UID to specialty service', async () => {
  let invocation;
  const handler = createSpecialtyCallable({
    service: {
      save: async (request) => {
        invocation = request;
        return { specialtyId: 'created-id' };
      },
    },
    operation: 'save',
    HttpsError: FakeHttpsError,
  });

  await assert.rejects(
    handler({ data: {} }),
    (error) => error instanceof FakeHttpsError && error.code === 'unauthenticated',
  );
  await handler({
    auth: { uid: 'verified-admin' },
    data: { actorUid: 'forged-user' },
  });
  assert.equal(invocation.actorUid, 'verified-admin');
  assert.equal(invocation.payload.actorUid, 'forged-user');
});

test('maps expected errors and masks unexpected specialty failures', async () => {
  const expected = createSpecialtyCallable({
    service: {
      setActive: async () => {
        throw new DoctorAdminError('permission-denied', 'Not allowed.');
      },
    },
    operation: 'setActive',
    HttpsError: FakeHttpsError,
  });
  await assert.rejects(
    expected({ auth: { uid: 'patient-1' }, data: {} }),
    (error) => error instanceof FakeHttpsError && error.code === 'permission-denied',
  );

  const unexpected = createSpecialtyCallable({
    service: { save: async () => { throw new Error('private data'); } },
    operation: 'save',
    HttpsError: FakeHttpsError,
    logger: { error() {} },
  });
  await assert.rejects(
    unexpected({ auth: { uid: 'admin-1' }, data: {} }),
    (error) => error instanceof FakeHttpsError &&
      error.code === 'internal' &&
      !error.message.includes('private data'),
  );
});
