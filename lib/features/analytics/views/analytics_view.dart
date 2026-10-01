import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../providers/analytics_provider.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analytics = ref.watch(campusAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Analytics 📊'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analytics Summary Row
            Row(
              children: [
                Expanded(child: _buildMetricCard(context, 'Uploaded', '${analytics.totalUploaded}', Icons.cloud_upload_rounded, AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(context, 'Borrowed', '${analytics.totalBorrowed}', Icons.swap_horiz_rounded, AppColors.secondary)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricCard(context, 'Available', '${analytics.totalAvailable}', Icons.check_circle_outline_rounded, AppColors.accent)),
              ],
            ),
            const SizedBox(height: 24),

            // Bar Chart Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Borrow Requests', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        barGroups: analytics.monthlyRequests
                            .asMap()
                            .entries
                            .map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value,
                                      color: AppColors.primary,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Popular Category Highlight
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Most Popular Category', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(analytics.topCategory, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
