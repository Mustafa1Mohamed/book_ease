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

## Patient Home Firestore contract

The patient home reads the authenticated patient's document from `users/{uid}`
and expects `fullName`, `role`, and optionally `profileImageUrl`. It reads
specialties from `specialties` (`name`, optional `imageUrl`, `iconName`, and
`isActive` boolean), featured doctors from `doctors` (`isFeatured` boolean,
`fullName` or `name`, optional `specialtyId`, `specialtyName`,
`profileImageUrl`, numeric `rating` and `consultationFee`, and boolean
`isAvailable`), and appointments from `appointments` (`patientId`, `doctorId`,
`appointmentDate`, optional `appointmentTime`, `specialtyId`, `doctorName`,
`specialtyName`, `doctorImageUrl`, and `status`). `appointmentDate` should be a
Firestore timestamp or ISO-8601 date; `appointmentTime` may be a 24-hour or
AM/PM time.

No sample records are inserted by the app. Missing specialties, featured
doctors, or upcoming appointments are shown as empty states. Appointment reads
are filtered using the current Firebase Authentication UID.

Firestore security rules must independently restrict profile reads to the
authenticated user, allow only the intended authenticated reads for doctor and
specialty data, and restrict appointment reads to documents whose `patientId`
matches `request.auth.uid`. The client-side query is not a security boundary.
This project does not currently configure a Firestore rules file; deploy rules
that enforce these conditions before using patient data in production.
