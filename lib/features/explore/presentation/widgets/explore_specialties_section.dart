import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/domain/entities/medical_specialty.dart';
import '../../../home/presentation/widgets/home_section_header.dart';
import '../../../home/presentation/widgets/home_section_empty.dart';
import '../../../home/presentation/widgets/medical_specialty_card.dart';

class ExploreSpecialtiesSection extends StatelessWidget {
  const ExploreSpecialtiesSection({
    super.key,
    required this.specialties,
    required this.selectedId,
    required this.query,
    required this.hasError,
    required this.onSelect,
    required this.onRetry,
  });

  final List<MedicalSpecialty> specialties;
  final String? selectedId;
  final String query;
  final bool hasError;
  final ValueChanged<String?> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final visibleSpecialties = specialties
        .where(
          (specialty) =>
              specialty.name.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(
          title: 'Specialties',
          actionLabel: selectedId == null ? null : 'Clear',
          onAction: selectedId == null ? null : () => onSelect(null),
        ),
        SizedBox(height: 12.h),
        if (hasError)
          HomeSectionEmpty(
            message: 'Could not load specialties.',
            onRetry: onRetry,
          )
        else if (visibleSpecialties.isEmpty)
          const HomeSectionEmpty(message: 'No specialties found.')
        else
          SizedBox(
            height: 116.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visibleSpecialties.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (_, index) {
                final specialty = visibleSpecialties[index];
                final isSelected = specialty.id == selectedId;
                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: 'Filter by ${specialty.name}',
                  child: MedicalSpecialtyCard(
                    specialty: specialty,
                    isSelected: isSelected,
                    onTap: () => onSelect(isSelected ? null : specialty.id),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
