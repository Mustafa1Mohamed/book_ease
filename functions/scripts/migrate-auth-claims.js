const { applicationDefault, getApps, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const { withSupabaseAuthenticatedRole } = require('../src/custom-claims');

const projectId = 'book-ease-f0346';

if (getApps().length === 0) {
  initializeApp({
    credential: applicationDefault(),
    projectId,
  });
}

async function migrateAuthClaims() {
  const auth = getAuth();
  const counts = { processed: 0, updated: 0, failed: 0 };
  let pageToken;

  try {
    do {
      const page = await auth.listUsers(1000, pageToken);
      for (const listedUser of page.users) {
        counts.processed++;
        try {
          const user = await auth.getUser(listedUser.uid);
          await auth.setCustomUserClaims(
            user.uid,
            withSupabaseAuthenticatedRole(user.customClaims),
          );
          counts.updated++;
          console.info(`Updated claims for Firebase user ${user.uid}.`);
        } catch (error) {
          counts.failed++;
          console.error(
            `Failed to update Firebase user ${listedUser.uid}; ` +
              `errorCode=${error.code ?? 'unknown'}.`,
          );
        }
      }
      pageToken = page.pageToken;
    } while (pageToken);
  } catch (error) {
    counts.failed++;
    console.error(
      `Could not continue listing Firebase users; ` +
        `errorCode=${error.code ?? 'unknown'}.`,
    );
  }

  console.info(
    `Firebase custom-claim migration finished: ` +
      `processed=${counts.processed} updated=${counts.updated} failed=${counts.failed}.`,
  );
  if (counts.failed > 0) process.exitCode = 1;
  return counts;
}

if (require.main === module) {
  migrateAuthClaims().catch((error) => {
    console.error(
      `Firebase custom-claim migration failed; ` +
        `errorCode=${error.code ?? 'unknown'}.`,
    );
    process.exitCode = 1;
  });
}

module.exports = { migrateAuthClaims };
