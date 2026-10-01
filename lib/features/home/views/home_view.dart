import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/router/route_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../resource/providers/resource_provider.dart';
import '../widgets/category_selector.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/resource_card.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  ResourceCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allResourcesAsync = ref.watch(allResourcesStreamProvider);
    final crossAxisCount = ResponsiveLayout.getGridCrossAxisCount(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(allResourcesStreamProvider);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Welcome Header with Summary Stats & Announcements
                const HomeHeader(),
                const SizedBox(height: 20),

                // Search Trigger Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: HomeSearchBar(
                    onTap: () => context.goNamed(RouteConstants.searchName),
                    onFilterTap: () => context.goNamed(RouteConstants.browseName),
                  ),
                ),
                const SizedBox(height: 20),

                // Category Selector Chips
                CategorySelector(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                ),
                const SizedBox(height: 24),

                allResourcesAsync.when(
                  data: (resources) {
                    final filtered = _selectedCategory == null
                        ? resources
                        : resources.where((r) => r.category == _selectedCategory).toList();

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondaryDark),
                              const SizedBox(height: 12),
                              Text('No resources in this category', style: theme.textTheme.titleMedium),
                            ],
                          ),
                        ),
                      );
                    }

                    final featured = filtered.take(4).toList();
                    final trending = filtered.skip(1).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Featured Section Carousel
                        _buildSectionHeader(
                          context,
                          title: AppStrings.featuredResources,
                          onSeeAll: () => context.goNamed(RouteConstants.browseName),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final item = featured[index];
                              return SizedBox(
                                width: 175,
                                child: ResourceCard(
                                  resource: item,
                                  onTap: () => context.pushNamed(
                                    RouteConstants.resourceDetailsName,
                                    pathParameters: {'id': item.id},
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Trending / Recommended Grid Section (Responsive grid columns)
                        _buildSectionHeader(
                          context,
                          title: 'Recommended For You 🔥',
                          onSeeAll: () => context.goNamed(RouteConstants.browseName),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemCount: trending.length,
                            itemBuilder: (context, index) {
                              final item = trending[index];
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
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        ShimmerLoading.cardSkeleton(height: 200),
                        const SizedBox(height: 14),
                        ShimmerLoading.cardSkeleton(height: 150),
                      ],
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error loading feed: $e')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required VoidCallback onSeeAll}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
