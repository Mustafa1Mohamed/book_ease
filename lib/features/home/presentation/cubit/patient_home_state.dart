import 'package:equatable/equatable.dart';

import '../../domain/entities/patient_home_data.dart';

sealed class PatientHomeState extends Equatable {
  const PatientHomeState();

  @override
  List<Object?> get props => [];
}

class PatientHomeInitial extends PatientHomeState {
  const PatientHomeInitial();
}

class PatientHomeLoading extends PatientHomeState {
  const PatientHomeLoading();
}

class PatientHomeLoaded extends PatientHomeState {
  const PatientHomeLoaded(
    this.data, {
    this.isRefreshing = false,
    this.refreshError,
  });

  final PatientHomeData data;
  final bool isRefreshing;
  final String? refreshError;

  @override
  List<Object?> get props => [data, isRefreshing, refreshError];
}

class PatientHomeFailure extends PatientHomeState {
  const PatientHomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
