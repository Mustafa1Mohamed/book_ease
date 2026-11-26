const { DoctorAdminError } = require('./errors');
const { requireAdminActor, resolveDoctorProfile } = require('./identity');
const {
  readDoctorStatus,
  transitionDoctorStatus,
} = require('./status-policy');

const ACTIONS = new Set(['approve', 'reject', 'suspend', 'restore']);
const REASON_REQUIRED_ACTIONS = new Set(['reject', 'suspend']);
const OPERATION_ID_PATTERN = /^[A-Za-z0-9_-]{1,128}$/;
const MAX_REASON_LENGTH = 500;

function createDoctorAdminService({ db, serverTimestamp }) {
  if (!db || typeof serverTimestamp !== 'function') {
    throw new TypeError('Firestore and serverTimestamp are required.');
  }

  return {
    async execute({ actorUid, action, payload }) {
      if (!ACTIONS.has(action)) {
        throw new DoctorAdminError(
          'invalid-argument',
          'Unsupported doctor action.',
        );
      }
      if (typeof actorUid !== 'string' || actorUid.length === 0) {
        throw new DoctorAdminError(
          'unauthenticated',
          'Authentication is required.',
        );
      }
      const request = validatePayload(action, payload);
      return db.runTransaction(async (transaction) => {
        await requireAdminActor(transaction, db, actorUid);

        const auditRef = db
          .collection('doctor_admin_audit')
          .doc(request.operationId);
        const existingAudit = await transaction.get(auditRef);
        if (existingAudit.exists) {
          const event = existingAudit.data();
          if (!matchesRequest(event, actorUid, action, request)) {
            throw new DoctorAdminError(
              'already-exists',
              'The operation ID has already been used.',
            );
          }
          return resultFromAudit(event);
        }

        const targetUserRef = db.collection('users').doc(
          request.targetDoctorUid,
        );
        const targetUserSnapshot = await transaction.get(targetUserRef);
        if (!targetUserSnapshot.exists) {
          throw new DoctorAdminError(
            'not-found',
            'Doctor profile was not found.',
          );
        }
        const { doctorRef, doctorData } = await resolveDoctorProfile(
          transaction,
          db,
          request.targetDoctorUid,
          targetUserSnapshot.data(),
        );
        const previous = readDoctorStatus(doctorData);
        const next = transitionDoctorStatus(action, previous);

        const event = {
          actorUid,
          action,
          targetDoctorUid: request.targetDoctorUid,
          doctorProfileId: doctorRef.id,
          previousApprovalStatus: previous.approvalStatus,
          newApprovalStatus: next.approvalStatus,
          previousAdministrativeStatus: previous.administrativeStatus,
          newAdministrativeStatus: next.administrativeStatus,
          operationId: request.operationId,
          schemaVersion: 1,
          createdAt: serverTimestamp(),
        };
        if (request.reason !== undefined) event.reason = request.reason;

        transaction.update(doctorRef, {
          approvalStatus: next.approvalStatus,
          administrativeStatus: next.administrativeStatus,
        });
        transaction.create(auditRef, event);
        return resultFromAudit(event);
      });
    },
  };
}

function validatePayload(action, payload) {
  if (
    payload === null ||
    typeof payload !== 'object' ||
    Array.isArray(payload)
  ) {
    throw invalidPayload();
  }
  const allowedKeys = new Set(['targetDoctorUid', 'operationId', 'reason']);
  if (Object.keys(payload).some((key) => !allowedKeys.has(key))) {
    throw invalidPayload();
  }

  const targetDoctorUid = readRequiredString(payload.targetDoctorUid, 128);
  const operationId = readRequiredString(payload.operationId, 128);
  if (!OPERATION_ID_PATTERN.test(operationId)) throw invalidPayload();

  let reason;
  if (Object.hasOwn(payload, 'reason')) {
    if (typeof payload.reason !== 'string') throw invalidPayload();
    reason = payload.reason.trim();
    if (reason.length === 0 || reason.length > MAX_REASON_LENGTH) {
      throw invalidPayload();
    }
  }
  if (REASON_REQUIRED_ACTIONS.has(action) && reason === undefined) {
    throw new DoctorAdminError(
      'invalid-argument',
      'A reason is required for this action.',
    );
  }

  return { targetDoctorUid, operationId, reason };
}

function readRequiredString(value, maxLength) {
  if (
    typeof value !== 'string' ||
    value.length === 0 ||
    value.length > maxLength ||
    value.includes('/') ||
    value.trim() !== value
  ) {
    throw invalidPayload();
  }
  return value;
}

function matchesRequest(event, actorUid, action, request) {
  return (
    event.actorUid === actorUid &&
    event.action === action &&
    event.targetDoctorUid === request.targetDoctorUid &&
    event.operationId === request.operationId &&
    event.reason === request.reason
  );
}

function resultFromAudit(event) {
  return {
    operationId: event.operationId,
    action: event.action,
    targetDoctorUid: event.targetDoctorUid,
    doctorProfileId: event.doctorProfileId,
    approvalStatus: event.newApprovalStatus,
    administrativeStatus: event.newAdministrativeStatus,
  };
}

function invalidPayload() {
  return new DoctorAdminError('invalid-argument', 'Invalid action payload.');
}

module.exports = { createDoctorAdminService };
