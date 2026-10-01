import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/router/route_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../../resource/providers/resource_provider.dart';
import '../../resource/providers/upload_resource_provider.dart';

class MyListingsView extends ConsumerWidget {
  const MyListingsView({super.key});

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ResourceEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: Text('Are you sure you want to remove "${item.title}" from the campus marketplace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await ref.read(resourceRepositoryProvider).deleteResource(item.id);
              result.fold(
                onSuccess: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Listing deleted successfully.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                onFailure: (failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delete failed: ${failure.message}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleAvailabilityStatus(BuildContext context, WidgetRef ref, ResourceEntity item) async {
    final nextStatus = item.availability == ResourceAvailability.available
        ? ResourceAvailability.borrowed
        : ResourceAvailability.available;

    final updated = item.copyWith(availability: nextStatus, updatedAt: DateTime.now());
    final success = await ref.read(uploadResourceNotifierProvider.notifier).updateListing(updated);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${nextStatus.displayName}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Inventory Listings')),
        body: const EmptyStateView(
          icon: Icons.lock_outline_rounded,
          title: 'Sign In Required',
          description: 'Sign in to manage your active campus listings and inventory items.',
        ),
      );
    }

    final allResourcesAsync = ref.watch(allResourcesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inventory Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => context.pushNamed(RouteConstants.addListingName),
          ),
        ],
      ),
      body: SafeArea(
        child: allResourcesAsync.when(
          data: (allResources) {
            final myListings = allResources.where((res) => res.ownerId == user.id).toList();

            if (myListings.isEmpty) {
              return EmptyStateView(
                icon: Icons.inventory_2_outlined,
                title: 'No Listings Posted',
                description: 'You haven\'t uploaded any items for share or sale yet. Help campus peers by posting an unused resource.',
                buttonText: 'Post First Listing',
                onActionButtonPressed: () => context.pushNamed(RouteConstants.addListingName),
              );
            }

            final availableCount = myListings.where((i) => i.isAvailable).length;
            final borrowedCount = myListings.length - availableCount;

            return Column(
              children: [
                // Inventory Stats Summary Bar
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Total Items', '${myListings.length}'),
                      Container(height: 30, width: 1, color: Colors.white38),
                      _buildStatColumn('Available', '$availableCount'),
                      Container(height: 30, width: 1, color: Colors.white38),
                      _buildStatColumn('Borrowed', '$borrowedCount'),
                    ],
                  ),
                ),

                // Inventory List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: myListings.length,
                    itemBuilder: (context, index) {
                      final item = myListings[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? AppColors.cardDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: item.imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: item.imageUrl,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 64,
                                          height: 64,
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                                        ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            item.category.displayName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '• Posted ${Formatters.formatRelativeTime(item.createdAt)}',
                                            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),

                            // Control Actions Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _toggleAvailabilityStatus(context, ref, item),
                                  icon: Icon(
                                    item.isAvailable
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.pause_circle_outline_rounded,
                                    size: 18,
                                    color: item.isAvailable ? AppColors.success : AppColors.warning,
                                  ),
                                  label: Text(
                                    item.isAvailable ? 'Mark Borrowed' : 'Mark Available',
                                    style: TextStyle(
                                      color: item.isAvailable ? AppColors.success : AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                      onPressed: () => context.pushNamed(
                                        RouteConstants.editListingName,
                                        pathParameters: {'id': item.id},
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                      onPressed: () => _showDeleteConfirmation(context, ref, item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (_, _) => ShimmerLoading.listTileSkeleton(),
          ),
          error: (err, stack) => ErrorView(message: err.toString()),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
