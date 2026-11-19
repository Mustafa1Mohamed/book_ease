import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/domain/entities/medical_specialty.dart';

class ExploreFilterOptions extends StatelessWidget {
  const ExploreFilterOptions({
    super.key,
    required this.specialties,
    required this.specialtyId,
    required this.availableOnly,
    required this.supportsAvailability,
    required this.onSpecialtyChanged,
    required this.onAvailabilityChanged,
  });

  final List<MedicalSpecialty> specialties;
  final String? specialtyId;
  final bool availableOnly;
  final bool supportsAvailability;
  final ValueChanged<String?> onSpecialtyChanged;
  final ValueChanged<bool> onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specialty', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: specialtyId,
          decoration: const InputDecoration(labelText: 'Any specialty'),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Any specialty'),
            ),
            ...specialties.map(
              (specialty) => DropdownMenuItem(
                value: specialty.id,
                child: Text(specialty.name),
              ),
            ),
          ],
          onChanged: onSpecialtyChanged,
        ),
        if (supportsAvailability)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: availableOnly,
            onChanged: (value) => onAvailabilityChanged(value ?? false),
            title: const Text('Available only'),
          ),
      ],
    );
  }
}
