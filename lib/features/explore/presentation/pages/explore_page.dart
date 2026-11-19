import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/presentation/widgets/home_error_view.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import '../widgets/explore_content.dart';
import '../widgets/explore_loading_view.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (context, state) {
        final cubit = context.read<ExploreCubit>();
        return switch (state) {
          ExploreLoaded(
            :final catalog,
            :final query,
            :final filters,
            :final filteredDoctors,
            :final isRefreshing,
            :final refreshError,
          ) =>
            ExploreContent(
              catalog: catalog,
              query: query,
              filters: filters,
              filteredDoctors: filteredDoctors,
              searchController: _searchController,
              isRefreshing: isRefreshing,
              refreshError: refreshError,
              onQueryChanged: cubit.updateQuery,
              onClearQuery: () {
                _searchController.clear();
                cubit.updateQuery('');
              },
              onRefresh: () => cubit.load(refresh: true),
              onSelectSpecialty: cubit.selectSpecialty,
              onApplyFilters: cubit.applyFilters,
              onSelectSort: cubit.selectSort,
            ),
          ExploreFailure(:final message) => HomeErrorView(
            message: message,
            onRetry: () => cubit.load(),
          ),
          _ => const ExploreLoadingView(),
        };
      },
    );
  }
}
