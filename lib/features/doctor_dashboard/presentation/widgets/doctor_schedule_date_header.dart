import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

class DoctorScheduleDateHeader extends StatelessWidget {
  const DoctorScheduleDateHeader({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous day',
          onPressed: () =>
              onDateSelected(selectedDate.subtract(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(
              DateFormat.yMMMMd().format(selectedDate),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: () =>
              onDateSelected(selectedDate.add(const Duration(days: 1))),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) onDateSelected(date);
  }
}
