import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../home/domain/entities/featured_doctor.dart';
import '../../../home/presentation/widgets/home_error_view.dart';
import '../cubit/doctor_details_cubit.dart';
import '../cubit/doctor_details_state.dart';
import '../widgets/doctor_profile_header.dart';

class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
      builder: (context, state) => switch (state) {
        DoctorDetailsLoading() || DoctorDetailsInitial() => const Center(
          child: CircularProgressIndicator(),
        ),
        DoctorDetailsLoaded(:final doctor) => _DoctorDetailsContent(
          doctor: doctor,
          onBook: () => context.pushNamed(
            AppRouter.booking,
            pathParameters: {'doctorId': doctor.id},
          ),
        ),
        DoctorDetailsNotFound() => const Center(
          child: Text('This doctor is no longer available.'),
        ),
        DoctorDetailsFailure(:final message) => HomeErrorView(
          message: message,
          onRetry: () => context.read<DoctorDetailsCubit>().load(doctorId),
        ),
      },
    );
  }
}

class _DoctorDetailsContent extends StatelessWidget {
  const _DoctorDetailsContent({required this.doctor, required this.onBook});

  final FeaturedDoctor doctor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            children: [
              DoctorProfileHeader(doctor: doctor),
              if (doctor.biography.isNotEmpty)
                _Section(title: 'About', child: Text(doctor.biography)),
              if (doctor.qualifications.isNotEmpty)
                _Section(
                  title: 'Qualifications',
                  child: _BulletList(items: doctor.qualifications),
                ),
              if (doctor.yearsExperience != null)
                _Section(
                  title: 'Experience',
                  child: Text('${doctor.yearsExperience} years of experience'),
                ),
              if (doctor.languages.isNotEmpty)
                _Section(
                  title: 'Languages',
                  child: Text(doctor.languages.join(', ')),
                ),
              if (doctor.clinicName.isNotEmpty ||
                  doctor.clinicAddress.isNotEmpty)
                _Section(
                  title: 'Practice',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (doctor.clinicName.isNotEmpty)
                        Text(
                          doctor.clinicName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      if (doctor.clinicAddress.isNotEmpty)
                        Text(doctor.clinicAddress),
                    ],
                  ),
                ),
              _Section(
                title: 'Consultation',
                child: Text(
                  '${_feeLabel(doctor.consultationFee)}'
                  '${doctor.consultationDurationMinutes == null ? '' : ' · ${doctor.consultationDurationMinutes} minutes'}',
                ),
              ),
              _Section(
                title: 'Appointments',
                child: const Text(
                  'Choose a date to see the appointment times published by this doctor.',
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Book appointment'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _feeLabel(double? fee) {
    if (fee == null) return 'Fee not provided';
    return fee == fee.roundToDouble()
        ? 'Consultation fee: ${fee.toStringAsFixed(0)}'
        : 'Consultation fee: $fee';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}
