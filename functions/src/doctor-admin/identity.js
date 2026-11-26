const { DoctorAdminError } = require('./errors');

async function requireAdminActor(transaction, db, actorUid) {
  const actorRef = db.collection('users').doc(actorUid);
  const actorSnapshot = await transaction.get(actorRef);
  if (!actorSnapshot.exists || actorSnapshot.data()?.role !== 'admin') {
    throw new DoctorAdminError(
      'permission-denied',
      'This action is not permitted.',
    );
  }
  return actorRef;
}

async function resolveDoctorProfile(
  transaction,
  db,
  targetDoctorUid,
  targetUserData,
) {
  if (targetUserData?.role !== 'doctor') {
    throw doctorNotFound();
  }

  const doctors = db.collection('doctors');
  const matches = await transaction.get(
    doctors.where('uid', '==', targetDoctorUid).limit(2),
  );
  if (matches.docs.length > 1) {
    throw ambiguousIdentity();
  }

  const legacyRef = doctors.doc(targetDoctorUid);
  const legacySnapshot = await transaction.get(legacyRef);
  const hasExplicitLink = Object.hasOwn(targetUserData, 'doctorProfileId');

  if (hasExplicitLink) {
    const linkedId = targetUserData.doctorProfileId;
    if (
      typeof linkedId !== 'string' ||
      linkedId.length === 0 ||
      linkedId.length > 1500 ||
      linkedId.includes('/') ||
      linkedId.trim() !== linkedId
    ) {
      throw invalidIdentity();
    }

    const linkedRef = doctors.doc(linkedId);
    const linkedSnapshot = await transaction.get(linkedRef);
    if (
      !linkedSnapshot.exists ||
      linkedSnapshot.data()?.uid !== targetDoctorUid ||
      matches.docs.length !== 1 ||
      matches.docs[0].id !== linkedId
    ) {
      throw invalidIdentity();
    }

    if (
      legacySnapshot.exists &&
      legacySnapshot.id !== linkedId
    ) {
      throw ambiguousIdentity();
    }

    return { doctorRef: linkedRef, doctorData: linkedSnapshot.data() };
  }

  if (matches.docs.length === 1) {
    const match = matches.docs[0];
    if (legacySnapshot.exists && legacySnapshot.id !== match.id) {
      throw ambiguousIdentity();
    }
    return {
      doctorRef: doctors.doc(match.id),
      doctorData: match.data(),
    };
  }

  if (!legacySnapshot.exists) throw doctorNotFound();
  const legacyData = legacySnapshot.data();
  const legacyUid = legacyData?.uid;
  if (
    (legacyUid === undefined || legacyUid === null || legacyUid === '') &&
    legacySnapshot.id === targetDoctorUid
  ) {
    return { doctorRef: legacyRef, doctorData: legacyData };
  }

  throw invalidIdentity();
}

function doctorNotFound() {
  return new DoctorAdminError('not-found', 'Doctor profile was not found.');
}

function invalidIdentity() {
  return new DoctorAdminError(
    'failed-precondition',
    'The doctor profile identity could not be verified.',
  );
}

function ambiguousIdentity() {
  return new DoctorAdminError(
    'failed-precondition',
    'The doctor profile identity is ambiguous.',
  );
}

module.exports = { requireAdminActor, resolveDoctorProfile };
