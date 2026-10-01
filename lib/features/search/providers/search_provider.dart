import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/resource_entity.dart';
import '../../../domain/repositories/resource_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../resource/providers/resource_provider.dart';

class SearchState {
  final String query;
  final bool isSearching;
  final List<String> recentSearches;
  final List<ResourceEntity> searchResults;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.isSearching = false,
    this.recentSearches = const [],
    this.searchResults = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    List<String>? recentSearches,
    List<ResourceEntity>? searchResults,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      recentSearches: recentSearches ?? this.recentSearches,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ResourceRepository repository;
  final SharedPreferences prefs;
  static const String _recentSearchesKey = 'recent_search_queries';

  SearchNotifier({
    required this.repository,
    required this.prefs,
  }) : super(const SearchState()) {
    _loadRecentSearches();
  }


  void _loadRecentSearches() {
    final list = prefs.getStringList(_recentSearchesKey) ?? [];
    state = state.copyWith(recentSearches: list);
  }

  Future<void> _saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final current = List<String>.from(state.recentSearches);
    current.remove(trimmed);
    current.insert(0, trimmed);

    if (current.length > 8) {
      current.removeLast();
    }

    state = state.copyWith(recentSearches: current);
    await prefs.setStringList(_recentSearchesKey, current);
  }

  Future<void> removeRecentSearch(String query) async {
    final current = List<String>.from(state.recentSearches);
    current.remove(query);
    state = state.copyWith(recentSearches: current);
    await prefs.setStringList(_recentSearchesKey, current);
  }

  Future<void> clearRecentSearches() async {
    state = state.copyWith(recentSearches: []);
    await prefs.remove(_recentSearchesKey);
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(query: '', searchResults: [], isSearching: false);
      return;
    }

    state = state.copyWith(query: trimmed, isSearching: true, errorMessage: null);

    final result = await repository.searchResources(trimmed);

    result.fold(
      onSuccess: (list) {
        state = state.copyWith(
          isSearching: false,
          searchResults: list,
        );
        _saveRecentSearch(trimmed);
      },
      onFailure: (failure) {
        state = state.copyWith(
          isSearching: false,
          errorMessage: failure.message,
        );
      },
    );
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(
    repository: ref.watch(resourceRepositoryProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  );
});
