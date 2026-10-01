/// Academic Resource Category Enum
enum ResourceCategory {
  books('Books'),
  electronics('Electronics'),
  labEquipment('Lab Equipment'),
  sportsEquipment('Sports Equipment'),
  projectKits('Project Kits'),
  musicalInstruments('Musical Instruments'),
  hostelEssentials('Hostel Essentials'),
  others('Others');

  final String displayName;
  const ResourceCategory(this.displayName);

  static ResourceCategory fromString(String categoryStr) {
    return ResourceCategory.values.firstWhere(
      (e) => e.displayName.toLowerCase() == categoryStr.toLowerCase(),
      orElse: () => ResourceCategory.others,
    );
  }
}

/// Resource Condition Enum
enum ResourceCondition {
  brandNew('Brand New'),
  likeNew('Like New'),
  good('Good'),
  fair('Fair');

  final String displayName;
  const ResourceCondition(this.displayName);

  static ResourceCondition fromString(String conditionStr) {
    return ResourceCondition.values.firstWhere(
      (e) => e.displayName.toLowerCase() == conditionStr.toLowerCase(),
      orElse: () => ResourceCondition.good,
    );
  }
}

/// Resource Availability Enum
enum ResourceAvailability {
  available('Available'),
  borrowed('Borrowed'),
  rented('Rented'),
  sold('Sold');

  final String displayName;
  const ResourceAvailability(this.displayName);

  static ResourceAvailability fromString(String statusStr) {
    return ResourceAvailability.values.firstWhere(
      (e) => e.displayName.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => ResourceAvailability.available,
    );
  }
}

/// Pure Domain Entity representing a campus resource listing.
class ResourceEntity {
  final String id;
  final String title;
  final String description;
  final ResourceCategory category;
  final ResourceCondition condition;
  final ResourceAvailability availability;
  final double price;
  final double depositAmount;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String campusName;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New Pickup Location & Review Fields
  final String pickupBlock;
  final String floor;
  final String roomNumber;
  final String meetingPoint;
  final double averageRating;
  final int reviewCount;
  final bool isFavourite;

  const ResourceEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.availability,
    required this.price,
    required this.depositAmount,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.campusName,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.pickupBlock = 'Academic Block A',
    this.floor = '2nd Floor',
    this.roomNumber = 'Lab A-204',
    this.meetingPoint = 'Main Library Entrance',
    this.averageRating = 4.8,
    this.reviewCount = 12,
    this.isFavourite = false,
  });

  bool get isFreeBorrow => price == 0;
  bool get isAvailable => availability == ResourceAvailability.available;

  ResourceEntity copyWith({
    String? id,
    String? title,
    String? description,
    ResourceCategory? category,
    ResourceCondition? condition,
    ResourceAvailability? availability,
    double? price,
    double? depositAmount,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    String? campusName,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pickupBlock,
    String? floor,
    String? roomNumber,
    String? meetingPoint,
    double? averageRating,
    int? reviewCount,
    bool? isFavourite,
  }) {
    return ResourceEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      availability: availability ?? this.availability,
      price: price ?? this.price,
      depositAmount: depositAmount ?? this.depositAmount,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      campusName: campusName ?? this.campusName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pickupBlock: pickupBlock ?? this.pickupBlock,
      floor: floor ?? this.floor,
      roomNumber: roomNumber ?? this.roomNumber,
      meetingPoint: meetingPoint ?? this.meetingPoint,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}
