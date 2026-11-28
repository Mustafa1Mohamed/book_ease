import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  after,
  before,
  beforeEach,
  test,
} from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteField,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const PROJECT_ID = 'demo-bookease-rules-test';
const FUTURE_APPOINTMENT_AT = Timestamp.fromDate(
  new Date(Date.now() + 2 * 60 * 60 * 1000),
);
const FUTURE_APPOINTMENT_END_AT = Timestamp.fromDate(
  new Date(Date.now() + 150 * 60 * 1000),
);
const emulatorAddress = process.env.FIRESTORE_EMULATOR_HOST ?? '';
const projectId = process.env.GCLOUD_PROJECT ?? process.env.GOOGLE_CLOUD_PROJECT;
if (
  projectId !== PROJECT_ID ||
  !/^((127\.0\.0\.1)|(localhost)):8085$/.test(emulatorAddress)
) {
  throw new Error(
    'Rules tests require the local demo-bookease-rules-test Firestore emulator on port 8085.',
  );
}

const testDirectory = path.dirname(fileURLToPath(import.meta.url));
const rootDirectory = path.resolve(testDirectory, '..', '..', '..');
let testEnvironment;

before(async () => {
  testEnvironment = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: '127.0.0.1',
      port: 8085,
      rules: readFileSync(path.join(rootDirectory, 'firestore.rules'), 'utf8'),
    },
  });
});

after(async () => {
  await testEnvironment?.cleanup();
});

beforeEach(async () => {
  await testEnvironment.clearFirestore();
});

function dbFor(uid, email = `${uid}@example.com`) {
  return testEnvironment.authenticatedContext(uid, { email }).firestore();
}

function doctorRecord({
  approvalStatus = 'approved',
  administrativeStatus = 'active',
  includeAdministrativeStatus = true,
  uid = 'doctor-1',
} = {}) {
  return {
    uid,
    fullName: 'Dr. Morgan Lee',
    profileImageUrl: '',
    specialtyId: 'cardiology',
    specialtyName: 'Cardiology',
    consultationFee: 80,
    isFeatured: true,
    approvalStatus,
    ...(includeAdministrativeStatus ? { administrativeStatus } : {}),
  };
}

async function seed({
  approvalStatus = 'approved',
  administrativeStatus = 'active',
  includeAdministrativeStatus = true,
  doctorUid = 'doctor-1',
  doctorProfileId = 'doctor-1',
} = {}) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/patient-1'), {
      uid: 'patient-1',
      role: 'patient',
      fullName: 'Patient One',
      email: 'patient@example.com',
      profileImageUrl: '',
      phoneNumber: '100',
    });
    await setDoc(doc(db, 'users/doctor-1'), {
      uid: 'doctor-1',
      role: 'doctor',
      ...(doctorProfileId === undefined ? {} : { doctorProfileId }),
    });
    await setDoc(doc(db, 'users/admin-1'), {
      uid: 'admin-1',
      role: 'admin',
    });
    await setDoc(doc(db, 'specialties/cardiology'), {
      name: 'Cardiology',
      isActive: true,
    });
    await setDoc(doc(db, 'doctors/doctor-1'), doctorRecord({
      approvalStatus,
      administrativeStatus,
      includeAdministrativeStatus,
      uid: doctorUid,
    }));

    await setDoc(doc(db, 'doctors/doctor-1/availabilitySlots/slot-1'), {
      startAt: FUTURE_APPOINTMENT_AT,
      endAt: FUTURE_APPOINTMENT_END_AT,
      isAvailable: true,
    });
  });
}

function bookingBatch(db, {
  appointmentId = 'new-appointment',
  slotId = 'slot-1',
} = {}) {
  const appointmentAt = FUTURE_APPOINTMENT_AT;
  const appointmentEndAt = FUTURE_APPOINTMENT_END_AT;
  const batch = writeBatch(db);
  batch.update(doc(db, `doctors/doctor-1/availabilitySlots/${slotId}`), {
    isAvailable: false,
    appointmentId,
    reservedAt: serverTimestamp(),
  });
  batch.set(doc(db, `appointments/${appointmentId}`), {
    patientId: 'patient-1',
    patientName: 'Patient One',
    patientImageUrl: '',
    patientPhoneNumber: '100',
    doctorId: 'doctor-1',
    doctorName: 'Dr. Morgan Lee',
    doctorImageUrl: '',
    specialtyId: 'cardiology',
    specialtyName: 'Cardiology',
    slotId,
    appointmentAt,
    appointmentEndAt,
    appointmentDate: appointmentAt,
    appointmentTime: '10:00 AM',
    consultationFee: 80,
    status: 'confirmed',
    createdAt: serverTimestamp(),
  });
  return batch;
}

async function seedAppointment({
  appointmentId = 'appointment-1',
  patientId = 'patient-1',
  slotId = 'slot-1',
  appointmentAt = FUTURE_APPOINTMENT_AT,
  appointmentEndAt = FUTURE_APPOINTMENT_END_AT,
  slotAppointmentId = appointmentId,
} = {}) {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, `appointments/${appointmentId}`), {
      patientId,
      doctorId: 'doctor-1',
      slotId,
      appointmentAt,
      appointmentEndAt,
      status: 'confirmed',
    });
    await setDoc(doc(db, `doctors/doctor-1/availabilitySlots/${slotId}`), {
      startAt: appointmentAt,
      endAt: appointmentEndAt,
      isAvailable: false,
      appointmentId: slotAppointmentId,
      reservedAt: Timestamp.now(),
    });
  });
}

test('denies booking pending, rejected, suspended, and invalid doctors', async () => {
  const cases = [
    { approvalStatus: 'pending', administrativeStatus: 'active' },
    { approvalStatus: 'rejected', administrativeStatus: 'active' },
    { approvalStatus: 'approved', administrativeStatus: 'suspended' },
    { approvalStatus: 'approved', administrativeStatus: null },
    { approvalStatus: 'approved', administrativeStatus: '' },
    { approvalStatus: 'approved', administrativeStatus: 'blocked' },
    { approvalStatus: 'pending', administrativeStatus: 'suspended' },
    { approvalStatus: null, administrativeStatus: 'active' },
  ];

  for (const [index, status] of cases.entries()) {
    await seed(status);
    await assertFails(bookingBatch(dbFor('patient-1'), {
      appointmentId: `blocked-${index}`,
    }).commit());
  }
});

test('allows an approved active doctor booking atomically', async () => {
  await seed();
  const db = dbFor('patient-1');
  const patient = await assertSucceeds(getDoc(doc(db, 'users/patient-1')));
  assert.equal(patient.data()?.role, 'patient');
  await assertSucceeds(getDoc(doc(db, 'doctors/doctor-1')));
  await assertSucceeds(
    getDoc(doc(db, 'doctors/doctor-1/availabilitySlots/slot-1')),
  );
  await assertSucceeds(bookingBatch(db).commit());

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const privileged = context.firestore();
    const [appointment, slot] = await Promise.all([
      getDoc(doc(privileged, 'appointments/new-appointment')),
      getDoc(doc(privileged, 'doctors/doctor-1/availabilitySlots/slot-1')),
    ]);
    assert.equal(appointment.data()?.status, 'confirmed');
    assert.equal(slot.data()?.isAvailable, false);
    assert.equal(slot.data()?.appointmentId, 'new-appointment');
  });
});

test('doctor applications are readable only by the applicant or an admin', async () => {
    await seed();
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'doctor_applications/application-own'), {
        applicationId: 'application-own',
        applicantUid: 'patient-1',
        applicationStatus: 'pending',
        specialtyId: 'cardiology',
      });
      await setDoc(doc(db, 'doctor_applications/application-other'), {
        applicationId: 'application-other',
        applicantUid: 'patient-2',
        applicationStatus: 'pending',
        specialtyId: 'cardiology',
      });
    });

    const patientDb = dbFor('patient-1');
    await assertSucceeds(getDoc(doc(patientDb, 'doctor_applications/application-own')));
    await assertFails(getDoc(doc(patientDb, 'doctor_applications/application-other')));
    await assertSucceeds(
      getDocs(query(
        collection(patientDb, 'doctor_applications'),
        where('applicantUid', '==', 'patient-1'),
      )),
    );
    await assertFails(getDoc(
      doc(dbFor('doctor-1'), 'doctor_application_state/patient-1'),
    ));
    await assertFails(
      getDocs(collection(patientDb, 'doctor_applications')),
    );
    await assertSucceeds(
      getDocs(collection(dbFor('admin-1'), 'doctor_applications')),
    );
  });

test('patients can submit valid applications but cannot forge or review them', async () => {
    await seed();
    const patientDb = dbFor('patient-1');
    const applicationData = {
      applicationId: 'patient-1_1',
      applicantUid: 'patient-1',
      applicantName: 'Patient One',
      applicantNameLower: 'patient one',
      applicantEmail: 'patient@example.com',
      applicantEmailLower: 'patient@example.com',
      applicantPhone: '+1 555 0100',
      profileImageUrl: '',
      specialtyId: 'cardiology',
      specialtyName: 'Cardiology',
      qualification: 'MD',
      experienceYears: 8,
      bio: 'A professional biography.',
      consultationFee: 80,
      clinicAddress: 'Main Street clinic',
      applicationStatus: 'pending',
      submittedAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
      schemaVersion: 1,
      revision: 1,
    };
    const submission = writeBatch(patientDb);
    submission.update(doc(patientDb, 'users/patient-1'), {
      fullName: applicationData.applicantName,
      phoneNumber: applicationData.applicantPhone,
      updatedAt: serverTimestamp(),
    });
    submission.set(
      doc(patientDb, 'doctor_applications/patient-1_1'),
      applicationData,
    );
    submission.set(doc(patientDb, 'doctor_application_state/patient-1'), {
      currentApplicationId: 'patient-1_1',
      nextRevision: 2,
      updatedAt: serverTimestamp(),
    });
    await assertSucceeds(submission.commit());

    const doctorDb = dbFor('doctor-1');
    const forgedSubmission = writeBatch(doctorDb);
    forgedSubmission.set(
      doc(doctorDb, 'doctor_applications/forged'),
      { ...applicationData, applicationId: 'forged' },
    );
    forgedSubmission.set(
      doc(doctorDb, 'doctor_application_state/doctor-1'),
      {
        currentApplicationId: 'forged',
        nextRevision: 2,
        updatedAt: serverTimestamp(),
      },
    );
    await assertFails(forgedSubmission.commit());

    const adminDb = dbFor('admin-1');
    await assertSucceeds(
      getDoc(doc(adminDb, 'doctor_application_state/patient-1')),
    );
    const rejection = writeBatch(adminDb);
    rejection.update(
      doc(adminDb, 'doctor_applications/patient-1_1'),
      {
        applicationStatus: 'rejected',
        reviewedBy: 'admin-1',
        reviewedAt: serverTimestamp(),
        rejectionReason: 'Please add more experience details.',
        updatedAt: serverTimestamp(),
      },
    );
    rejection.set(doc(adminDb, 'doctor_application_audit/reject-test'), {
      actorUid: 'admin-1',
      action: 'application_reject',
      applicationId: 'patient-1_1',
      applicantUid: 'patient-1',
      operationId: 'reject-test',
      reason: 'Please add more experience details.',
      schemaVersion: 1,
      createdAt: serverTimestamp(),
    });
    await assertSucceeds(rejection.commit());

    const resubmission = writeBatch(patientDb);
    resubmission.set(
      doc(patientDb, 'doctor_applications/patient-1_2'),
      {
        ...applicationData,
        applicationId: 'patient-1_2',
        submittedAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        revision: 2,
      },
    );
    resubmission.update(
      doc(patientDb, 'doctor_application_state/patient-1'),
      {
        currentApplicationId: 'patient-1_2',
        nextRevision: 3,
        updatedAt: serverTimestamp(),
      },
    );
    await assertSucceeds(resubmission.commit());

    const doctorProfileId = 'doctor_patient-1_2';
    const makeApproval = (db = adminDb) => {
      const approval = writeBatch(db);
      approval.set(doc(db, `doctors/${doctorProfileId}`), {
        uid: 'patient-1',
        fullName: 'Patient One',
        email: 'patient@example.com',
        phoneNumber: '+1 555 0100',
        profileImageUrl: '',
        specialtyId: 'cardiology',
        specialtyName: 'Cardiology',
        qualifications: ['MD'],
        yearsExperience: 8,
        biography: 'A professional biography.',
        consultationFee: 80,
        clinicAddress: 'Main Street clinic',
        approvalStatus: 'approved',
        administrativeStatus: 'active',
        applicationId: 'patient-1_2',
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      });
      approval.update(doc(db, 'users/patient-1'), {
        role: 'doctor',
        doctorProfileId,
        fullName: 'Patient One',
        phoneNumber: '+1 555 0100',
        updatedAt: serverTimestamp(),
      });
      approval.update(doc(db, 'doctor_applications/patient-1_2'), {
        applicationStatus: 'approved',
        reviewedBy: 'admin-1',
        reviewedAt: serverTimestamp(),
        doctorProfileId,
        updatedAt: serverTimestamp(),
      });
      approval.set(doc(db, 'doctor_application_audit/approve-test'), {
        actorUid: 'admin-1',
        action: 'application_approve',
        applicationId: 'patient-1_2',
        applicantUid: 'patient-1',
        operationId: 'approve-test',
        reason: '',
        schemaVersion: 1,
        createdAt: serverTimestamp(),
        doctorProfileId,
        newRole: 'doctor',
      });
      return approval;
    };

    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await updateDoc(doc(context.firestore(), 'specialties/cardiology'), {
        isActive: false,
      });
    });
    await assertFails(makeApproval(patientDb).commit());
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await updateDoc(doc(context.firestore(), 'specialties/cardiology'), {
        isActive: true,
      });
    });
    const operationId = 'application_patient-1_2_approve';
    const doctorProfile = {
      uid: 'patient-1',
      fullName: 'Patient One',
      email: 'patient@example.com',
      phoneNumber: '+1 555 0100',
      profileImageUrl: '',
      specialtyId: 'cardiology',
      specialtyName: 'Cardiology',
      qualifications: ['MD'],
      yearsExperience: 8,
      biography: 'A professional biography.',
      consultationFee: 80,
      clinicAddress: 'Main Street clinic',
      approvalStatus: 'approved',
      administrativeStatus: 'active',
      applicationId: 'patient-1_2',
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    };
    const userPromotion = {
      role: 'doctor',
      doctorProfileId,
      fullName: 'Patient One',
      phoneNumber: '+1 555 0100',
      updatedAt: serverTimestamp(),
    };
    const applicationApproval = {
      applicationStatus: 'approved',
      reviewedBy: 'admin-1',
      reviewedAt: serverTimestamp(),
      doctorProfileId,
      updatedAt: serverTimestamp(),
    };
    const auditRecord = {
      actorUid: 'admin-1',
      action: 'application_approve',
      applicationId: 'patient-1_2',
      applicantUid: 'patient-1',
      operationId,
      reason: '',
      schemaVersion: 1,
      createdAt: serverTimestamp(),
      doctorProfileId,
      newRole: 'doctor',
    };

    await assertFails(setDoc(
      doc(patientDb, `doctors/${doctorProfileId}`),
      doctorProfile,
    ));
    await assertFails(updateDoc(
      doc(patientDb, 'users/patient-1'),
      userPromotion,
    ));
    await assertFails(updateDoc(
      doc(patientDb, 'doctor_applications/patient-1_2'),
      applicationApproval,
    ));
    await assertFails(setDoc(
      doc(patientDb, `doctor_application_audit/${operationId}`),
      auditRecord,
    ));

    const commitApproval = ({
      db = adminDb,
      reviewedBy = 'admin-1',
      auditActor = 'admin-1',
    } = {}) => {
      const transactionApplicationReference = doc(
        db,
        'doctor_applications/patient-1_2',
      );
      const transactionUserReference = doc(db, 'users/patient-1');
      const transactionDoctorReference = doc(db, `doctors/${doctorProfileId}`);
      const transactionAuditReference = doc(
        db,
        `doctor_application_audit/${operationId}`,
      );
      return db.runTransaction(async (transaction) => {
        const approvalAudit = { ...auditRecord, actorUid: auditActor };
        const approvedApplication = {
          ...applicationApproval,
          reviewedBy,
        };

        await transaction.get(transactionAuditReference);
        await transaction.get(transactionApplicationReference);
        await transaction.get(transactionUserReference);
        await transaction.get(doc(db, 'doctor_application_state/patient-1'));
        await transaction.get(doc(db, 'doctors/patient-1'));
        await transaction.get(doc(db, 'specialties/cardiology'));
        await transaction.get(transactionDoctorReference);

        transaction.set(transactionDoctorReference, doctorProfile);
        transaction.update(transactionUserReference, userPromotion);
        transaction.update(transactionApplicationReference, approvedApplication);
        transaction.set(transactionAuditReference, approvalAudit);
      });
    };

    await assertFails(commitApproval({
      db: patientDb,
      reviewedBy: 'patient-1',
      auditActor: 'patient-1',
    }));
    await assertSucceeds(commitApproval());

    await assertSucceeds(getDoc(doc(adminDb, `doctors/${doctorProfileId}`)));
    assert.equal(
      (await assertSucceeds(getDoc(doc(adminDb, 'users/patient-1')))).data()?.role,
      'doctor',
    );

    await assertFails(updateDoc(
      doc(patientDb, 'doctor_applications/patient-1_2'),
      { applicationStatus: 'approved' },
    ));
    await assertFails(updateDoc(
      doc(patientDb, 'doctor_applications/patient-1_2'),
      { reviewedBy: 'patient-1' },
    ));
    await assertFails(updateDoc(
      doc(patientDb, 'doctor_application_state/patient-1'),
      { nextRevision: 100 },
    ));
  });

test('specialties are readable by authenticated users and admins can manage them', async () => {
    await seed();
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'specialties/active'), {
        name: 'Cardiology',
        nameLower: 'cardiology',
        nameAr: 'أمراض القلب',
        description: '',
        descriptionAr: '',
        iconName: 'heart',
        imageUrl: '',
        isActive: true,
      });
      await setDoc(doc(db, 'specialties/inactive'), {
        name: 'Legacy specialty',
        nameLower: 'legacy specialty',
        nameAr: 'تخصص قديم',
        description: '',
        descriptionAr: '',
        iconName: 'medical',
        imageUrl: '',
        isActive: false,
      });
    });

    const patientDb = dbFor('patient-1');
    const doctorDb = dbFor('doctor-1');
    const adminDb = dbFor('admin-1');
    await assertSucceeds(getDoc(doc(patientDb, 'specialties/active')));
    await assertSucceeds(getDoc(doc(patientDb, 'specialties/inactive')));
    await assertSucceeds(getDocs(collection(patientDb, 'specialties')));
    await assertSucceeds(getDocs(collection(doctorDb, 'specialties')));
    await assertSucceeds(getDocs(collection(adminDb, 'specialties')));
    await assertFails(
      getDocs(collection(testEnvironment.unauthenticatedContext().firestore(), 'specialties')),
    );

    for (const db of [patientDb, doctorDb]) {
      await assertFails(setDoc(doc(db, 'specialties/forged'), {
        name: 'Forged specialty',
        nameLower: 'forged specialty',
        nameAr: 'تخصص مزيف',
        description: '',
        descriptionAr: '',
        iconName: 'medical',
        imageUrl: '',
        isActive: true,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      }));
      await assertFails(updateDoc(doc(db, 'specialties/active'), {
        name: 'Cardiology',
        nameLower: 'cardiology',
        nameAr: 'أمراض القلب',
        description: '',
        descriptionAr: '',
        iconName: 'heart',
        imageUrl: '',
        isActive: true,
        updatedAt: serverTimestamp(),
      }));
      await assertFails(deleteDoc(doc(db, 'specialties/active')));
    }

    await assertSucceeds(setDoc(doc(adminDb, 'specialties/created-by-admin'), {
      name: 'Neurology',
      nameLower: 'neurology',
      nameAr: 'الأعصاب',
      description: '',
      descriptionAr: '',
      iconName: 'neurology',
      imageUrl: '',
      isActive: true,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(doc(adminDb, 'specialties/created-by-admin'), {
      isActive: false,
      updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(setDoc(doc(adminDb, 'specialties/invalid'), {
      name: 'Invalid',
      isActive: true,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(deleteDoc(doc(adminDb, 'specialties/created-by-admin')));
});

test('admins have full access to unmatched Firestore collections', async () => {
  await seed();
  const adminReference = doc(
    dbFor('admin-1'),
    'unmatched_collection/admin-record',
  );
  const patientReference = doc(
    dbFor('patient-1'),
    'unmatched_collection/admin-record',
  );

  await assertSucceeds(setDoc(adminReference, { value: 'admin-write' }));
  assert.equal((await assertSucceeds(getDoc(adminReference))).data()?.value, 'admin-write');
  await assertSucceeds(updateDoc(adminReference, { value: 'admin-update' }));

  await assertFails(getDoc(patientReference));
  await assertFails(setDoc(patientReference, { value: 'patient-write' }));
  await assertFails(updateDoc(patientReference, { value: 'patient-update' }));
  await assertFails(deleteDoc(patientReference));

  await assertSucceeds(deleteDoc(adminReference));
});

test('admins can reject a legacy pending application without state metadata', async () => {
  await seed();
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), 'doctor_applications/legacy-pending'),
      {
        applicationId: 'legacy-pending',
        applicantUid: 'patient-1',
        applicationStatus: 'pending',
      },
    );
  });

  const adminDb = dbFor('admin-1');
  const rejection = writeBatch(adminDb);
  rejection.update(doc(adminDb, 'doctor_applications/legacy-pending'), {
    applicationStatus: 'rejected',
    reviewedBy: 'admin-1',
    reviewedAt: serverTimestamp(),
    rejectionReason: 'Please update your credentials.',
    updatedAt: serverTimestamp(),
  });
  rejection.set(doc(adminDb, 'doctor_application_audit/legacy-reject'), {
    actorUid: 'admin-1',
    action: 'application_reject',
    applicationId: 'legacy-pending',
    applicantUid: 'patient-1',
    operationId: 'legacy-reject',
    reason: 'Please update your credentials.',
    schemaVersion: 1,
    createdAt: serverTimestamp(),
  });

  await assertSucceeds(rejection.commit());
});

test('users cannot self-assign admin or change an existing role', async () => {
  await seed();
  const patientDb = dbFor('patient-1', 'patient@example.com');
  const newPatientDb = dbFor('new-patient', 'new-patient@example.com');
  const newDoctorDb = dbFor('new-doctor', 'new-doctor@example.com');

  await assertSucceeds(setDoc(doc(newPatientDb, 'users/new-patient'), {
    uid: 'new-patient',
    role: 'patient',
    email: 'new-patient@example.com',
  }));
  await assertSucceeds(setDoc(doc(newDoctorDb, 'users/new-doctor'), {
    uid: 'new-doctor',
    role: 'doctor',
    email: 'new-doctor@example.com',
  }));
  await assertFails(setDoc(doc(newPatientDb, 'users/forged-admin'), {
    uid: 'forged-admin',
    role: 'admin',
    email: 'new-patient@example.com',
  }));
  await assertFails(updateDoc(doc(patientDb, 'users/patient-1'), {
    role: 'admin',
    fullName: 'Patient One',
    phoneNumber: '100',
    email: 'PATIENT@example.com',
    updatedAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(doc(patientDb, 'users/patient-1'), {
    role: 'doctor',
    fullName: 'Patient One',
    phoneNumber: '100',
    email: 'PATIENT@example.com',
    updatedAt: serverTimestamp(),
  }));
});

test('allows legacy missing administrativeStatus but explicit-active discovery omits it', async () => {
  await seed({ includeAdministrativeStatus: false });
  const db = dbFor('patient-1');

  await assertSucceeds(bookingBatch(db).commit());
  await assertSucceeds(getDoc(doc(db, 'doctors/doctor-1')));

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), 'doctors/doctor-2'),
      doctorRecord({ uid: 'doctor-2' }),
    );
    await setDoc(doc(context.firestore(), 'users/doctor-2'), {
      uid: 'doctor-2',
      role: 'doctor',
      doctorProfileId: 'doctor-2',
    });
  });
  const catalog = await assertSucceeds(
    getDocs(query(
      collection(db, 'doctors'),
      where('approvalStatus', '==', 'approved'),
      where('administrativeStatus', '==', 'active'),
    )),
  );
  assert.deepEqual(catalog.docs.map((document) => document.id), ['doctor-2']);
});

test('rejects direct reads and bookings for inconsistent doctor identity links', async () => {
  await seed({ doctorProfileId: 'different-profile' });
  const db = dbFor('patient-1');
  await assertFails(getDoc(doc(db, 'doctors/doctor-1')));
  await assertFails(bookingBatch(db).commit());
});

test('allows a doctor to check only their own missing or legacy UID profile', async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/doctor-1'), {
      uid: 'doctor-1',
      role: 'doctor',
      doctorProfileId: 'profile-1',
    });
    await setDoc(doc(db, 'doctors/profile-1'), doctorRecord({
      uid: 'doctor-1',
    }));
    await setDoc(doc(db, 'users/doctor-2'), {
      uid: 'doctor-2',
      role: 'doctor',
      doctorProfileId: 'profile-2',
    });
    await setDoc(doc(db, 'doctors/doctor-2'), doctorRecord({
      uid: 'another-doctor',
    }));
  });

  const doctorDb = dbFor('doctor-1');
  const missingLegacy = await assertSucceeds(
    getDoc(doc(doctorDb, 'doctors/doctor-1')),
  );
  assert.equal(missingLegacy.exists(), false);

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'doctors/doctor-1'), {
      ...doctorRecord({
        approvalStatus: 'approved',
        administrativeStatus: 'active',
        uid: '',
      }),
      fullName: 'Legacy doctor profile',
    });
    await setDoc(doc(db, 'doctors/doctor-1/availabilitySlots/slot-1'), {
      startAt: FUTURE_APPOINTMENT_AT,
      endAt: FUTURE_APPOINTMENT_END_AT,
      isAvailable: true,
    });
  });
  const legacy = await assertSucceeds(
    getDoc(doc(doctorDb, 'doctors/doctor-1')),
  );
  assert.equal(legacy.data()?.fullName, 'Legacy doctor profile');
  await assertFails(
    getDocs(collection(doctorDb, 'doctors/doctor-1/availabilitySlots')),
  );

  await assertFails(getDoc(doc(dbFor('doctor-2'), 'doctors/doctor-2')));
});

test('allows only eligible doctor discovery queries and availability reads', async () => {
  await seed();
  const patientDb = dbFor('patient-1');
  const doctorQuery = query(
    collection(patientDb, 'doctors'),
    where('approvalStatus', '==', 'approved'),
    where('administrativeStatus', '==', 'active'),
  );
  const catalog = await assertSucceeds(getDocs(doctorQuery));
  assert.deepEqual(catalog.docs.map((document) => document.id), ['doctor-1']);
  await assertSucceeds(
    getDocs(collection(patientDb, 'doctors/doctor-1/availabilitySlots')),
  );
  await assertSucceeds(
    getDoc(doc(patientDb, 'doctors/doctor-1/availabilitySlots/slot-1')),
  );

  const doctorDb = dbFor('doctor-1');
  await assertSucceeds(
    getDocs(collection(doctorDb, 'doctors/doctor-1/availabilitySlots')),
  );
});

test('does not expose suspended availability, while retaining the cancellation read exception', async () => {
  await seed({
    approvalStatus: 'approved',
    administrativeStatus: 'suspended',
  });
  const patientDb = dbFor('patient-1');
  await assertFails(
    getDocs(collection(patientDb, 'doctors/doctor-1/availabilitySlots')),
  );
  await assertFails(
    getDoc(doc(patientDb, 'doctors/doctor-1/availabilitySlots/slot-1')),
  );

  await seedAppointment();
  await assertSucceeds(
    getDoc(doc(patientDb, 'doctors/doctor-1/availabilitySlots/slot-1')),
  );
});

test('doctor owners cannot read availability when pending, rejected, or suspended', async () => {
  for (const status of [
    { approvalStatus: 'pending', administrativeStatus: 'active' },
    { approvalStatus: 'rejected', administrativeStatus: 'active' },
    { approvalStatus: 'approved', administrativeStatus: 'suspended' },
  ]) {
    await seed(status);
    await assertFails(
      getDocs(collection(
        dbFor('doctor-1'),
        'doctors/doctor-1/availabilitySlots',
      )),
    );
  }
});

test('keeps patient appointment reads and cancellation intact for suspended doctors', async () => {
  await seed({ approvalStatus: 'approved', administrativeStatus: 'suspended' });
  await seedAppointment();
  const patientDb = dbFor('patient-1');
  await assertSucceeds(getDoc(doc(patientDb, 'appointments/appointment-1')));
  await assertSucceeds(
    getDoc(doc(patientDb, 'doctors/doctor-1/availabilitySlots/slot-1')),
  );

  const batch = writeBatch(patientDb);
  batch.update(doc(patientDb, 'appointments/appointment-1'), {
    status: 'cancelled',
    cancelledAt: serverTimestamp(),
  });
  batch.update(doc(
    patientDb,
    'doctors/doctor-1/availabilitySlots/slot-1',
  ), {
    isAvailable: true,
    appointmentId: deleteField(),
    reservedAt: deleteField(),
  });
  await assertSucceeds(batch.commit());

  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const slot = await getDoc(
      doc(context.firestore(), 'doctors/doctor-1/availabilitySlots/slot-1'),
    );
    assert.equal(slot.data()?.isAvailable, true);
    assert.equal(Object.hasOwn(slot.data() ?? {}, 'appointmentId'), false);
  });
});

test('does not release a slot linked to another patient appointment', async () => {
  await seed();
  await seedAppointment({
    appointmentId: 'other-appointment',
    patientId: 'other-patient',
  });
  const patientDb = dbFor('patient-1');
  await assertFails(updateDoc(
    doc(patientDb, 'doctors/doctor-1/availabilitySlots/slot-1'),
    {
      isAvailable: true,
      appointmentId: deleteField(),
      reservedAt: deleteField(),
    },
  ));
});

test('only active approved doctor owners can complete ended appointments', async () => {
  const pastStart = Timestamp.fromDate(new Date(Date.now() - 3 * 60 * 60 * 1000));
  const pastEnd = Timestamp.fromDate(new Date(Date.now() - 2 * 60 * 60 * 1000));
  const statuses = [
    { approvalStatus: 'approved', administrativeStatus: 'active', allowed: true },
    { approvalStatus: 'approved', administrativeStatus: 'suspended', allowed: false },
    { approvalStatus: 'pending', administrativeStatus: 'active', allowed: false },
    { approvalStatus: 'rejected', administrativeStatus: 'active', allowed: false },
  ];

  for (const [index, status] of statuses.entries()) {
    await seed(status);
    await seedAppointment({
      appointmentId: `completion-${index}`,
      appointmentAt: pastStart,
      appointmentEndAt: pastEnd,
    });
    const result = updateDoc(
      doc(dbFor('doctor-1'), `appointments/completion-${index}`),
      { status: 'completed', completedAt: serverTimestamp() },
    );
    if (status.allowed) {
      await assertSucceeds(result);
    } else {
      await assertFails(result);
    }
  }
});

test('linked doctors read appointments by profile ID, not Firebase UID', async () => {
  await testEnvironment.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/doctor-1'), {
      uid: 'doctor-1',
      role: 'doctor',
      doctorProfileId: 'profile-1',
    });
    await setDoc(doc(db, 'doctors/profile-1'), doctorRecord({
      uid: 'doctor-1',
    }));
    await setDoc(doc(db, 'appointments/profile-appointment'), {
      doctorId: 'profile-1',
      status: 'confirmed',
    });
  });

  const db = dbFor('doctor-1');
  await assertSucceeds(
    getDocs(query(
      collection(db, 'appointments'),
      where('doctorId', '==', 'profile-1'),
    )),
  );
  await assertFails(
    getDocs(query(
      collection(db, 'appointments'),
      where('doctorId', '==', 'doctor-1'),
    )),
  );
});

test('prevents clients from changing doctor statuses, UID ownership, role, or profile link', async () => {
  await seed();
  const doctorDb = dbFor('doctor-1');
  await assertFails(updateDoc(doc(doctorDb, 'doctors/doctor-1'), {
    approvalStatus: 'rejected',
  }));
  await assertFails(updateDoc(doc(doctorDb, 'doctors/doctor-1'), {
    administrativeStatus: 'suspended',
  }));
  await assertFails(updateDoc(doc(doctorDb, 'doctors/doctor-1'), {
    uid: 'another-doctor',
  }));
  await assertFails(updateDoc(doc(doctorDb, 'users/doctor-1'), {
    role: 'patient',
  }));
  await assertFails(updateDoc(doc(doctorDb, 'users/doctor-1'), {
    doctorProfileId: 'another-profile',
  }));
});

test('keeps approved suspended doctor profile-image updates separate from operational access', async () => {
  await seed({
    approvalStatus: 'approved',
    administrativeStatus: 'suspended',
  });
  await assertSucceeds(
    updateDoc(doc(dbFor('doctor-1'), 'doctors/doctor-1'), {
      profileImageUrl: 'https://example.test/doctor.png',
      updatedAt: serverTimestamp(),
    }),
  );
});

test('admins can write audit records while non-admin clients cannot', async () => {
  await seed();
  const event = {
    actorUid: 'admin-1',
    action: 'approve',
    targetDoctorUid: 'doctor-1',
    operationId: 'forged-event',
  };
  await assertSucceeds(setDoc(
    doc(dbFor('admin-1'), 'doctor_admin_audit/forged-event'),
    event,
  ));
  await assertFails(setDoc(
    doc(dbFor('patient-1'), 'doctor_admin_audit/forged-event'),
    event,
  ));
});
