import 'package:book_ease/features/doctor_dashboard/domain/entities/doctor_dashboard_data.dart';
import 'package:book_ease/features/doctor_dashboard/domain/repositories/doctor_dashboard_repository.dart';
import 'package:book_ease/features/doctor_dashboard/domain/usecases/get_doctor_dashboard.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_dashboard_cubit.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/cubit/doctor_dashboard_state.dart';
import 'package:book_ease/features/doctor_dashboard/presentation/widgets/doctor_dashboard_content.dart';
import 'package:book_ease/features/home/domain/entities/featured_doctor.dart';
import 'package:book_ease/features/my_appointments/domain/entities/my_appointment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _EmptyDoctorDashboardRepository implements DoctorDashboardRepository {
  @override
  Future<void> completeAppointment(String appointmentId) async {}

  @override
  Future<MyAppointment?> getAppointment(String appointmentId) async => null;

  @override
  Future<DoctorDashboardData> getDashboard() async => const DoctorDashboardData(
    doctor: FeaturedDoctor(
      id: 'doctor-1',
      fullName: 'Dr Morgan Lee',
      specialtyId: 'cardiology',
      specialtyName: 'Cardiology',
      imageUrl: '',
      rating: null,
      consultationFee: null,
      isAvailable: true,
    ),
    appointments: [],
  );
}

void main() {
  testWidgets('shows empty states for the upcoming and selected-day schedule', (
    tester,
  ) async {
    final cubit = DoctorDashboardCubit(
      GetDoctorDashboard(_EmptyDoctorDashboardRepository()),
    );
    addTearDown(cubit.close);
    await cubit.load();
    final state = cubit.state;
    if (state is! DoctorDashboardLoaded) fail('Expected loaded dashboard.');

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: Scaffold(body: DoctorDashboardContent(state: state)),
          ),
        ),
      ),
    );

    expect(find.text('No upcoming appointments.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('No appointments for this date.'),
      240,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('No appointments for this date.'), findsOneWidget);
  });
}
