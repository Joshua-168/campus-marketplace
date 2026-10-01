/// User Roles for Campus Authorization
enum UserRole {
  student('Student'),
  faculty('Faculty'),
  admin('Administrator');

  final String displayName;
  const UserRole(this.displayName);

  static UserRole fromString(String roleStr) {
    return UserRole.values.firstWhere(
      (e) => e.displayName.toLowerCase() == roleStr.toLowerCase(),
      orElse: () => UserRole.student,
    );
  }
}

/// Pure Domain Entity representing an authenticated student user.
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String campusName;
  final String? photoUrl;
  final bool isEmailVerified;
  final String department;
  final String year;
  final String phoneNumber;
  final DateTime joinedAt;
  final UserRole role;
  final bool isVerified;
  final double rating;
  final int resourcesUploaded;
  final int resourcesBorrowed;
  final int completedTransactions;
  final int wishlistCount;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String bio;
  final DateTime lastLogin;
  final List<String> achievements;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.campusName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.department = 'Computer Science & Engineering',
    this.year = '3rd Year',
    this.phoneNumber = '+91 98765 43210',
    required this.joinedAt,
    this.role = UserRole.student,
    this.isVerified = true,
    this.rating = 4.9,
    this.resourcesUploaded = 5,
    this.resourcesBorrowed = 8,
    this.completedTransactions = 13,
    this.wishlistCount = 4,
    this.notificationsEnabled = true,
    this.darkModeEnabled = true,
    this.bio = 'Passionate computer science student sharing lab equipment & engineering textbooks.',
    required this.lastLogin,
    this.achievements = const [
      'First Upload 🚀',
      'Trusted Borrow Member 🤝',
      'Top Contributor 🏆',
    ],
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? campusName,
    String? photoUrl,
    bool? isEmailVerified,
    String? department,
    String? year,
    String? phoneNumber,
    DateTime? joinedAt,
    UserRole? role,
    bool? isVerified,
    double? rating,
    int? resourcesUploaded,
    int? resourcesBorrowed,
    int? completedTransactions,
    int? wishlistCount,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? bio,
    DateTime? lastLogin,
    List<String>? achievements,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      campusName: campusName ?? this.campusName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      department: department ?? this.department,
      year: year ?? this.year,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      joinedAt: joinedAt ?? this.joinedAt,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      resourcesUploaded: resourcesUploaded ?? this.resourcesUploaded,
      resourcesBorrowed: resourcesBorrowed ?? this.resourcesBorrowed,
      completedTransactions: completedTransactions ?? this.completedTransactions,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      bio: bio ?? this.bio,
      lastLogin: lastLogin ?? this.lastLogin,
      achievements: achievements ?? this.achievements,
    );
  }
}
