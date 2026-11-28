const { DoctorAdminError } = require('../doctor-admin/errors');

function createSpecialtyCallable({ service, operation, HttpsError, logger }) {
  return async (request) => {
    const actorUid = request?.auth?.uid;
    if (typeof actorUid !== 'string' || actorUid.length === 0) {
      throw new HttpsError('unauthenticated', 'Authentication is required.');
    }
    try {
      if (operation === 'save') {
        return await service.save({ actorUid, payload: request.data });
      }
      return await service.setActive({ actorUid, payload: request.data });
    } catch (error) {
      if (error instanceof DoctorAdminError) {
        throw new HttpsError(error.code, error.message);
      }
      logger?.error('Specialty management operation failed.', {
        operation,
        errorCode: error?.code ?? 'unknown',
      });
      throw new HttpsError(
        'internal',
        'The specialty operation could not be completed.',
      );
    }
  };
}

module.exports = { createSpecialtyCallable };
