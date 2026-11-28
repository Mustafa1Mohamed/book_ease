const { DoctorAdminError } = require('../doctor-admin/errors');

function createDoctorApplicationCallable({
  service,
  operation,
  action,
  HttpsError,
  logger,
}) {
  return async (request) => {
    const actorUid = request?.auth?.uid;
    if (typeof actorUid !== 'string' || actorUid.length === 0) {
      throw new HttpsError('unauthenticated', 'Authentication is required.');
    }

    try {
      if (operation === 'submit') {
        return await service.submit({ actorUid, payload: request.data });
      }
      return await service.review({
        actorUid,
        action,
        payload: request.data,
      });
    } catch (error) {
      if (error instanceof DoctorAdminError) {
        throw new HttpsError(error.code, error.message);
      }
      logger?.error('Doctor application operation failed.', {
        operation,
        action,
        errorCode: error?.code ?? 'unknown',
      });
      throw new HttpsError(
        'internal',
        'The application operation could not be completed.',
      );
    }
  };
}

module.exports = { createDoctorApplicationCallable };
