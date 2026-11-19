import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/featured_doctor.dart';

sealed class DoctorDetailsState extends Equatable {
  const DoctorDetailsState();

  @override
  List<Object?> get props => [];
}

class DoctorDetailsInitial extends DoctorDetailsState {
  const DoctorDetailsInitial();
}

class DoctorDetailsLoading extends DoctorDetailsState {
  const DoctorDetailsLoading();
}

class DoctorDetailsLoaded extends DoctorDetailsState {
  const DoctorDetailsLoaded(this.doctor);

  final FeaturedDoctor doctor;

  @override
  List<Object?> get props => [doctor];
}

class DoctorDetailsNotFound extends DoctorDetailsState {
  const DoctorDetailsNotFound();
}

class DoctorDetailsFailure extends DoctorDetailsState {
  const DoctorDetailsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
