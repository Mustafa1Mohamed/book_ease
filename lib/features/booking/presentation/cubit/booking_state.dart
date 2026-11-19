import 'package:equatable/equatable.dart';

import '../../../booking/domain/entities/appointment_slot.dart';
import '../../../booking/domain/entities/booking_confirmation.dart';
import '../../../home/domain/entities/featured_doctor.dart';

sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingFailure extends BookingState {
  const BookingFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class BookingReady extends BookingState {
  const BookingReady({
    required this.doctor,
    required this.availableDates,
    required this.slots,
    this.selectedDate,
    this.selectedSlotId,
    this.isLoadingSlots = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.confirmation,
  });

  final FeaturedDoctor doctor;
  final List<DateTime> availableDates;
  final List<AppointmentSlot> slots;
  final DateTime? selectedDate;
  final String? selectedSlotId;
  final bool isLoadingSlots;
  final bool isSubmitting;
  final String? errorMessage;
  final BookingConfirmation? confirmation;

  bool get isConfirmed => confirmation != null;

  BookingReady copyWith({
    List<DateTime>? availableDates,
    List<AppointmentSlot>? slots,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? selectedSlotId,
    bool clearSelectedSlot = false,
    bool? isLoadingSlots,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    BookingConfirmation? confirmation,
  }) {
    return BookingReady(
      doctor: doctor,
      availableDates: availableDates ?? this.availableDates,
      slots: slots ?? this.slots,
      selectedDate: clearSelectedDate
          ? null
          : selectedDate ?? this.selectedDate,
      selectedSlotId: clearSelectedSlot
          ? null
          : selectedSlotId ?? this.selectedSlotId,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      confirmation: confirmation ?? this.confirmation,
    );
  }

  @override
  List<Object?> get props => [
    doctor,
    availableDates,
    slots,
    selectedDate,
    selectedSlotId,
    isLoadingSlots,
    isSubmitting,
    errorMessage,
    confirmation,
  ];
}
