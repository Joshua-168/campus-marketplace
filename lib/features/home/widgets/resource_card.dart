import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../favourites/providers/favourites_provider.dart';

class ResourceCard extends ConsumerWidget {
  final ResourceEntity resource;
  final VoidCallback onTap;

  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favNotifier = ref.read(favouritesNotifierProvider.notifier);
    final isFav = ref.watch(favouritesNotifierProvider).contains(resource.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Image with Floating Favourite Button, Condition & Availability Tag
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    child: AspectRatio(
                      aspectRatio: 1.35,
                      child: Hero(
                        tag: 'resource_image_${resource.id}',
                        child: CachedNetworkImage(
                          imageUrl: resource.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.cardDarkHover,
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.cardDarkHover,
                            child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondaryDark, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating Favourite Heart Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => favNotifier.toggleFavourite(resource.id),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? AppColors.error : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Condition Tag
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        resource.condition.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Card Content Body (Flexible to prevent any RenderFlex overflow)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  resource.category.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondaryLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${resource.averageRating}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            resource.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            resource.price == 0 ? 'Free Borrow' : '₹${resource.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: resource.price == 0 ? AppColors.success : AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              resource.ownerName.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
