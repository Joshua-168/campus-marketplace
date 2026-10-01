import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/resource_entity.dart';

enum ResourceSortOption {
  newest('Newest First'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low');

  final String label;
  const ResourceSortOption(this.label);
}

class BrowseFilterState {
  final ResourceCategory? selectedCategory;
  final ResourceAvailability? selectedAvailability;
  final bool freeOnly;
  final ResourceSortOption sortOption;
  final String searchQuery;

  const BrowseFilterState({
    this.selectedCategory,
    this.selectedAvailability,
    this.freeOnly = false,
    this.sortOption = ResourceSortOption.newest,
    this.searchQuery = '',
  });

  BrowseFilterState copyWith({
    ResourceCategory? selectedCategory,
    bool clearCategory = false,
    ResourceAvailability? selectedAvailability,
    bool clearAvailability = false,
    bool? freeOnly,
    ResourceSortOption? sortOption,
    String? searchQuery,
  }) {
    return BrowseFilterState(
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedAvailability: clearAvailability ? null : (selectedAvailability ?? this.selectedAvailability),
      freeOnly: freeOnly ?? this.freeOnly,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class BrowseFilterNotifier extends StateNotifier<BrowseFilterState> {
  BrowseFilterNotifier() : super(const BrowseFilterState());

  void setCategory(ResourceCategory? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setAvailability(ResourceAvailability? availability) {
    if (availability == null) {
      state = state.copyWith(clearAvailability: true);
    } else {
      state = state.copyWith(selectedAvailability: availability);
    }
  }

  void toggleFreeOnly(bool value) {
    state = state.copyWith(freeOnly: value);
  }

  void setSortOption(ResourceSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void resetFilters() {
    state = const BrowseFilterState();
  }
}

final browseFilterNotifierProvider =
    StateNotifierProvider<BrowseFilterNotifier, BrowseFilterState>((ref) {
  return BrowseFilterNotifier();
});
