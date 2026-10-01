import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// Data Model for User document with Firestore serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.campusName,
    super.photoUrl,
    super.isEmailVerified,
    super.department,
    super.year,
    super.phoneNumber,
    required super.joinedAt,
    super.role,
    super.isVerified,
    super.rating,
    super.resourcesUploaded,
    super.resourcesBorrowed,
    super.completedTransactions,
    super.wishlistCount,
    super.notificationsEnabled,
    super.darkModeEnabled,
    super.bio,
    required super.lastLogin,
    super.achievements,
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserModel(
      id: snapshot.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      campusName: data['campusName'] ?? 'Chennai Institute of Technology',
      photoUrl: data['profilePhoto'] ?? data['photoUrl'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      department: data['department'] ?? 'Computer Science & Engineering',
      year: data['year'] ?? '3rd Year',
      phoneNumber: data['phoneNumber'] ?? '+91 98765 43210',
      joinedAt: data['joinedAt'] != null
          ? (data['joinedAt'] as Timestamp).toDate()
          : DateTime.now(),
      role: UserRole.fromString(data['role'] ?? 'Student'),
      isVerified: data['isVerified'] ?? true,
      rating: (data['rating'] ?? 4.9).toDouble(),
      resourcesUploaded: data['resourcesUploaded'] ?? 5,
      resourcesBorrowed: data['resourcesBorrowed'] ?? 8,
      completedTransactions: data['completedTransactions'] ?? 13,
      wishlistCount: data['wishlistCount'] ?? 4,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      darkModeEnabled: data['darkModeEnabled'] ?? true,
      bio: data['bio'] ?? 'Passionate computer science student sharing lab equipment & engineering textbooks.',
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : DateTime.now(),
      achievements: List<String>.from(data['achievements'] ?? [
        'First Upload 🚀',
        'Trusted Borrow Member 🤝',
        'Top Contributor 🏆',
      ]),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'campusName': campusName,
      'profilePhoto': photoUrl,
      'isEmailVerified': isEmailVerified,
      'department': department,
      'year': year,
      'phoneNumber': phoneNumber,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'role': role.displayName,
      'isVerified': isVerified,
      'rating': rating,
      'resourcesUploaded': resourcesUploaded,
      'resourcesBorrowed': resourcesBorrowed,
      'completedTransactions': completedTransactions,
      'wishlistCount': wishlistCount,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'bio': bio,
      'lastLogin': Timestamp.fromDate(lastLogin),
      'achievements': achievements,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      campusName: entity.campusName,
      photoUrl: entity.photoUrl,
      isEmailVerified: entity.isEmailVerified,
      department: entity.department,
      year: entity.year,
      phoneNumber: entity.phoneNumber,
      joinedAt: entity.joinedAt,
      role: entity.role,
      isVerified: entity.isVerified,
      rating: entity.rating,
      resourcesUploaded: entity.resourcesUploaded,
      resourcesBorrowed: entity.resourcesBorrowed,
      completedTransactions: entity.completedTransactions,
      wishlistCount: entity.wishlistCount,
      notificationsEnabled: entity.notificationsEnabled,
      darkModeEnabled: entity.darkModeEnabled,
      bio: entity.bio,
      lastLogin: entity.lastLogin,
      achievements: entity.achievements,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      campusName: campusName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      department: department,
      year: year,
      phoneNumber: phoneNumber,
      joinedAt: joinedAt,
      role: role,
      isVerified: isVerified,
      rating: rating,
      resourcesUploaded: resourcesUploaded,
      resourcesBorrowed: resourcesBorrowed,
      completedTransactions: completedTransactions,
      wishlistCount: wishlistCount,
      notificationsEnabled: notificationsEnabled,
      darkModeEnabled: darkModeEnabled,
      bio: bio,
      lastLogin: lastLogin,
      achievements: achievements,
    );
  }
}
