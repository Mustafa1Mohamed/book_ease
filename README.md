# book_ease

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Patient Firestore contract

The patient home reads the authenticated patient's document from `users/{uid}`
and expects `fullName`, `role`, and optionally `profileImageUrl`. It reads
specialties from `specialties` (`name`, optional `imageUrl`, `iconName`, and
`isActive` boolean), featured doctors from `doctors` (`isFeatured` boolean,
`fullName` or `name`, optional `specialtyId`, `specialtyName`,
`profileImageUrl`, numeric `rating` and `consultationFee`, and boolean
`isAvailable`), and appointments from `appointments` (`patientId`, `doctorId`,
`appointmentAt`, `appointmentEndAt`, `appointmentDate`, `appointmentTime`,
`specialtyId`, `doctorName`, `specialtyName`, `doctorImageUrl`, and `status`).
New bookings use Firestore timestamps in `appointmentAt` and
`appointmentEndAt`; the legacy `appointmentDate` and `appointmentTime` fields
remain for compatibility. Older records may use a Firestore timestamp or
ISO-8601 date in `appointmentDate`, with an optional 24-hour or AM/PM
`appointmentTime`.

No sample records are inserted by the app. Missing specialties, featured
doctors, or upcoming appointments are shown as empty states. Appointment reads
are filtered using the current Firebase Authentication UID.

`doctors/{doctorId}` may include optional `biography`, `qualifications`
(string list), `yearsExperience`, `languages` (string list), `clinicName`,
`clinicAddress`, `consultationDurationMinutes`, and `reviewCount` fields to
populate doctor details. Missing optional fields are not fabricated.

Doctors or trusted backend code must publish real appointment slots at
`doctors/{doctorId}/availabilitySlots/{slotId}`. Each slot contains Firestore
timestamps `startAt` and `endAt`, plus `isAvailable: true`. Patient clients can
read published slots but cannot create or edit them. A booking transaction
marks the chosen slot unavailable and creates the patient appointment together;
the deployed Firestore rules require both writes to match.

## My Appointments

The appointments screen queries only `appointments` documents whose
`patientId` matches the authenticated Firebase UID. It groups the existing
appointment records into Upcoming, Completed, and Cancelled; it does not add a
new appointment collection or schema. Doctor and specialty documents are read
only when optional appointment-card details are missing.

Patients can cancel `confirmed`, `pending`, `scheduled`, or `booked`
appointments before their scheduled start time. The cancellation policy is
centralized in `AppointmentCancellationPolicy` and defaults to no minimum
notice beyond cancelling before the start time. Keep that policy aligned with
the corresponding time condition in `firestore.rules` if it is changed. The
cancellation transaction updates the appointment status and releases its
availability slot only when the slot still names that exact appointment.
Missing slots or slots linked to a different appointment are left untouched.
The rules permit patient-owned cancellation and the matching slot release;
they must be deployed through the normal reviewed rules release process before
this behavior is available in production.

## Authentication roles and provisioning

The authentication layer resolves `patient`, `doctor`, and `admin` to a
centralized role enum. Missing role data safely falls back to `patient` for
legacy patient accounts; the auth repository upgrades only still-missing role
fields to `patient` in a transaction, and an unrecognized role is restricted.
Public email and Google registration create patients only. Google sign-in
preserves an existing Firestore role and never infers a privileged role from
Google profile data.

Doctor accounts must be created or linked by trusted server-side tooling, such
as an Admin SDK Cloud Function or a controlled administrative provisioning
process. Set `users/{uid}.role` to `doctor`, link exactly one
`doctors/{doctorId}` document with `uid: {uid}`, and set its
`approvalStatus` to `pending`, `approved`, or `rejected`. `doctorProfileId` on
the user document may be used when the profile ID is not discoverable by UID.
Missing approval status is treated as pending; missing or ambiguous doctor
profiles do not grant dashboard access. Existing doctors must be explicitly
reviewed and marked approved by a trusted operator before their dashboard is
available.

Admin accounts must likewise be provisioned by trusted server-side tooling by
setting `users/{uid}.role` to `admin`; there is no public admin registration.
The `/admin` route is currently a protected placeholder. Admin-specific
Firestore and Storage permissions must be designed and reviewed separately
before an admin dashboard performs privileged data operations. Never grant
roles by trusting client input or local state.

The router enforces role-specific destinations and blocks direct navigation
between patient, doctor, and admin areas. This is a UI authorization layer,
not a replacement for Firebase Security Rules. The rules source permits only
the non-elevating migration from a missing role to `patient`; no rules were
deployed. Doctor appointment/availability ownership checks in the rules also
require an `approved` doctor profile; the doctor can still read its own profile
to display pending/rejected status. Admin-specific Firestore and Storage
permissions must be designed and reviewed separately before the admin
dashboard performs privileged operations. Role and approval changes are
watched while the user is signed in and are re-resolved when the session is
restored.

## Doctor dashboard

Doctor dashboard appointment queries are scoped to the linked doctor document
ID; Firestore rules restrict appointment reads and updates to the linked
doctor. New bookings copy the patient's name, image URL, and phone number into
the appointment as booking-time display snapshots. The dashboard does not read
other patients' profile documents. Older appointment records without those
optional fields display a safe fallback.

New bookings copy the patient's name, image URL, and phone number into the
appointment as booking-time display snapshots. The dashboard does not read
other patients' profile documents. Older appointment records without those
optional fields display a safe fallback.

The current booking flow creates appointments directly as `confirmed`, so
there is no pending-confirmation or rejection workflow. Doctors may mark a
confirmed appointment completed only after its `appointmentEndAt`; the
transition updates only its status and `completedAt`. Doctor-side slot
creation and editing are not enabled: slot publishing remains a trusted
backend responsibility because current client rules prohibit doctors from
changing availability. Deploy the updated Firestore rules through the reviewed
release process before enabling the dashboard in production. No rules were
deployed as part of this change.

Patient profile edits update only `fullName` and `phoneNumber`; `email` and
`role` are read-only to the patient. Profile images are uploaded under
`users/{uid}/profile/`; authenticated Storage reads and writes are restricted
to the owning account. The profile stores a Firebase download URL, which is a
bearer link, so profile photos should not be treated as confidential.

`firebase.json` now points Firebase CLI to `firestore.rules` and `storage.rules`.
Deploy the rules with `firebase deploy --only firestore:rules,storage` before
using patient data in production. Review the project-specific policies before
deployment. These client/rule flows do not replace trusted backend
authorization for doctor/admin operations.

## Explore data behavior

Explore reuses the Home specialty and doctor models and reads `specialties`
and `doctors`. It filters out specialties with `isActive: false`, maps doctors
with a `fullName` or `name`, and uses optional `specialtyId`,
`specialtyName`, `profileImageUrl`, `rating`, `consultationFee`, and
`isAvailable` when present. Search and filter/sort operations run locally on
the fetched catalog; they do not issue a Firestore request for every keystroke.
Firestore does not provide arbitrary full-text search, so a larger catalog
should move to pagination and a dedicated search service/index. Booking never invents availability; the booking screen only
offers slots published under the selected doctor.
