import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/router/route_constants.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state_view.dart';

import '../../auth/providers/auth_provider.dart';
import '../../request/providers/request_provider.dart';
import '../../resource/providers/resource_provider.dart';
import '../widgets/edit_profile_dialog.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Delete Account Permanently?'),
        content: const Text(
          'This will permanently delete your authentication credentials, profile document, uploaded listings, and borrowing history from Firebase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(authNotifierProvider.notifier).deleteAccount();
              if (context.mounted && success) {
                context.goNamed(RouteConstants.loginName);
              }
            },
            child: const Text('Delete Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out of your campus account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.goNamed(RouteConstants.loginName);
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
      ),
      children: [
        const SizedBox(height: 12),
        const Text(
          'Campus Resource Sharing Marketplace is developed exclusively for college students to share, borrow, rent, sell, and request academic resources within their campus.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const EmptyStateView(
          icon: Icons.person_outline_rounded,
          title: 'Sign In Required',
          description: 'Sign in to access your student profile, inventory stats, and settings.',
        ),
      );
    }

    final allResourcesAsync = ref.watch(allResourcesStreamProvider);
    final sentRequestsAsync = ref.watch(sentRequestsStreamProvider(user.id));

    final myItemsCount = allResourcesAsync.when(
      data: (list) => list.where((i) => i.ownerId == user.id).length,
      loading: () => user.resourcesUploaded,
      error: (_, _) => user.resourcesUploaded,
    );

    final sentCount = sentRequestsAsync.when(
      data: (list) => list.length,
      loading: () => user.resourcesBorrowed,
      error: (_, _) => user.resourcesBorrowed,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.accent),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditProfileDialog(user: user),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Cover & Avatar Banner Card
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Cover Banner Background
                    Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -32),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.cardDark,
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      user.name,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, size: 20, color: Colors.white),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        user.department,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        user.year,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
                                  const SizedBox(width: 4),
                                  Text('${user.rating} Rating', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Text('Joined ${Formatters.formatDate(user.joinedAt)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Student Bio
              if (user.bio.isNotEmpty) ...[
                Text('Bio', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(user.bio, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
              ],

              // Achievements & Badges List
              Text('Achievements & Badges 🏆', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: user.achievements.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final badge = user.achievements[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Activity Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, 'My Listings', '$myItemsCount', Icons.inventory_2_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(context, 'Requests Sent', '$sentCount', Icons.swap_horiz_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(context, 'Completed', '${user.completedTransactions}', Icons.check_circle_outline_rounded)),
                ],
              ),
              const SizedBox(height: 24),

              // Menu Settings Options
              _buildMenuTile(
                context,
                icon: Icons.favorite_border_rounded,
                title: 'Saved Wishlist',
                subtitle: 'View your favourited items and saved resources',
                onTap: () => context.pushNamed(RouteConstants.wishlistName),
              ),
              _buildMenuTile(
                context,
                icon: Icons.notifications_none_rounded,
                title: 'Notification Center',
                subtitle: 'Check real-time borrow & handover alerts',
                onTap: () => context.pushNamed(RouteConstants.notificationName),
              ),
              _buildMenuTile(
                context,
                icon: Icons.bar_chart_rounded,
                title: 'Campus Analytics Dashboard',
                subtitle: 'View borrowing trends, activity & charts',
                onTap: () => context.pushNamed(RouteConstants.analyticsName),
              ),
              _buildMenuTile(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'My Inventory Listings',
                subtitle: 'Manage your active shared & rented items',
                onTap: () => context.pushNamed(RouteConstants.myListingsName),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final themeMode = ref.watch(themeNotifierProvider);
                  final isDark = themeMode == ThemeMode.dark;
                  return _buildMenuTile(
                    context,
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    title: 'Dark Mode Theme',
                    subtitle: isDark ? 'Currently using Dark Theme' : 'Currently using Light Theme',
                    trailingWidget: Switch(
                      value: isDark,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(themeNotifierProvider.notifier).setThemeMode(
                          val ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                    onTap: () {
                      ref.read(themeNotifierProvider.notifier).toggleDarkLight();
                    },
                  );
                },
              ),
              _buildMenuTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'About Campus Marketplace',
                subtitle: 'App version, license, and campus vision',
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: 14),

              // Sign Out Tile
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Log out of your campus account'),
                  onTap: () => _showSignOutDialog(context, ref),
                ),
              ),

              // Delete Account Tile
              Container(
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                  title: const Text(
                    'Delete Account Permanently',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Permanently remove credentials & listings'),
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
          trailing: trailingWidget ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryDark),
        ),
      ),
    );
  }
}
