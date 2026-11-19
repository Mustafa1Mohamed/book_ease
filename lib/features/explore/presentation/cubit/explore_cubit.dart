import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/explore_filters.dart';
import '../../domain/entities/explore_sort.dart';
import '../../domain/usecases/get_explore_catalog.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._getExploreCatalog) : super(const ExploreInitial());

  final GetExploreCatalog _getExploreCatalog;
  bool _isLoading = false;

  Future<void> load({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    final previous = state;
    if (refresh && previous is ExploreLoaded) {
      emit(previous.copyWith(isRefreshing: true, clearRefreshError: true));
    } else {
      emit(const ExploreLoading());
    }

    try {
      final catalog = await _getExploreCatalog();
      if (previous is ExploreLoaded) {
        emit(
          ExploreLoaded(
            catalog: catalog,
            query: previous.query,
            filters: previous.filters,
          ),
        );
      } else {
        emit(ExploreLoaded(catalog: catalog));
      }
    } on Exception catch (error, stackTrace) {
      debugPrint('Explore catalog load failed: $error\n$stackTrace');
      _emitFailure(
        'Explore data could not be loaded. Please try again.',
        previous,
      );
    } finally {
      _isLoading = false;
    }
  }

  void updateQuery(String query) {
    final current = state;
    if (current is ExploreLoaded) {
      emit(current.copyWith(query: query));
    }
  }

  void applyFilters(ExploreFilters filters) {
    final current = state;
    if (current is ExploreLoaded) {
      emit(current.copyWith(filters: filters));
    }
  }

  void selectSpecialty(String? specialtyId) {
    final current = state;
    if (current is ExploreLoaded) {
      emit(
        current.copyWith(
          filters: current.filters.copyWith(
            specialtyId: specialtyId,
            clearSpecialty: specialtyId == null,
          ),
        ),
      );
    }
  }

  void selectSort(ExploreSort sort) {
    final current = state;
    if (current is ExploreLoaded) {
      emit(current.copyWith(filters: current.filters.copyWith(sort: sort)));
    }
  }

  void clearFilters() => applyFilters(const ExploreFilters());

  void _emitFailure(String message, ExploreState previous) {
    if (previous is ExploreLoaded) {
      emit(previous.copyWith(isRefreshing: false, refreshError: message));
    } else {
      emit(ExploreFailure(message));
    }
  }
}
