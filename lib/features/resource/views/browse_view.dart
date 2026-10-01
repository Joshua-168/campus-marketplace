import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/router/route_constants.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../home/widgets/resource_card.dart';
import '../providers/browse_filter_provider.dart';
import '../providers/resource_provider.dart';

class BrowseView extends ConsumerStatefulWidget {
  const BrowseView({super.key});

  @override
  ConsumerState<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends ConsumerState<BrowseView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final filterState = ref.watch(browseFilterNotifierProvider);
            final filterNotifier = ref.read(browseFilterNotifierProvider.notifier);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort Listings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          filterNotifier.resetFilters();
                          _searchController.clear();
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Sort Options
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ResourceSortOption>(
                    initialValue: filterState.sortOption,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: ResourceSortOption.values.map((opt) {
                      return DropdownMenuItem(
                        value: opt,
                        child: Text(opt.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) filterNotifier.setSortOption(val);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Free Only Switch
                  SwitchListTile(
                    title: const Text('Free Borrow Only', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Show items offered at ₹0 cost'),
                    value: filterState.freeOnly,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => filterNotifier.toggleFreeOnly(val),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(browseFilterNotifierProvider);
    final filterNotifier = ref.read(browseFilterNotifierProvider.notifier);

    final resourcesStream = ref.watch(
      resourcesByCategoryStreamProvider(filterState.selectedCategory),
    );


    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Campus Marketplace'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => filterNotifier.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search by title, description, or tag...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            filterNotifier.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Category Tab Bar
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ChoiceChip(
                    label: const Text('All Categories'),
                    selected: filterState.selectedCategory == null,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: filterState.selectedCategory == null ? Colors.white : AppColors.textPrimaryLight,
                      fontWeight: filterState.selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) filterNotifier.setCategory(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...ResourceCategory.values.map((cat) {
                    final isSelected = filterState.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat.displayName),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          filterNotifier.setCategory(selected ? cat : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Active Filter Badges Row
            if (filterState.freeOnly || filterState.searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    if (filterState.freeOnly)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: const Text('Free Borrow'),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => filterNotifier.toggleFreeOnly(false),
                          backgroundColor: AppColors.success.withValues(alpha: 0.15),
                          side: BorderSide.none,
                        ),
                      ),
                    if (filterState.searchQuery.isNotEmpty)
                      Chip(
                        label: Text('Query: "${filterState.searchQuery}"'),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          _searchController.clear();
                          filterNotifier.setSearchQuery('');
                        },
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        side: BorderSide.none,
                      ),
                  ],
                ),
              ),

            // Main Grid Stream Content
            Expanded(
              child: resourcesStream.when(
                data: (resourcesList) {
                  // Apply Client-Side Filter Rules (Free Only, Search Query, Sorting)
                  var filteredList = resourcesList.where((item) {
                    if (filterState.freeOnly && item.price > 0) {
                      return false;
                    }
                    if (filterState.searchQuery.isNotEmpty) {
                      final q = filterState.searchQuery.toLowerCase();
                      final matchesTitle = item.title.toLowerCase().contains(q);
                      final matchesDesc = item.description.toLowerCase().contains(q);
                      final matchesCategory = item.category.displayName.toLowerCase().contains(q);
                      if (!matchesTitle && !matchesDesc && !matchesCategory) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();

                  // Sort List
                  if (filterState.sortOption == ResourceSortOption.priceLowToHigh) {
                    filteredList.sort((a, b) => a.price.compareTo(b.price));
                  } else if (filterState.sortOption == ResourceSortOption.priceHighToLow) {
                    filteredList.sort((a, b) => b.price.compareTo(a.price));
                  } else {
                    filteredList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  }

                  if (filteredList.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No Resources Found',
                      description: 'No campus items match your selected filters. Try clearing some filters or searching for something else.',
                      buttonText: 'Reset Filters',
                      onActionButtonPressed: () {
                        filterNotifier.resetFilters();
                        _searchController.clear();
                      },
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.74,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return ResourceCard(
                        resource: item,
                        onTap: () => context.pushNamed(
                          RouteConstants.resourceDetailsName,
                          pathParameters: {'id': item.id},
                        ),
                      );
                    },
                  );
                },
                loading: () => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.74,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, _) => ShimmerLoading.cardSkeleton(height: 220),
                ),
                error: (err, stack) => ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.refresh(resourcesByCategoryStreamProvider(filterState.selectedCategory)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
