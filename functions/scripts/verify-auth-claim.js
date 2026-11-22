const { applicationDefault, getApps, initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

const projectId = 'book-ease-f0346';
const uid = process.argv[2];

if (!uid) {
  console.error('Pass a Firebase UID: npm run verify:claim -- <uid>.');
  process.exitCode = 2;
} else {
  if (getApps().length === 0) {
    initializeApp({
      credential: applicationDefault(),
      projectId,
    });
  }

  getAuth()
    .getUser(uid)
    .then((user) => {
      const role = user.customClaims?.role;
      console.info(
        `Firebase UID ${uid}: Supabase role claim is ${
          role === 'authenticated' ? 'authenticated' : 'missing or incorrect'
        }.`,
      );
      if (role !== 'authenticated') process.exitCode = 1;
    })
    .catch((error) => {
      console.error(
        `Could not verify Firebase user; errorCode=${error.code ?? 'unknown'}.`,
      );
      process.exitCode = 1;
    });
}
