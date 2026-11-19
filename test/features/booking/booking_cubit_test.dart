import 'package:book_ease/features/booking/domain/entities/appointment_slot.dart';
import 'package:book_ease/features/booking/domain/entities/booking_confirmation.dart';
import 'package:book_ease/features/booking/domain/errors/booking_exception.dart';
import 'package:book_ease/features/booking/domain/repositories/booking_repository.dart';
import 'package:book_ease/features/booking/domain/usecases/book_appointment.dart';
import 'package:book_ease/features/booking/domain/usecases/get_available_dates.dart';
import 'package:book_ease/features/booking/domain/usecases/get_available_slots.dart';
import 'package:book_ease/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:book_ease/features/booking/presentation/cubit/booking_state.dart';
import 'package:book_ease/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:book_ease/features/doctors/domain/usecases/get_doctor_details.dart';
import 'package:book_ease/features/home/domain/entities/featured_doctor.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDoctorRepository implements DoctorRepository {
  @override
  Future<FeaturedDoctor?> getDoctor(String doctorId) async => _doctor;
}

class _FakeBookingRepository implements BookingRepository {
  bool rejectBooking = false;
  int bookingCount = 0;
  final date = DateTime(2030, 7, 18);
  final slot = AppointmentSlot(
    id: 'slot-1',
    startAt: DateTime(2030, 7, 18, 9),
    endAt: DateTime(2030, 7, 18, 9, 30),
  );

  @override
  Future<List<DateTime>> getAvailableDates(String doctorId) async => [date];

  @override
  Future<List<AppointmentSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
  ) async => rejectBooking ? [] : [slot];

  @override
  Future<BookingConfirmation> bookAppointment({
    required String doctorId,
    required String slotId,
  }) async {
    bookingCount++;
    if (rejectBooking) {
      throw const BookingException('The slot is no longer available.');
    }
    return BookingConfirmation(
      appointmentId: 'appointment-1',
      doctorName: _doctor.fullName,
      startAt: slot.startAt,
      endAt: slot.endAt,
    );
  }
}

const _doctor = FeaturedDoctor(
  id: 'doctor-1',
  fullName: 'Dr. Morgan Lee',
  specialtyId: 'cardiology',
  specialtyName: 'Cardiology',
  imageUrl: '',
  rating: null,
  consultationFee: 80,
  isAvailable: true,
);

void main() {
  late _FakeBookingRepository repository;
  late BookingCubit cubit;

  setUp(() {
    repository = _FakeBookingRepository();
    cubit = BookingCubit(
      GetDoctorDetails(_FakeDoctorRepository()),
      GetAvailableDates(repository),
      GetAvailableSlots(repository),
      BookAppointment(repository),
    );
  });

  tearDown(() async => cubit.close());

  test('books a selected published slot and exposes confirmation', () async {
    await cubit.load('doctor-1');
    expect(cubit.state, isA<BookingReady>());
    if (cubit.state is! BookingReady) fail('Expected booking options.');
    expect((cubit.state as BookingReady).slots, [repository.slot]);

    cubit.selectSlot(repository.slot);
    await cubit.confirmBooking();

    final state = cubit.state;
    expect(state, isA<BookingReady>());
    expect(
      (state as BookingReady).confirmation?.appointmentId,
      'appointment-1',
    );
    expect(repository.bookingCount, 1);
  });

  test(
    'refreshes available times and clears selection when slot is taken',
    () async {
      await cubit.load('doctor-1');
      cubit.selectSlot(repository.slot);
      repository.rejectBooking = true;

      await cubit.confirmBooking();

      final state = cubit.state as BookingReady;
      expect(state.slots, isEmpty);
      expect(state.selectedSlotId, isNull);
      expect(state.errorMessage, 'The slot is no longer available.');
    },
  );
}
