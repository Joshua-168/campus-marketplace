import 'package:flutter/material.dart';
import '../../../domain/entities/resource_entity.dart';
import 'resource_card.dart';

/// Horizontal Featured Resources Carousel
class FeaturedResourcesCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> resources;
  final Function(String id) onResourceTap;

  const FeaturedResourcesCarousel({
    super.key,
    required this.resources,
    required this.onResourceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: resources.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = resources[index];
          final entity = ResourceEntity(
            id: item['id'] ?? 'res_$index',
            title: item['title'] ?? 'Academic Resource',
            description: 'Campus listing',
            category: ResourceCategory.fromString(item['category'] ?? 'Books'),
            condition: ResourceCondition.fromString(item['condition'] ?? 'Good'),
            availability: ResourceAvailability.fromString(item['availability'] ?? 'Available'),
            price: (item['price'] as num?)?.toDouble() ?? 0.0,
            depositAmount: 100,
            ownerId: 'owner_$index',
            ownerName: item['ownerName'] ?? 'Student',
            ownerEmail: 'student@citchennai.net',
            campusName: 'Chennai Institute of Technology',
            imageUrl: item['imageUrl'] ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          return SizedBox(
            width: 200,
            child: ResourceCard(
              resource: entity,
              onTap: () => onResourceTap(entity.id),
            ),
          );
        },
      ),
    );
  }
}
