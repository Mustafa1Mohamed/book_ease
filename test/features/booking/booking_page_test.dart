import 'package:book_ease/features/booking/domain/entities/appointment_slot.dart';
import 'package:book_ease/features/booking/domain/entities/booking_confirmation.dart';
import 'package:book_ease/features/booking/domain/repositories/booking_repository.dart';
import 'package:book_ease/features/booking/domain/usecases/book_appointment.dart';
import 'package:book_ease/features/booking/domain/usecases/get_available_dates.dart';
import 'package:book_ease/features/booking/domain/usecases/get_available_slots.dart';
import 'package:book_ease/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:book_ease/features/booking/presentation/pages/booking_page.dart';
import 'package:book_ease/features/doctors/domain/repositories/doctor_repository.dart';
import 'package:book_ease/features/doctors/domain/usecases/get_doctor_details.dart';
import 'package:book_ease/features/home/domain/entities/featured_doctor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _DoctorRepository implements DoctorRepository {
  @override
  Future<FeaturedDoctor?> getDoctor(String doctorId) async => _doctor;
}

class _BookingRepository implements BookingRepository {
  final date = DateTime(2030, 7, 18);
  final slot = AppointmentSlot(
    id: 'published-slot',
    startAt: DateTime(2030, 7, 18, 9),
    endAt: DateTime(2030, 7, 18, 9, 30),
  );

  @override
  Future<List<DateTime>> getAvailableDates(String doctorId) async => [date];

  @override
  Future<List<AppointmentSlot>> getAvailableSlots(
    String doctorId,
    DateTime date,
  ) async => [slot];

  @override
  Future<BookingConfirmation> bookAppointment({
    required String doctorId,
    required String slotId,
  }) async => BookingConfirmation(
    appointmentId: 'appointment-1',
    doctorName: _doctor.fullName,
    startAt: slot.startAt,
    endAt: slot.endAt,
  );
}

const _doctor = FeaturedDoctor(
  id: 'doctor-1',
  fullName: 'Dr Morgan Lee',
  specialtyId: 'cardiology',
  specialtyName: 'Cardiology',
  imageUrl: '',
  rating: null,
  consultationFee: 80,
  isAvailable: true,
);

void main() {
  testWidgets('booking screen shows only the published date and time', (
    tester,
  ) async {
    final bookingRepository = _BookingRepository();
    final cubit = BookingCubit(
      GetDoctorDetails(_DoctorRepository()),
      GetAvailableDates(bookingRepository),
      GetAvailableSlots(bookingRepository),
      BookAppointment(bookingRepository),
    )..load('doctor-1');
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const Scaffold(body: BookingPage(doctorId: 'doctor-1')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dr Morgan Lee'), findsOneWidget);
    expect(find.textContaining('9:00'), findsOneWidget);
    expect(find.text('Confirm booking'), findsOneWidget);
  });
}
