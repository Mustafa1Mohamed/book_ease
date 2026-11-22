const { getAuth } = require('firebase-admin/auth');
const { initializeApp, getApps } = require('firebase-admin/app');
const { logger } = require('firebase-functions');
const { onUserCreated } = require('firebase-functions/v2/identity');

const { withSupabaseAuthenticatedRole } = require('./src/custom-claims');

if (getApps().length === 0) {
  initializeApp();
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
