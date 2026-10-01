import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/router/route_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../home/widgets/resource_card.dart';
import '../providers/search_provider.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  static const List<String> _smartSuggestions = [
    'Calculus Textbook',
    'TI-84 Graphing Calculator',
    'Arduino Starter Kit',
    'Aarav Sharma',
    'Lab Equipment',
    'Electronics',
    'Books',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchNotifierProvider.notifier).search(query);
    });
  }

  void _executeSearch(String query) {
    _searchController.text = query;
    ref.read(searchNotifierProvider.notifier).search(query);
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Search Filters 🎛️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Sort By Price', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('Free Borrow'), selected: true, onSelected: (_) {}),
                ChoiceChip(label: const Text('Under ₹500'), selected: false, onSelected: (_) {}),
                ChoiceChip(label: const Text('Highest Rating'), selected: false, onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(searchNotifierProvider);
    final queryText = _searchController.text.trim();
    final crossAxisCount = ResponsiveLayout.getGridCrossAxisCount(context);

    final filteredSuggestions = _smartSuggestions
        .where((s) => s.toLowerCase().contains(queryText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            onSubmitted: _executeSearch,
            decoration: InputDecoration(
              hintText: 'Search books, lab kits, owner names...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic_rounded, color: AppColors.accent),
                    onPressed: () {
                      _executeSearch('Arduino');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppColors.secondary),
                    onPressed: () => _showFilterBottomSheet(context),
                  ),
                  if (queryText.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchNotifierProvider.notifier).search('');
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Search Dropdown Suggestions (when typing)
            if (queryText.isNotEmpty && filteredSuggestions.isNotEmpty && searchState.searchResults.isEmpty && !searchState.isSearching) ...[
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: filteredSuggestions.map((suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.accent),
                      title: Text(suggestion, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      onTap: () => _executeSearch(suggestion),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Recent Searches Chips
            if (queryText.isEmpty && searchState.recentSearches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Searches 🕒', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: searchState.recentSearches.map((term) {
                        return ActionChip(
                          label: Text(term),
                          backgroundColor: AppColors.cardDark,
                          onPressed: () => _executeSearch(term),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // Search Results Body Grid
            Expanded(
              child: searchState.isSearching
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: 4,
                        itemBuilder: (context, index) => ShimmerLoading.cardSkeleton(height: 200),
                      ),
                    )
                  : searchState.searchResults.isEmpty && queryText.isNotEmpty
                      ? const EmptyStateView(
                          title: 'No Resources Found',
                          description: 'Try searching for textbooks, lab equipment, or owner names.',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                          itemCount: searchState.searchResults.length,
                          itemBuilder: (context, index) {
                            final item = searchState.searchResults[index];
                            return ResourceCard(
                              resource: item,
                              onTap: () => context.pushNamed(
                                RouteConstants.resourceDetailsName,
                                pathParameters: {'id': item.id},
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
