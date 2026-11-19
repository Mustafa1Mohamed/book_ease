import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

class ExploreFilterActions extends StatelessWidget {
  const ExploreFilterActions({
    super.key,
    required this.onCancel,
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onCancel;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        const Spacer(),
        TextButton(onPressed: onReset, child: const Text('Reset')),
        SizedBox(width: 8.w),
        FilledButton(onPressed: onApply, child: const Text('Apply')),
      ],
    );
  }
}
