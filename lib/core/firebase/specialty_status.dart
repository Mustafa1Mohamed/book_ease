enum SpecialtyAvailability { legacyActive, active, inactive, invalid }

SpecialtyAvailability specialtyAvailability(Map<String, dynamic> data) {
  if (!data.containsKey('isActive')) {
    return SpecialtyAvailability.legacyActive;
  }
  return switch (data['isActive']) {
    true => SpecialtyAvailability.active,
    false => SpecialtyAvailability.inactive,
    _ => SpecialtyAvailability.invalid,
  };
}

bool specialtyIsAvailableForPatients(Map<String, dynamic> data) {
  final status = specialtyAvailability(data);
  return status == SpecialtyAvailability.legacyActive ||
      status == SpecialtyAvailability.active;
}
