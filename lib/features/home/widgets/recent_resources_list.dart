import 'package:flutter/material.dart';
import '../../../domain/entities/resource_entity.dart';
import 'resource_card.dart';

/// Grid View for Recent Campus Resource Listings
class RecentResourcesList extends StatelessWidget {
  final List<Map<String, dynamic>> resources;
  final Function(String id) onResourceTap;

  const RecentResourcesList({
    super.key,
    required this.resources,
    required this.onResourceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text('No recent resources available right now.'),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final item = resources[index];
        final entity = ResourceEntity(
          id: item['id'] ?? 'recent_$index',
          title: item['title'] ?? 'Resource Title',
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

        return ResourceCard(
          resource: entity,
          onTap: () => onResourceTap(entity.id),
        );
      },
    );
  }
}
