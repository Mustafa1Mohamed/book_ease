import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/presentation/widgets/home_search_field.dart';

class ExploreSearchPanel extends StatelessWidget {
  const ExploreSearchPanel({
    super.key,
    required this.controller,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.isRefreshing,
    required this.refreshError,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final bool isRefreshing;
  final String? refreshError;

  @override
  Widget build(BuildContext context) {
    final visibleError = refreshError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSearchField(
          controller: controller,
          onChanged: onQueryChanged,
          onClear: onClearQuery,
        ),
        if (isRefreshing) ...[
          SizedBox(height: 12.h),
          const LinearProgressIndicator(),
        ],
        if (visibleError != null) ...[
          SizedBox(height: 10.h),
          Text(
            visibleError,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
