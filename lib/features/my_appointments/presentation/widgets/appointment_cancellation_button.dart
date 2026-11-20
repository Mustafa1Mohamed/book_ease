import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/my_appointment.dart';

class AppointmentCancellationButton extends StatelessWidget {
  const AppointmentCancellationButton({
    super.key,
    required this.appointment,
    required this.isCancelling,
    required this.policyDescription,
    required this.onCancel,
  });

  final MyAppointment appointment;
  final bool isCancelling;
  final String policyDescription;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          policyDescription,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        OutlinedButton.icon(
          onPressed: isCancelling ? null : () => _confirm(context),
          icon: isCancelling
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.event_busy_rounded),
          label: Text(isCancelling ? 'Cancelling...' : 'Cancel appointment'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final date = DateFormat.yMMMd().add_jm().format(
      appointment.scheduledAt.toLocal(),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: Text(
          'Cancel your appointment with ${appointment.doctorName} on $date?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep appointment'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Cancel appointment'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) onCancel();
  }
}
