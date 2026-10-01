import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/resource_entity.dart';

/// Data Model for Resource document with Firestore serialization.
class ResourceModel extends ResourceEntity {
  const ResourceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.condition,
    required super.availability,
    required super.price,
    required super.depositAmount,
    required super.ownerId,
    required super.ownerName,
    required super.ownerEmail,
    required super.campusName,
    required super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
    super.pickupBlock,
    super.floor,
    super.roomNumber,
    super.meetingPoint,
    super.averageRating,
    super.reviewCount,
    super.isFavourite,
  });

  factory ResourceModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ResourceModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: ResourceCategory.fromString(data['category'] ?? ''),
      condition: ResourceCondition.fromString(data['condition'] ?? ''),
      availability: ResourceAvailability.fromString(data['availability'] ?? ''),
      price: (data['price'] ?? 0).toDouble(),
      depositAmount: (data['depositAmount'] ?? 0).toDouble(),
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      campusName: data['campusName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      pickupBlock: data['pickupBlock'] ?? 'Academic Block A',
      floor: data['floor'] ?? '2nd Floor',
      roomNumber: data['roomNumber'] ?? 'Lab A-204',
      meetingPoint: data['meetingPoint'] ?? 'Main Library Entrance',
      averageRating: (data['averageRating'] ?? 4.8).toDouble(),
      reviewCount: data['reviewCount'] ?? 12,
      isFavourite: data['isFavourite'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category.displayName,
      'condition': condition.displayName,
      'availability': availability.displayName,
      'price': price,
      'depositAmount': depositAmount,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'campusName': campusName,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'pickupBlock': pickupBlock,
      'floor': floor,
      'roomNumber': roomNumber,
      'meetingPoint': meetingPoint,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isFavourite': isFavourite,
    };
  }

  factory ResourceModel.fromEntity(ResourceEntity entity) {
    return ResourceModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      condition: entity.condition,
      availability: entity.availability,
      price: entity.price,
      depositAmount: entity.depositAmount,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      ownerEmail: entity.ownerEmail,
      campusName: entity.campusName,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      pickupBlock: entity.pickupBlock,
      floor: entity.floor,
      roomNumber: entity.roomNumber,
      meetingPoint: entity.meetingPoint,
      averageRating: entity.averageRating,
      reviewCount: entity.reviewCount,
      isFavourite: entity.isFavourite,
    );
  }

  ResourceEntity toEntity() {
    return ResourceEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      condition: condition,
      availability: availability,
      price: price,
      depositAmount: depositAmount,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      campusName: campusName,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pickupBlock: pickupBlock,
      floor: floor,
      roomNumber: roomNumber,
      meetingPoint: meetingPoint,
      averageRating: averageRating,
      reviewCount: reviewCount,
      isFavourite: isFavourite,
    );
  }
}
