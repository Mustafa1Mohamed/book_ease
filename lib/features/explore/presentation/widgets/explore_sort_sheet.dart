import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/explore_sort.dart';

class ExploreSortSheet extends StatelessWidget {
  const ExploreSortSheet({
    super.key,
    required this.currentSort,
    required this.supportsRating,
    required this.supportsFee,
  });

  final ExploreSort currentSort;
  final bool supportsRating;
  final bool supportsFee;

  static Future<ExploreSort?> show(
    BuildContext context, {
    required ExploreSort currentSort,
    required bool supportsRating,
    required bool supportsFee,
  }) {
    return showModalBottomSheet<ExploreSort>(
      context: context,
      builder: (_) => ExploreSortSheet(
        currentSort: currentSort,
        supportsRating: supportsRating,
        supportsFee: supportsFee,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Recommended order'),
              trailing: currentSort == ExploreSort.none
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.pop(context, ExploreSort.none),
            ),
            if (supportsRating)
              ListTile(
                title: const Text('Highest rated'),
                trailing: currentSort == ExploreSort.highestRating
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, ExploreSort.highestRating),
              ),
            if (supportsFee)
              ListTile(
                title: const Text('Lowest consultation fee'),
                trailing: currentSort == ExploreSort.lowestFee
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, ExploreSort.lowestFee),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
