const { DoctorAdminError } = require('./errors');

function createDoctorAdminCallable({ service, action, HttpsError, logger }) {
  return async (request) => {
    const actorUid = request?.auth?.uid;
    if (typeof actorUid !== 'string' || actorUid.length === 0) {
      throw new HttpsError('unauthenticated', 'Authentication is required.');
    }

    try {
      return await service.execute({
        actorUid,
        action,
        payload: request.data,
      });
    } catch (error) {
      if (error instanceof DoctorAdminError) {
        throw new HttpsError(error.code, error.message);
      }

      logger?.error('Doctor administration action failed.', {
        action,
        errorCode: error?.code ?? 'unknown',
      });
      throw new HttpsError(
        'internal',
        'The doctor action could not be completed.',
      );
    }
  };
}

module.exports = { createDoctorAdminCallable };
