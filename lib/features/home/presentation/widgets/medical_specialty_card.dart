import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/medical_specialty.dart';

class MedicalSpecialtyCard extends StatelessWidget {
  const MedicalSpecialtyCard({
    super.key,
    required this.specialty,
    this.isSelected = false,
    this.onTap,
  });

  final MedicalSpecialty specialty;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = specialty.localizedName(
      Localizations.localeOf(context).languageCode,
    );
    final icon = _iconFor(specialty.iconName, name);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        width: 92.w,
        child: Column(
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20.r),
                border: isSelected
                    ? Border.all(color: AppColors.primary)
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: specialty.imageUrl.isEmpty
                  ? Icon(icon, color: AppColors.primary, size: 30.r)
                  : Image.network(
                      specialty.imageUrl,
                      fit: BoxFit.cover,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded || frame != null) {
                              return child;
                            }
                            return Icon(
                              icon,
                              color: AppColors.primary,
                              size: 30.r,
                            );
                          },
                      errorBuilder: (_, _, _) =>
                          Icon(icon, color: AppColors.primary, size: 30.r),
                    ),
            ),
            SizedBox(height: 8.h),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.primary : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String iconName, String name) {
    final key = '${iconName.toLowerCase()} ${name.toLowerCase()}';
    if (key.contains('heart') || key.contains('cardio')) {
      return Icons.favorite_rounded;
    }
    if (key.contains('dent')) return Icons.health_and_safety_rounded;
    if (key.contains('skin') || key.contains('derm')) {
      return Icons.face_retouching_natural_rounded;
    }
    if (key.contains('neuro')) return Icons.psychology_rounded;
    if (key.contains('pediat') || key.contains('child')) {
      return Icons.child_care_rounded;
    }
    if (key.contains('ortho') || key.contains('bone')) {
      return Icons.accessibility_new_rounded;
    }
    return Icons.medical_services_rounded;
  }
}
