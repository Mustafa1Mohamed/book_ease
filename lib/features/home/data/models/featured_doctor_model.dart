import '../../domain/entities/featured_doctor.dart';

abstract final class FeaturedDoctorModel {
  static FeaturedDoctor? fromMap(
    String id,
    Map<String, dynamic> data, {
    required Map<String, String> specialtyNamesById,
  }) {
    final fullName = _string(data['fullName']).trim().isNotEmpty
        ? _string(data['fullName']).trim()
        : _string(data['name']).trim();
    if (fullName.isEmpty) return null;

    final specialtyId = _string(data['specialtyId']);
    return FeaturedDoctor(
      id: id,
      fullName: fullName,
      specialtyId: specialtyId,
      specialtyName: _string(data['specialtyName']).trim().isNotEmpty
          ? _string(data['specialtyName']).trim()
          : specialtyNamesById[specialtyId] ?? '',
      imageUrl: _string(data['profileImageUrl']),
      rating: _number(data['rating']),
      consultationFee: _number(data['consultationFee']),
      isAvailable: data['isAvailable'] is bool
          ? data['isAvailable'] as bool
          : null,
    );
  }

  static String _string(Object? value) => value is String ? value : '';

  static double? _number(Object? value) {
    final number = switch (value) {
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
    return number != null && number.isFinite && number >= 0 ? number : null;
  }
}
