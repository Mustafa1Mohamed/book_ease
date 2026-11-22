# Supabase Profile Image Storage Setup

This setup connects Firebase Auth with Supabase Storage. Do not add a Supabase
service-role key to the Flutter application.

The Supabase `role: "authenticated"` claim is only the Postgres role used for
Supabase RLS. BookEase application roles (`patient`, `doctor`, `admin`) continue
to come from Firestore and are not changed by this claim.

## 1. Firebase Functions backend

The project had no existing `functions/` directory, Functions codebase, or
Firebase Admin initialization. The new `functions/` codebase uses Node.js 22,
Firebase Admin SDK Application Default Credentials, and the 2nd-generation
Firebase Auth `onUserCreated` trigger. It reads a new user's current custom
claims, preserves them, and sets only `role: "authenticated"`. The operation is
idempotent and retries failed event deliveries. It does not modify Firestore
application roles.

Firebase documents 2nd-generation Authentication creation triggers as **Preview**.
The trigger is asynchronous: it runs after account creation, not before the
first ID token is issued. Do not assume the initial token has the claim.

Cloud Functions deployment requires the Firebase project to use the **Blaze**
pay-as-you-go plan. The functions have Firebase's no-cost invocation allowance,
but associated Cloud Run, Eventarc, build, and artifact services may incur
charges. Firebase may prompt to enable the required Google Cloud APIs on first
deployment. Ensure the function's runtime service account has the Firebase
Authentication Admin permissions required to read user records and set custom
claims.

### One-time migration for existing users

The migration script lives at `functions/scripts/migrate-auth-claims.js`. It
lists users using Firebase Auth pagination, fetches each current UserRecord,
preserves its other custom claims, and assigns the Supabase role claim. It is
not run by Flutter startup or by function deployment.

From PowerShell at the repository root, authenticate using Application Default
Credentials (ADC) with an identity granted Firebase Authentication Admin
permissions:

```powershell
gcloud auth application-default login
gcloud auth application-default set-quota-project book-ease-f0346
Set-Location functions
npm ci
npm run migrate:claims
```

Alternatively, use a service-account JSON file stored outside this repository
and set `GOOGLE_APPLICATION_CREDENTIALS` in the same PowerShell session before
running the script:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\secure\book-ease-admin.json'
Set-Location functions
npm ci
npm run migrate:claims
```

Use a least-privilege service account with Firebase Authentication Admin
permissions. Never commit or copy the service-account file into the repository.
The script reports processed, updated, and failed counts and logs only user UIDs
and error codes, never credentials or tokens. A nonzero exit code indicates
failures that need review.

### Future users and deployment

After reviewing and testing the function, deploy it manually from the repository
root. Do not deploy it as part of the migration or Flutter build:

```powershell
firebase deploy --project book-ease-f0346 --only functions:assignSupabaseAuthenticatedRole
```

The `onUserCreated` trigger handles email/password and first-time federated
sign-ins, including Google. It reads the current Admin SDK UserRecord before
merging the claim. The Flutter email and Google registration flows force-refresh
the Firebase ID token until this claim appears (up to 12 attempts, one second
apart). If that times out, the Firebase account and profile remain created; sign
in again after the function has completed.

An alternative is a blocking `beforeUserCreated` (and, if needed,
`beforeUserSignedIn`) function, which can add custom claims synchronously before
Firebase issues an ID token. Blocking functions require upgrading to **Firebase
Authentication with Identity Platform**. This project is not automatically
upgraded, and the blocking option is not enabled by these changes.

## 2. Flutter token refresh

The app never sets Firebase custom claims. After email or Google sign-in it
forces an ID token refresh; for a newly created account it additionally waits
until `getIdTokenResult()` confirms `role == "authenticated"`. The Firebase
token is never logged.

After running the one-time migration, existing users must sign out and sign in
again, or force-refresh their token while signed in:

```dart
await FirebaseAuth.instance.currentUser?.getIdToken(true);
```

The app's sign-in flows already force-refresh the token. If the role is still
missing in the app diagnostics, confirm migration/function completion and sign
out/in once more.

To verify a user's claim from a trusted local environment without printing the
ID token or other custom claims, authenticate with ADC as above, then run:

```powershell
Set-Location functions
npm run verify:claim -- <firebase-uid>
```

The script prints only whether that UID's `role` claim is
`authenticated` (never the token or the rest of the custom claims).

## 3. Configure Firebase as a Supabase third-party auth provider

In the Supabase Dashboard:

1. Open **Authentication > Providers** or **Authentication > Third-party Auth**
   for the project.
2. Add Firebase.
3. Enter `book-ease-f0346`, matching the project ID in `firebase.json` and
   `lib/firebase_options.dart`.
4. Confirm that Supabase accepts Firebase ID tokens. The Flutter app passes the
   current Firebase ID token using the supported `accessToken` option.
5. Ensure every Firebase user has the server-assigned custom claim
   `role: "authenticated"`. Firebase ID tokens do not include this claim by
   default; assign it through a trusted Firebase Admin SDK/Cloud Function, never
   from the client. Existing users need the claim assigned and a refreshed ID
   token before storage access works.
6. Do not enable a public Supabase sign-in or use a service-role key in the app.

The Firebase ID token subject (`sub`) must contain the Firebase authenticated
user UID. Supabase does not infer ownership from a client-provided UID.

## 4. Create the bucket

In **Storage**, create a bucket with:

- ID: `profile-images`
- Name: `profile-images`
- Public: enabled
- File size limit: `5 MB`
- Allowed MIME types: `image/jpeg`

Or run this SQL in the Supabase SQL Editor:

```sql
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'profile-images',
  'profile-images',
  true,
  5242880,
  array['image/jpeg']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;
```

## 5. Storage policies

Run the following SQL in the Supabase SQL Editor. These policies require the
configured Firebase third-party JWT and restrict all writes to
`users/<Firebase UID>/...`.

```sql
drop policy if exists "Users can upload their own profile images"
  on storage.objects;
drop policy if exists "Users can replace their own profile images"
  on storage.objects;
drop policy if exists "Users can read their own profile images"
  on storage.objects;
drop policy if exists "Users can delete their own profile images"
  on storage.objects;

create policy "Users can read their own profile images"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = (auth.jwt()->>'sub')
);

create policy "Users can upload their own profile images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = (auth.jwt()->>'sub')
);

create policy "Users can replace their own profile images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = (auth.jwt()->>'sub')
)
with check (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = (auth.jwt()->>'sub')
);

create policy "Users can delete their own profile images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'profile-images'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = (auth.jwt()->>'sub')
);
```

The app never calls object deletion. The delete policy is included as a narrow,
owner-only safety policy. Do not add a public insert, update, or delete policy.
The owner-only `SELECT` policy is required because this upload uses `upsert:
true`; Supabase requires `SELECT` and `UPDATE` in addition to `INSERT` when
overwriting an existing object.

The public bucket permits unauthenticated public reads. Profile URLs are stored
in Firestore and may be viewed through those public URLs.

To inspect the policies and bucket currently deployed to the project, run this
read-only SQL in the Supabase SQL Editor:

```sql
select policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where schemaname = 'storage'
  and tablename = 'objects'
order by policyname;

select id, public, file_size_limit, allowed_mime_types
from storage.buckets
where id = 'profile-images';
```

## 6. Firebase project configuration

No Firebase Storage bucket is used for profile images. Firebase Auth must remain
configured, and the app obtains the current Firebase UID and ID token from
`FirebaseAuth.instance`.

## 7. Manual verification

1. Set the Firebase project ID in Supabase third-party auth.
2. Create `profile-images`.
3. Apply the SQL policies.
4. Sign in to BookEase.
5. Upload a photo.
6. Confirm that the object is stored at
   `users/<firebaseUid>/profile.jpg`.
7. Confirm that `users/<firebaseUid>/profileImageUrl` is updated.
8. Confirm that a doctor also has `profileImageUrl` synchronized on the owned
   `doctors/{doctorId}` document.
