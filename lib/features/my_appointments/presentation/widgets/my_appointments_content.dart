import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/appointment_category.dart';
import '../../domain/entities/my_appointment.dart';
import '../cubit/my_appointments_cubit.dart';
import '../cubit/my_appointments_state.dart';
import 'appointment_category_selector.dart';
import 'appointments_list.dart';

class MyAppointmentsContent extends StatelessWidget {
  const MyAppointmentsContent({super.key, required this.state});

  final MyAppointmentsLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyAppointmentsCubit>();
    final selected = state.selectedCategory;
    final counts = {
      for (final category in AppointmentCategory.values)
        category: cubit.appointmentsFor(state, category).length,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Appointments',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 14.h),
              AppointmentCategorySelector(
                selected: selected,
                counts: counts,
                onSelected: cubit.selectCategory,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: AppointmentsList(
              appointments: cubit.appointmentsFor(state, selected),
              category: selected,
              refreshError: state.refreshError,
              onOpen: (appointment) =>
                  _openDetails(context, cubit, appointment),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openDetails(
    BuildContext context,
    MyAppointmentsCubit cubit,
    MyAppointment appointment,
  ) async {
    final cancelled = await context.pushNamed<bool>(
      AppRouter.appointmentDetails,
      pathParameters: {'appointmentId': appointment.id},
    );
    if (cancelled == true && context.mounted) await cubit.refresh();
  }
}
