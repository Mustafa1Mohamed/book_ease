import '../../domain/entities/featured_doctor.dart';
import '../../../auth/domain/entities/doctor_lifecycle_status.dart';

abstract final class FeaturedDoctorModel {
  static FeaturedDoctor? fromMap(
    String id,
    Map<String, dynamic> data, {
    required Map<String, String> specialtyNamesById,
    Map<String, String> specialtyNamesArById = const {},
  }) {
    if (!DoctorLifecycleStatus.fromDoctorData(data).canOperate) return null;

    final fullName = _string(data['fullName']).trim().isNotEmpty
        ? _string(data['fullName']).trim()
        : _string(data['name']).trim();
    if (fullName.isEmpty) return null;

    final specialtyId = _string(data['specialtyId']);
    return FeaturedDoctor(
      id: id,
      fullName: fullName,
      specialtyId: specialtyId,
      specialtyName:
          specialtyNamesById[specialtyId] ??
          _string(data['specialtyName']).trim(),
      specialtyNameAr: specialtyNamesArById[specialtyId] ?? '',
      imageUrl: _string(data['profileImageUrl']),
      rating: _number(data['rating']),
      consultationFee: _number(data['consultationFee']),
      isAvailable: data['isAvailable'] is bool
          ? data['isAvailable'] as bool
          : null,
      reviewCount: _integer(data['reviewCount']),
      biography: _string(data['biography']).trim().isNotEmpty
          ? _string(data['biography']).trim()
          : _string(data['description']).trim(),
      qualifications: _stringList(data['qualifications']),
      yearsExperience: _integer(data['yearsExperience']),
      languages: _stringList(data['languages']),
      clinicName: _string(data['clinicName']).trim(),
      clinicAddress: _string(data['clinicAddress']).trim(),
      consultationDurationMinutes: _integer(
        data['consultationDurationMinutes'],
      ),
    );
  }

  static String _string(Object? value) => value is String ? value : '';

  static List<String> _stringList(Object? value) {
    if (value is! Iterable) return const [];
    return List.unmodifiable(
      value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    );
  }

  static int? _integer(Object? value) {
    final number = switch (value) {
      int value => value,
      double value when value.isFinite && value == value.roundToDouble() =>
        value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
    return number != null && number >= 0 ? number : null;
  }

  static double? _number(Object? value) {
    final number = switch (value) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
    return number != null && number.isFinite && number >= 0 ? number : null;
  }
}
