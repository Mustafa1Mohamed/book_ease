const { DoctorAdminError } = require('../doctor-admin/errors');
const { requireAdminActor } = require('../doctor-admin/identity');

const APPLICATION_STATUSES = new Set(['pending', 'approved', 'rejected']);
const OPERATION_ID_PATTERN = /^[A-Za-z0-9_-]{1,128}$/;
const MAX_TEXT_LENGTH = 5000;

function createDoctorApplicationService({ db, serverTimestamp }) {
  if (!db || typeof serverTimestamp !== 'function') {
    throw new TypeError('Firestore and serverTimestamp are required.');
  }

  return {
    async submit({ actorUid, payload }) {
      if (typeof actorUid !== 'string' || actorUid.length === 0) {
        throw new DoctorAdminError('unauthenticated', 'Authentication is required.');
      }
      const application = validateSubmission(payload);
      return db.runTransaction(async (transaction) => {
        const userRef = db.collection('users').doc(actorUid);
        const stateRef = db.collection('doctor_application_state').doc(actorUid);
        const specialtyRef = db.collection('specialties').doc(application.specialtyId);
        const doctorQuery = db
          .collection('doctors')
          .where('uid', '==', actorUid)
          .limit(2);
        const applicationHistoryQuery = db
          .collection('doctor_applications')
          .where('applicantUid', '==', actorUid)
          .limit(2);
        const legacyDoctorRef = db.collection('doctors').doc(actorUid);

        const [
          userSnapshot,
          stateSnapshot,
          specialtySnapshot,
          doctorMatches,
          legacyDoctor,
          applicationHistory,
        ] =
          await Promise.all([
            transaction.get(userRef),
            transaction.get(stateRef),
            transaction.get(specialtyRef),
            transaction.get(doctorQuery),
            transaction.get(legacyDoctorRef),
            transaction.get(applicationHistoryQuery),
          ]);

        const userData = userSnapshot.data();
        if (!userSnapshot.exists || userData?.role !== 'patient') {
          throw new DoctorAdminError(
            'failed-precondition',
            'Only patient accounts may apply to become a doctor.',
          );
        }
        if (Object.hasOwn(userData, 'doctorProfileId')) {
          throw new DoctorAdminError(
            'failed-precondition',
            'This account already has a doctor profile link.',
          );
        }
        if (doctorMatches.docs.length > 0 || legacyDoctor.exists) {
          throw new DoctorAdminError(
            'failed-precondition',
            'A doctor profile already exists for this account.',
          );
        }
        const specialty = specialtySnapshot.data();
        if (!specialtySnapshot.exists ||
            specialty?.isActive === false ||
            typeof specialty?.name !== 'string' ||
            specialty.name.trim().length === 0) {
          throw new DoctorAdminError(
            'invalid-argument',
            'Choose an active specialty.',
          );
        }

        const currentApplicationId = stateSnapshot.data()?.currentApplicationId;
        if (stateSnapshot.exists &&
            (typeof currentApplicationId !== 'string' ||
             currentApplicationId.length === 0)) {
          throw new DoctorAdminError(
            'failed-precondition',
            'Application history could not be verified.',
          );
        }
        if (!stateSnapshot.exists && applicationHistory.docs.length > 0) {
          throw new DoctorAdminError(
            'failed-precondition',
            'Application history could not be verified.',
          );
        }
        const currentApplicationRef = typeof currentApplicationId === 'string'
          ? db.collection('doctor_applications').doc(currentApplicationId)
          : null;
        const currentApplication = currentApplicationRef == null
          ? null
          : await transaction.get(currentApplicationRef);
        const previousData = currentApplication?.data();
        if (stateSnapshot.exists &&
            (!currentApplication?.exists ||
             previousData?.applicantUid !== actorUid)) {
          throw new DoctorAdminError(
            'failed-precondition',
            'Application history could not be verified.',
          );
        }
        if (currentApplication?.exists &&
            !APPLICATION_STATUSES.has(previousData?.applicationStatus)) {
          throw new DoctorAdminError(
            'failed-precondition',
            'The existing application has an invalid status.',
          );
        }
        if (previousData?.applicationStatus === 'pending') {
          throw new DoctorAdminError(
            'already-exists',
            'You already have an application under review.',
          );
        }
        if (previousData?.applicationStatus === 'approved' ||
            userData.role !== 'patient') {
          throw new DoctorAdminError(
            'failed-precondition',
            'This account is not eligible to submit another application.',
          );
        }

        const revision = stateSnapshot.exists
          ? stateSnapshot.data()?.nextRevision
          : 1;
        if (!Number.isSafeInteger(revision) || revision < 1) {
          throw new DoctorAdminError(
            'failed-precondition',
            'Application history could not be verified.',
          );
        }
        const applicationId = `${actorUid}_${revision}`;
        const applicationRef = db.collection('doctor_applications').doc(applicationId);
        const duplicateSnapshot = await transaction.get(applicationRef);
        if (duplicateSnapshot.exists) {
          throw new DoctorAdminError(
            'already-exists',
            'This application submission already exists.',
          );
        }

        transaction.create(applicationRef, {
          applicationId,
          applicantUid: actorUid,
          applicantName: application.fullName,
          applicantNameLower: application.fullName.toLowerCase(),
          applicantEmail: readUserString(userData, 'email', 254).toLowerCase(),
          applicantEmailLower: readUserString(userData, 'email', 254).toLowerCase(),
          applicantPhone: application.phoneNumber,
          profileImageUrl: readOptionalString(userData, 'profileImageUrl', 2048),
          specialtyId: application.specialtyId,
          specialtyName: specialty.name.trim(),
          qualification: application.qualification,
          experienceYears: application.experienceYears,
          bio: application.bio,
          consultationFee: application.consultationFee,
          clinicAddress: application.clinicAddress,
          applicationStatus: 'pending',
          submittedAt: serverTimestamp(),
          updatedAt: serverTimestamp(),
          schemaVersion: 1,
          revision,
        });
        if (userData.fullName !== application.fullName ||
            userData.phoneNumber !== application.phoneNumber) {
          transaction.update(userRef, {
            fullName: application.fullName,
            phoneNumber: application.phoneNumber,
            updatedAt: serverTimestamp(),
          });
        }
        if (stateSnapshot.exists) {
          transaction.update(stateRef, {
            currentApplicationId: applicationId,
            nextRevision: revision + 1,
            updatedAt: serverTimestamp(),
          });
        } else {
          transaction.create(stateRef, {
            currentApplicationId: applicationId,
            nextRevision: revision + 1,
            updatedAt: serverTimestamp(),
          });
        }
        return { applicationId, applicationStatus: 'pending' };
      });
    },

    async review({ actorUid, action, payload }) {
      if (!['approve', 'reject'].includes(action)) {
        throw new DoctorAdminError('invalid-argument', 'Unsupported application action.');
      }
      if (typeof actorUid !== 'string' || actorUid.length === 0) {
        throw new DoctorAdminError('unauthenticated', 'Authentication is required.');
      }
      const request = validateReview(action, payload);
      return db.runTransaction(async (transaction) => {
        await requireAdminActor(transaction, db, actorUid);

        const auditRef = db.collection('doctor_application_audit').doc(request.operationId);
        const previousAudit = await transaction.get(auditRef);
        if (previousAudit.exists) {
          const event = previousAudit.data();
          if (!matchesReview(event, actorUid, action, request)) {
            throw new DoctorAdminError(
              'already-exists',
              'The operation ID has already been used.',
            );
          }
          return reviewResult(event);
        }

        const applicationRef = db.collection('doctor_applications').doc(request.applicationId);
        const applicationSnapshot = await transaction.get(applicationRef);
        const application = applicationSnapshot.data();
        if (!applicationSnapshot.exists) {
          throw new DoctorAdminError('not-found', 'Application was not found.');
        }
        if (application?.applicationStatus !== 'pending') {
          throw new DoctorAdminError(
            'failed-precondition',
            'Only pending applications can be reviewed.',
          );
        }
        const applicantUid = application.applicantUid;
        if (typeof applicantUid !== 'string' || applicantUid === actorUid) {
          throw new DoctorAdminError(
            'permission-denied',
            'An administrator cannot review their own application.',
          );
        }
        const userRef = db.collection('users').doc(applicantUid);
        const stateRef = db.collection('doctor_application_state').doc(applicantUid);
        const doctorQuery = db.collection('doctors').where('uid', '==', applicantUid).limit(2);
        const legacyDoctorRef = db.collection('doctors').doc(applicantUid);
        const [userSnapshot, stateSnapshot, doctorMatches, legacyDoctor] = await Promise.all([
          transaction.get(userRef),
          transaction.get(stateRef),
          transaction.get(doctorQuery),
          transaction.get(legacyDoctorRef),
        ]);
        const userData = userSnapshot.data();
        if (!userSnapshot.exists ||
            userData?.role !== 'patient' ||
            stateSnapshot.data()?.currentApplicationId !== request.applicationId) {
          throw new DoctorAdminError(
            'failed-precondition',
            'The applicant or current application state could not be verified.',
          );
        }
        if (doctorMatches.docs.length > 0 ||
            legacyDoctor.exists ||
            Object.hasOwn(userData, 'doctorProfileId')) {
          throw new DoctorAdminError(
            'failed-precondition',
            'A conflicting doctor profile already exists.',
          );
        }

        const reviewedAt = serverTimestamp();
        const event = {
          actorUid,
          action: `application_${action}`,
          applicationId: request.applicationId,
          applicantUid,
          operationId: request.operationId,
          reason: request.reason ?? '',
          schemaVersion: 1,
          createdAt: reviewedAt,
        };
        if (action === 'approve') {
          const doctorProfileId = `doctor_${request.applicationId}`;
          const doctorRef = db.collection('doctors').doc(doctorProfileId);
          const doctorSnapshot = await transaction.get(doctorRef);
          if (doctorSnapshot.exists) {
            throw new DoctorAdminError(
              'failed-precondition',
              'The doctor profile ID is already in use.',
            );
          }
          const doctorProfile = {
            uid: applicantUid,
            fullName: application.applicantName,
            email: application.applicantEmail,
            phoneNumber: application.applicantPhone,
            profileImageUrl: application.profileImageUrl ?? '',
            specialtyId: application.specialtyId,
            specialtyName: application.specialtyName,
            qualifications: [application.qualification],
            yearsExperience: application.experienceYears,
            biography: application.bio,
            consultationFee: application.consultationFee,
            clinicAddress: application.clinicAddress,
            approvalStatus: 'approved',
            administrativeStatus: 'active',
            applicationId: request.applicationId,
            createdAt: reviewedAt,
            updatedAt: reviewedAt,
          };
          transaction.create(doctorRef, doctorProfile);
          transaction.update(userRef, {
            role: 'doctor',
            doctorProfileId,
            fullName: application.applicantName,
            phoneNumber: application.applicantPhone,
            updatedAt: reviewedAt,
          });
          transaction.update(applicationRef, {
            applicationStatus: 'approved',
            reviewerUid: actorUid,
            reviewedAt,
            doctorProfileId,
            updatedAt: reviewedAt,
          });
          event.doctorProfileId = doctorProfileId;
          event.newRole = 'doctor';
        } else {
          transaction.update(applicationRef, {
            applicationStatus: 'rejected',
            reviewerUid: actorUid,
            reviewedAt,
            rejectionReason: request.reason,
            updatedAt: reviewedAt,
          });
        }
        transaction.create(auditRef, event);
        return reviewResult(event);
      });
    },
  };
}

function validateSubmission(payload) {
  if (!isPlainObject(payload) ||
      Object.keys(payload).some((key) => ![
    'fullName',
    'phoneNumber',
        'specialtyId',
        'qualification',
        'experienceYears',
        'bio',
        'consultationFee',
        'clinicAddress',
      ].includes(key))) {
    throw invalidPayload();
  }
  const fullName = readRequiredString(payload.fullName, 120);
  const phoneNumber = readRequiredString(payload.phoneNumber, 40);
  const specialtyId = readRequiredString(payload.specialtyId, 128);
  const qualification = readRequiredString(payload.qualification, 250);
  const bio = readRequiredString(payload.bio, MAX_TEXT_LENGTH);
  const clinicAddress = readRequiredString(payload.clinicAddress, 500);
  const experienceYears = payload.experienceYears;
  const consultationFee = payload.consultationFee;
  if (!Number.isSafeInteger(experienceYears) ||
      experienceYears < 0 ||
      experienceYears > 80 ||
      !/^[0-9+() .-]{7,24}$/.test(phoneNumber) ||
      typeof consultationFee !== 'number' ||
      !Number.isFinite(consultationFee) || consultationFee < 0 ||
      consultationFee > 1000000) {
    throw invalidPayload();
  }
  return {
    fullName,
    phoneNumber,
    specialtyId,
    qualification,
    experienceYears,
    bio,
    consultationFee,
    clinicAddress,
  };
}

function validateReview(action, payload) {
  const allowed = action === 'reject'
    ? ['applicationId', 'operationId', 'reason']
    : ['applicationId', 'operationId'];
  if (!isPlainObject(payload) || Object.keys(payload).some((key) => !allowed.includes(key))) {
    throw invalidPayload();
  }
  const applicationId = readRequiredString(payload.applicationId, 256);
  const operationId = readRequiredString(payload.operationId, 128);
  if (!OPERATION_ID_PATTERN.test(operationId)) throw invalidPayload();
  let reason;
  if (action === 'reject') {
    reason = readRequiredString(payload.reason, 500);
    if (reason.length < 5) throw invalidPayload();
  }
  return { applicationId, operationId, reason };
}

function readUserString(userData, key, maxLength) {
  const value = userData[key];
  if (typeof value !== 'string' || value.trim().length === 0 ||
      value.trim().length > maxLength) {
    throw new DoctorAdminError(
      'failed-precondition',
      'Complete your account profile before applying.',
    );
  }
  return value.trim();
}

function readOptionalString(userData, key, maxLength) {
  const value = userData[key];
  if (value === undefined || value === null || value === '') return '';
  if (typeof value !== 'string' || value.trim().length > maxLength) {
    throw new DoctorAdminError(
      'failed-precondition',
      'Complete your account profile before applying.',
    );
  }
  return value.trim();
}

function readRequiredString(value, maxLength) {
  if (typeof value !== 'string' || value.trim().length === 0 ||
      value.trim().length > maxLength || value.includes('/')) {
    throw invalidPayload();
  }
  return value.trim();
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function matchesReview(event, actorUid, action, request) {
  return event.actorUid === actorUid &&
    event.action === `application_${action}` &&
    event.applicationId === request.applicationId &&
    event.operationId === request.operationId &&
    event.reason === (request.reason ?? '');
}

function reviewResult(event) {
  return {
    applicationId: event.applicationId,
    action: event.action,
    applicantUid: event.applicantUid,
    doctorProfileId: event.doctorProfileId ?? null,
    applicationStatus: event.action === 'application_approve' ? 'approved' : 'rejected',
    operationId: event.operationId,
  };
}

function invalidPayload() {
  return new DoctorAdminError('invalid-argument', 'Invalid application payload.');
}

module.exports = { createDoctorApplicationService };
