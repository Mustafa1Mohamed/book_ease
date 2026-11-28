const { getAuth } = require('firebase-admin/auth');
const { initializeApp, getApps } = require('firebase-admin/app');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { logger } = require('firebase-functions');
const { onUserCreated } = require('firebase-functions/v2/identity');
const { HttpsError, onCall } = require('firebase-functions/v2/https');

const { withSupabaseAuthenticatedRole } = require('./src/custom-claims');
const { createDoctorAdminCallable } = require('./src/doctor-admin/callable');
const {
  createDoctorAdminService,
} = require('./src/doctor-admin/doctor-admin-service');

if (getApps().length === 0) {
  initializeApp();
}

const doctorAdminService = createDoctorAdminService({
  db: getFirestore(),
  serverTimestamp: () => FieldValue.serverTimestamp(),
});
for (const action of ['approve', 'reject', 'suspend', 'restore']) {
  exports[`${action}Doctor`] = onCall(
    { region: 'us-central1' },
    createDoctorAdminCallable({
      service: doctorAdminService,
      action,
      HttpsError,
      logger,
    }),
  );
}

exports.assignSupabaseAuthenticatedRole = onUserCreated(
  {
    region: 'us-central1',
    retry: true,
  },
  async (event) => {
    const uid = event.data.uid;

    try {
      const auth = getAuth();
      const currentUser = await auth.getUser(uid);
      const currentClaims = currentUser.customClaims ?? {};
      if (currentClaims.role === 'authenticated') {
        logger.info('Supabase authentication claim already present.', { uid });
        return;
      }

      await auth.setCustomUserClaims(
        uid,
        withSupabaseAuthenticatedRole(currentClaims),
      );
      logger.info('Assigned Supabase authentication claim.', { uid });
    } catch (error) {
      logger.error('Failed to assign Supabase authentication claim.', {
        uid,
        errorCode: error.code ?? 'unknown',
      });
      throw error;
    }
  },
);
