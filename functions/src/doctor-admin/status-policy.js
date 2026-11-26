const { DoctorAdminError } = require('./errors');

const APPROVAL_STATUSES = new Set(['pending', 'approved', 'rejected']);
const ADMINISTRATIVE_STATUSES = new Set(['active', 'suspended']);

function readApprovalStatus(doctorData) {
  requireStatusRecord(doctorData);
  if (!Object.hasOwn(doctorData, 'approvalStatus')) return 'pending';
  const status = doctorData.approvalStatus;
  if (typeof status === 'string' && APPROVAL_STATUSES.has(status)) {
    return status;
  }
  throw invalidStatus();
}

function readAdministrativeStatus(doctorData) {
  requireStatusRecord(doctorData);
  if (!Object.hasOwn(doctorData, 'administrativeStatus')) return 'active';
  const status = doctorData.administrativeStatus;
  if (typeof status === 'string' && ADMINISTRATIVE_STATUSES.has(status)) {
    return status;
  }
  throw invalidStatus();
}

function readDoctorStatus(doctorData) {
  if (doctorData === null || typeof doctorData !== 'object') {
    throw invalidStatus();
  }

  const status = {
    approvalStatus: readApprovalStatus(doctorData),
    administrativeStatus: readAdministrativeStatus(doctorData),
  };
  if (
    (status.administrativeStatus === 'suspended' &&
      status.approvalStatus !== 'approved')
  ) {
    throw invalidStatus();
  }
  return status;
}

function transitionDoctorStatus(action, currentStatus) {
  const current = readDoctorStatus(currentStatus);
  const allowed = {
    approve: {
      from: ['pending', 'active'],
      to: ['approved', 'active'],
    },
    reject: {
      from: ['pending', 'active'],
      to: ['rejected', 'active'],
    },
    suspend: {
      from: ['approved', 'active'],
      to: ['approved', 'suspended'],
    },
    restore: {
      from: ['approved', 'suspended'],
      to: ['approved', 'active'],
    },
  }[action];

  if (!allowed) {
    throw new DoctorAdminError('invalid-argument', 'Unsupported doctor action.');
  }

  if (
    current.approvalStatus !== allowed.from[0] ||
    current.administrativeStatus !== allowed.from[1]
  ) {
    throw new DoctorAdminError(
      'failed-precondition',
      'The doctor status does not allow this action.',
    );
  }

  return {
    approvalStatus: allowed.to[0],
    administrativeStatus: allowed.to[1],
  };
}

function invalidStatus() {
  return new DoctorAdminError(
    'failed-precondition',
    'The doctor has an invalid status.',
  );
}

function requireStatusRecord(doctorData) {
  if (doctorData === null || typeof doctorData !== 'object') {
    throw invalidStatus();
  }
}

module.exports = {
  readApprovalStatus,
  readAdministrativeStatus,
  readDoctorStatus,
  transitionDoctorStatus,
};
