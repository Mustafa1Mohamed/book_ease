import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/medical_specialty.dart';

class MedicalSpecialtyCard extends StatelessWidget {
  const MedicalSpecialtyCard({super.key, required this.specialty});

  final MedicalSpecialty specialty;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(specialty.iconName, specialty.name);
    return SizedBox(
      width: 92.w,
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: specialty.imageUrl.isEmpty
                ? Icon(icon, color: AppColors.primary, size: 30.w)
                : Image.network(
                    specialty.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Icon(icon, color: AppColors.primary, size: 30.w),
                  ),
          ),
          SizedBox(height: 8.h),
          Text(
            specialty.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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
