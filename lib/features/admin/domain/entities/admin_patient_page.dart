import 'package:equatable/equatable.dart';

import 'admin_patient.dart';

class AdminPatientCursor extends Equatable {
  const AdminPatientCursor({
    required this.documentId,
    this.sortField,
    this.sortValue,
  });

  final String documentId;
  final String? sortField;
  final String? sortValue;

  @override
  List<Object?> get props => [documentId, sortField, sortValue];
}

class AdminPatientPage extends Equatable {
  const AdminPatientPage({
    required this.patients,
    required this.hasMore,
    this.nextCursor,
  });

  final List<AdminPatient> patients;
  final bool hasMore;
  final AdminPatientCursor? nextCursor;

  @override
  List<Object?> get props => [patients, hasMore, nextCursor];
}
