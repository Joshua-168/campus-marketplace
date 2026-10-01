import 'package:flutter_riverpod/flutter_riverpod.dart';

class CampusAnalyticsData {
  final int totalUploaded;
  final int totalBorrowed;
  final int totalAvailable;
  final String topCategory;
  final List<double> monthlyRequests;
  final Map<String, int> categoryDistribution;

  const CampusAnalyticsData({
    required this.totalUploaded,
    required this.totalBorrowed,
    required this.totalAvailable,
    required this.topCategory,
    required this.monthlyRequests,
    required this.categoryDistribution,
  });
}

final campusAnalyticsProvider = Provider<CampusAnalyticsData>((ref) {
  return const CampusAnalyticsData(
    totalUploaded: 42,
    totalBorrowed: 18,
    totalAvailable: 24,
    topCategory: 'Books & Textbooks',
    monthlyRequests: [12, 19, 25, 32, 45, 60],
    categoryDistribution: {
      'Books': 18,
      'Electronics': 10,
      'Lab Equipment': 8,
      'Project Kits': 6,
    },
  );
});
