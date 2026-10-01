/// Application Constants & Enums Definition
class AppConstants {
  AppConstants._();

  static const String appName = 'Campus Market';
  static const String appTagline = 'Share, Borrow, Rent & Request Academic Resources';

  // Resource Categories
  static const List<String> categories = [
    'Books',
    'Electronics',
    'Lab Equipment',
    'Sports Equipment',
    'Project Kits',
    'Musical Instruments',
    'Hostel Essentials',
    'Others',
  ];

  // Resource Conditions
  static const List<String> conditions = [
    'Brand New',
    'Like New',
    'Good',
    'Fair',
  ];

  // Resource Availability Statuses
  static const List<String> availabilityTypes = [
    'Available',
    'Borrowed',
    'Rented',
    'Sold',
  ];

  // Request Statuses
  static const String requestPending = 'Pending';
  static const String requestApproved = 'Approved';
  static const String requestRejected = 'Rejected';

  // Storage Bucket Paths
  static const String resourceImagesPath = 'resource_images';
  static const String userAvatarsPath = 'user_avatars';

  // Default Asset Paths
  static const String defaultUserAvatar = 'assets/images/default_avatar.png';
  static const String defaultResourceImage = 'assets/images/placeholder_resource.png';
}
