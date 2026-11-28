import 'package:book_ease/features/explore/domain/entities/explore_filters.dart';
import 'package:book_ease/features/explore/domain/entities/explore_sort.dart';
import 'package:book_ease/features/explore/domain/usecases/filter_explore_catalog.dart';
import 'package:book_ease/features/home/domain/entities/featured_doctor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const doctors = [
    FeaturedDoctor(
      id: 'one',
      fullName: 'Dr. Heart',
      specialtyId: 'cardio',
      specialtyName: 'Cardiology',
      specialtyNameAr: 'أمراض القلب',
      imageUrl: '',
      rating: 4.8,
      consultationFee: 100,
      isAvailable: true,
    ),
    FeaturedDoctor(
      id: 'two',
      fullName: 'Dr. Skin',
      specialtyId: 'derm',
      specialtyName: 'Dermatology',
      imageUrl: '',
      rating: 4.9,
      consultationFee: null,
      isAvailable: false,
    ),
    FeaturedDoctor(
      id: 'three',
      fullName: 'Dr. Care',
      specialtyId: 'cardio',
      specialtyName: 'Cardiology',
      specialtyNameAr: 'أمراض القلب',
      imageUrl: '',
      rating: null,
      consultationFee: 50,
      isAvailable: null,
    ),
  ];

  const filter = FilterExploreCatalog();

  test('searches doctor and specialty names without case sensitivity', () {
    final results = filter(
      doctors,
      query: 'derm',
      filters: const ExploreFilters(),
    );

    expect(results.map((doctor) => doctor.id), ['two']);
  });

  test('searches Arabic specialty names', () {
    final results = filter(
      doctors,
      query: 'أمراض القلب',
      filters: const ExploreFilters(),
    );

    expect(results.map((doctor) => doctor.id), ['one', 'three']);
  });

  test('filters by specialty and reliable availability', () {
    final results = filter(
      doctors,
      query: '',
      filters: const ExploreFilters(specialtyId: 'cardio', availableOnly: true),
    );

    expect(results.map((doctor) => doctor.id), ['one']);
  });

  test('sorts missing ratings and fees after values', () {
    final byRating = filter(
      doctors,
      query: '',
      filters: const ExploreFilters(sort: ExploreSort.highestRating),
    );
    final byFee = filter(
      doctors,
      query: '',
      filters: const ExploreFilters(sort: ExploreSort.lowestFee),
    );

    expect(byRating.map((doctor) => doctor.id), ['two', 'one', 'three']);
    expect(byFee.map((doctor) => doctor.id), ['three', 'one', 'two']);
  });
}
