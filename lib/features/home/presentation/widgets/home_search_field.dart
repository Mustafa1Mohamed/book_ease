import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search doctors, specialties...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
      ),
    );
  }
}
