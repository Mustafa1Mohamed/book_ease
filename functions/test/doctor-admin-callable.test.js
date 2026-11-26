const assert = require('node:assert/strict');
const test = require('node:test');

const { createDoctorAdminCallable } = require('../src/doctor-admin/callable');
const { DoctorAdminError } = require('../src/doctor-admin/errors');

class FakeHttpsError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}

test('rejects unauthenticated callable requests before invoking the service', async () => {
  let called = false;
  const handler = createDoctorAdminCallable({
    service: { execute: async () => { called = true; } },
    action: 'approve',
    HttpsError: FakeHttpsError,
  });
  await assert.rejects(
    handler({ data: {} }),
    (error) => error instanceof FakeHttpsError && error.code === 'unauthenticated',
  );
  assert.equal(called, false);
});

test('uses only the verified context UID and maps service authorization errors', async () => {
  let invocation;
  const handler = createDoctorAdminCallable({
    service: {
      execute: async (request) => {
        invocation = request;
        throw new DoctorAdminError(
          'permission-denied',
          'This action is not permitted.',
        );
      },
    },
    action: 'approve',
    HttpsError: FakeHttpsError,
  });
  await assert.rejects(
    handler({
      auth: { uid: 'verified-admin' },
      data: { actorUid: 'forged-user', targetDoctorUid: 'doctor-1' },
    }),
    (error) => error instanceof FakeHttpsError && error.code === 'permission-denied',
  );
  assert.equal(invocation.actorUid, 'verified-admin');
  assert.equal(invocation.payload.actorUid, 'forged-user');
});

test('converts unexpected failures to a stable internal error', async () => {
  const logged = [];
  const handler = createDoctorAdminCallable({
    service: { execute: async () => { throw new Error('private details'); } },
    action: 'suspend',
    HttpsError: FakeHttpsError,
    logger: { error: (...args) => logged.push(args) },
  });
  await assert.rejects(
    handler({ auth: { uid: 'admin-1' }, data: {} }),
    (error) =>
      error instanceof FakeHttpsError &&
      error.code === 'internal' &&
      error.message === 'The doctor action could not be completed.',
  );
  assert.equal(logged.length, 1);
  assert.equal(JSON.stringify(logged).includes('private details'), false);
});
