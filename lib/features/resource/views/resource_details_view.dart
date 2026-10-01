import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favourites/providers/favourites_provider.dart';
import '../../request/widgets/request_dialog.dart';
import '../providers/resource_provider.dart';

class ResourceDetailsView extends ConsumerWidget {
  final String resourceId;

  const ResourceDetailsView({super.key, required this.resourceId});

  Color _getAvailabilityColor(ResourceAvailability availability) {
    switch (availability) {
      case ResourceAvailability.available:
        return AppColors.success;
      case ResourceAvailability.borrowed:
      case ResourceAvailability.rented:
        return AppColors.warning;
      case ResourceAvailability.sold:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authNotifierProvider).user;
    final resourceAsync = ref.watch(resourceDetailStreamProvider(resourceId));
    final favNotifier = ref.read(favouritesNotifierProvider.notifier);
    final isFav = ref.watch(favouritesNotifierProvider).contains(resourceId);

    return Scaffold(
      body: resourceAsync.when(
        data: (resource) {
          if (resource == null) {
            return const ErrorView(message: 'This resource listing was deleted or is no longer available.');
          }

          final isOwner = currentUser != null && currentUser.id == resource.ownerId;
          final statusColor = _getAvailabilityColor(resource.availability);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Sliver AppBar with Hero Image Header
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isFav ? AppColors.error : Colors.white,
                            ),
                            onPressed: () => favNotifier.toggleFavourite(resource.id),
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'resource_image_${resource.id}',
                        child: CachedNetworkImage(
                          imageUrl: resource.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => ShimmerLoading.cardSkeleton(height: 320),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.cardDarkHover,
                            child: const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Resource Details Content Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges & Category
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  resource.category.displayName,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.cardDark,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  resource.condition.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  resource.availability.displayName,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Title & Pricing
                          Text(
                            resource.title,
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                resource.price == 0 ? 'Free Borrow' : '₹${resource.price.toStringAsFixed(0)} / day',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: resource.price == 0 ? AppColors.success : AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (resource.depositAmount > 0) ...[
                                const SizedBox(width: 16),
                                const Icon(Icons.security_rounded, size: 14, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Text(
                                  'Deposit: ₹${resource.depositAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Campus Pickup Location Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Campus Pickup Location', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildLocationDetail('Block', resource.pickupBlock),
                                    _buildLocationDetail('Floor', resource.floor),
                                    _buildLocationDetail('Room', resource.roomNumber),
                                  ],
                                ),
                                const Divider(height: 24, color: AppColors.cardDarkHover),
                                Row(
                                  children: [
                                    const Icon(Icons.meeting_room_rounded, size: 16, color: AppColors.accent),
                                    const SizedBox(width: 8),
                                    Text('Meeting Point: ', style: theme.textTheme.bodySmall),
                                    Text(resource.meetingPoint, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Owner Information Card with Direct Contact Triggers
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    resource.ownerName.isNotEmpty ? resource.ownerName[0].toUpperCase() : 'O',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(resource.ownerName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                                          const SizedBox(width: 4),
                                          Text('${resource.averageRating} (${resource.reviewCount} Reviews)', style: theme.textTheme.bodySmall),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accent),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Starting campus chat with ${resource.ownerName}... 💬')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.phone_outlined, color: AppColors.success),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Calling ${resource.ownerName}... 📞')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text('Description & Rules', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(resource.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky Bottom Action Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: isOwner
                      ? CustomButton(
                          text: 'You Own This Listing',
                          onPressed: null,
                        )
                      : CustomButton(
                          text: resource.isAvailable ? AppStrings.requestResource : 'Currently Unavailable',
                          onPressed: resource.isAvailable
                              ? () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => RequestDialog(resource: resource),
                                  );
                                }
                              : null,
                        ),
                ),
              ),
            ],
          );
        },
        loading: () => ShimmerLoading.cardSkeleton(height: 400),
        error: (e, _) => ErrorView(message: 'Error loading details: $e'),
      ),
    );
  }

  Widget _buildLocationDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
