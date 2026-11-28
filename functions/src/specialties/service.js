const { DoctorAdminError } = require('../doctor-admin/errors');
const { requireAdminActor } = require('../doctor-admin/identity');

const ICON_NAMES = new Set([
  'medical',
  'heart',
  'dental',
  'skin',
  'neurology',
  'pediatrics',
  'orthopedics',
]);
const MAX_NAME_LENGTH = 100;
const MAX_DESCRIPTION_LENGTH = 2000;

function createSpecialtyService({ db, serverTimestamp }) {
  if (!db || typeof serverTimestamp !== 'function') {
    throw new TypeError('Firestore and serverTimestamp are required.');
  }

  return {
    async save({ actorUid, payload }) {
      if (typeof actorUid !== 'string' || actorUid.length === 0) {
        throw new DoctorAdminError('unauthenticated', 'Authentication is required.');
      }
      const request = validateSave(payload);
      const specialties = db.collection('specialties');
      const specialtyRef = request.specialtyId
        ? specialties.doc(request.specialtyId)
        : specialties.doc();

      return db.runTransaction(async (transaction) => {
        await requireAdminActor(transaction, db, actorUid);
        const [current, existingSpecialties] = await Promise.all([
          request.specialtyId
            ? transaction.get(specialtyRef)
            : Promise.resolve(null),
          transaction.get(specialties),
        ]);
        if (request.specialtyId && !current.exists) {
          throw new DoctorAdminError('not-found', 'Specialty was not found.');
        }

        assertUniqueNames(existingSpecialties.docs, request, request.specialtyId);
        const currentData = current?.data() ?? {};
        const data = {
          name: request.name,
          nameAr: request.nameAr,
          description: request.description,
          descriptionAr: request.descriptionAr,
          iconName: request.iconName,
          imageUrl: request.clearImage ? '' : readImageUrl(currentData.imageUrl),
          isActive: request.isActive,
          updatedAt: serverTimestamp(),
        };
        if (request.specialtyId) {
          transaction.update(specialtyRef, data);
        } else {
          transaction.create(specialtyRef, {
            ...data,
            createdAt: serverTimestamp(),
          });
        }
        return { specialtyId: specialtyRef.id };
      });
    },

    async setActive({ actorUid, payload }) {
      if (typeof actorUid !== 'string' || actorUid.length === 0) {
        throw new DoctorAdminError('unauthenticated', 'Authentication is required.');
      }
      if (!isPlainObject(payload) ||
          Object.keys(payload).some((key) => !['specialtyId', 'isActive'].includes(key)) ||
          typeof payload.isActive !== 'boolean') {
        throw invalidPayload();
      }
      const specialtyId = readRequiredString(payload.specialtyId, 128);
      const specialtyRef = db.collection('specialties').doc(specialtyId);
      await db.runTransaction(async (transaction) => {
        await requireAdminActor(transaction, db, actorUid);
        const specialty = await transaction.get(specialtyRef);
        if (!specialty.exists) {
          throw new DoctorAdminError('not-found', 'Specialty was not found.');
        }
        transaction.update(specialtyRef, {
          isActive: payload.isActive,
          updatedAt: serverTimestamp(),
        });
      });
      return { specialtyId, isActive: payload.isActive };
    },
  };
}

function validateSave(payload) {
  const allowedFields = [
    'specialtyId',
    'name',
    'nameAr',
    'description',
    'descriptionAr',
    'iconName',
    'isActive',
    'clearImage',
  ];
  if (!isPlainObject(payload) ||
      Object.keys(payload).some((key) => !allowedFields.includes(key))) {
    throw invalidPayload();
  }

  const specialtyId = payload.specialtyId === undefined
    ? undefined
    : readRequiredString(payload.specialtyId, 128);
  const name = readRequiredString(payload.name, MAX_NAME_LENGTH);
  const nameAr = readRequiredString(payload.nameAr, MAX_NAME_LENGTH);
  const description = readOptionalString(payload.description, MAX_DESCRIPTION_LENGTH);
  const descriptionAr = readOptionalString(payload.descriptionAr, MAX_DESCRIPTION_LENGTH);
  const iconName = readRequiredString(payload.iconName, 32);
  if (!ICON_NAMES.has(iconName) ||
      typeof payload.isActive !== 'boolean' ||
      typeof payload.clearImage !== 'boolean') {
    throw invalidPayload();
  }
  return {
    specialtyId,
    name,
    nameAr,
    description,
    descriptionAr,
    iconName,
    isActive: payload.isActive,
    clearImage: payload.clearImage,
  };
}

function assertUniqueNames(documents, request, specialtyId) {
  const requestedNames = new Set([
    normalizeName(request.name),
    normalizeName(request.nameAr),
  ]);
  for (const document of documents) {
    if (document.id === specialtyId) continue;
    const data = document.data();
    const existingNames = [
      normalizeName(data?.name),
      normalizeName(data?.nameAr),
    ].filter(Boolean);
    if (existingNames.some((name) => requestedNames.has(name))) {
      throw new DoctorAdminError(
        'already-exists',
        'A specialty with this name already exists.',
      );
    }
  }
}

function normalizeName(value) {
  if (typeof value !== 'string') return '';
  return value.normalize('NFKC').trim().toLocaleLowerCase().replace(/\s+/g, ' ');
}

function readRequiredString(value, maxLength) {
  if (typeof value !== 'string') throw invalidPayload();
  const normalized = value.trim();
  if (!normalized || normalized.length > maxLength || normalized.includes('/')) {
    throw invalidPayload();
  }
  return normalized;
}

function readOptionalString(value, maxLength) {
  if (value === undefined || value === null) return '';
  if (typeof value !== 'string' || value.trim().length > maxLength) {
    throw invalidPayload();
  }
  return value.trim();
}

function readImageUrl(value) {
  return typeof value === 'string' ? value.trim() : '';
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function invalidPayload() {
  return new DoctorAdminError('invalid-argument', 'Invalid specialty data.');
}

module.exports = { createSpecialtyService };
