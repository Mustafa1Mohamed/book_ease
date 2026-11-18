import 'package:equatable/equatable.dart';

class HomeSectionData<T> extends Equatable {
  const HomeSectionData({required this.value, this.hasError = false});

  final T value;
  final bool hasError;

  @override
  List<Object?> get props => [value, hasError];
}
