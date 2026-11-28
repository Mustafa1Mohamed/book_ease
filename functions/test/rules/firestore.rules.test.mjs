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

function dbFor(uid) {
  return testEnvironment.authenticatedContext(uid).firestore();
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
    await assertFails(
      getDocs(collection(patientDb, 'doctor_applications')),
    );
    await assertSucceeds(
      getDocs(collection(dbFor('admin-1'), 'doctor_applications')),
    );
  });

  test('application submission and review fields cannot be written by clients', async () => {
    await seed();
    const patientDb = dbFor('patient-1');
    const applicationRef = doc(patientDb, 'doctor_applications/new-application');
    await assertFails(setDoc(applicationRef, {
      applicationId: 'new-application',
      applicantUid: 'patient-1',
      applicationStatus: 'pending',
      specialtyId: 'cardiology',
    }));
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'doctor_applications/pending-app'), {
        applicationId: 'pending-app',
        applicantUid: 'patient-1',
        applicationStatus: 'pending',
        specialtyId: 'cardiology',
      });
    });

    for (const privilegedChanges of [
      { applicationStatus: 'approved' },
      { applicationStatus: 'rejected' },
      { reviewerUid: 'patient-1' },
      { doctorProfileId: 'forged-doctor' },
    ]) {
      await assertFails(updateDoc(
        doc(patientDb, 'doctor_applications/pending-app'),
        privilegedChanges,
      ));
    }
    await assertFails(updateDoc(doc(patientDb, 'users/patient-1'), {
      role: 'doctor',
    }));
    await assertFails(updateDoc(
      doc(dbFor('admin-1'), 'doctor_applications/pending-app'),
      { applicationStatus: 'approved' },
    ));
    await assertFails(setDoc(
      doc(dbFor('admin-1'), 'doctor_application_audit/forged-event'),
      { actorUid: 'admin-1' },
    ));
  });

  test('specialties are readable to app users but writable only through admin callables', async () => {
    await seed();
    await testEnvironment.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'specialties/active'), {
        name: 'Cardiology',
        isActive: true,
      });
      await setDoc(doc(db, 'specialties/inactive'), {
        name: 'Legacy specialty',
        isActive: false,
      });
    });

    const patientDb = dbFor('patient-1');
    const adminDb = dbFor('admin-1');
    await assertSucceeds(getDoc(doc(patientDb, 'specialties/active')));
    await assertSucceeds(getDoc(doc(patientDb, 'specialties/inactive')));
    await assertSucceeds(getDocs(collection(patientDb, 'specialties')));
    await assertSucceeds(getDocs(collection(adminDb, 'specialties')));
    await assertFails(
      getDocs(collection(testEnvironment.unauthenticatedContext().firestore(), 'specialties')),
    );

    for (const db of [patientDb, adminDb]) {
      await assertFails(setDoc(doc(db, 'specialties/forged'), {
        name: 'Forged specialty',
        isActive: true,
      }));
      await assertFails(updateDoc(doc(db, 'specialties/inactive'), {
        isActive: true,
      }));
      await assertFails(deleteDoc(doc(db, 'specialties/inactive')));
    }
  });
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

test('prevents clients from writing audit records while allowing admin reads', async () => {
  await seed();
  const event = {
    actorUid: 'admin-1',
    action: 'approve',
    targetDoctorUid: 'doctor-1',
    operationId: 'forged-event',
  };
  await assertFails(setDoc(
    doc(dbFor('admin-1'), 'doctor_admin_audit/forged-event'),
    event,
  ));
  await assertFails(setDoc(
    doc(dbFor('patient-1'), 'doctor_admin_audit/forged-event'),
    event,
  ));
});
