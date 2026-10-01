import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/views/email_verification_view.dart';

import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/views/home_view.dart';
import '../../features/profile/views/my_listings_view.dart';
import '../../features/profile/views/profile_view.dart';
import '../../features/request/views/requests_view.dart';

import '../../features/analytics/views/analytics_view.dart';
import '../../features/favourites/views/wishlist_view.dart';
import '../../features/notification/views/notification_view.dart';
import '../../features/resource/views/add_listing_view.dart';
import '../../features/resource/views/browse_view.dart';
import '../../features/resource/views/resource_details_view.dart';
import '../../features/search/views/search_view.dart';
import 'app_shell.dart';

import 'route_constants.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.homePath,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated && authState.user != null;
      final isAuthRoute = state.matchedLocation == RouteConstants.loginPath ||
          state.matchedLocation == RouteConstants.registerPath ||
          state.matchedLocation == RouteConstants.forgotPasswordPath;

      if (!isAuthenticated && !isAuthRoute) {
        return RouteConstants.loginPath;
      }

      if (isAuthenticated && isAuthRoute) {
        return RouteConstants.homePath;
      }

      return null;
    },
    routes: [
      // Authentication Routes
      GoRoute(
        path: RouteConstants.loginPath,
        name: RouteConstants.loginName,
        builder: (context, state) => LoginView(
          onNavigateToRegister: () => context.goNamed(RouteConstants.registerName),
          onNavigateToForgotPassword: () => context.goNamed(RouteConstants.forgotPasswordName),
          onLoginSuccess: () => context.goNamed(RouteConstants.homeName),
        ),
      ),
      GoRoute(
        path: RouteConstants.registerPath,
        name: RouteConstants.registerName,
        builder: (context, state) => RegisterView(
          onNavigateToLogin: () => context.goNamed(RouteConstants.loginName),
          onRegisterSuccess: () => context.goNamed(RouteConstants.emailVerificationName),
        ),
      ),
      GoRoute(
        path: RouteConstants.forgotPasswordPath,
        name: RouteConstants.forgotPasswordName,
        builder: (context, state) => ForgotPasswordView(
          onBackToLogin: () => context.goNamed(RouteConstants.loginName),
        ),
      ),
      GoRoute(
        path: RouteConstants.emailVerificationPath,
        name: RouteConstants.emailVerificationName,
        builder: (context, state) => EmailVerificationView(
          onContinue: () => context.goNamed(RouteConstants.homeName),
        ),
      ),

      // Resource Detail & Upload Modal Routes
      GoRoute(
        path: RouteConstants.addListingPath,
        name: RouteConstants.addListingName,
        builder: (context, state) => const AddListingView(),
      ),
      GoRoute(
        path: RouteConstants.searchPath,
        name: RouteConstants.searchName,
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: RouteConstants.myListingsPath,
        name: RouteConstants.myListingsName,
        builder: (context, state) => const MyListingsView(),
      ),
      GoRoute(
        path: RouteConstants.wishlistPath,
        name: RouteConstants.wishlistName,
        builder: (context, state) => const WishlistView(),
      ),
      GoRoute(
        path: RouteConstants.notificationPath,
        name: RouteConstants.notificationName,
        builder: (context, state) => const NotificationView(),
      ),
      GoRoute(
        path: RouteConstants.analyticsPath,
        name: RouteConstants.analyticsName,
        builder: (context, state) => const AnalyticsView(),
      ),


      GoRoute(
        path: RouteConstants.resourceDetailsPath,
        name: RouteConstants.resourceDetailsName,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ResourceDetailsView(resourceId: id);
        },
      ),

      // Main App Shell Route (Tabbed Navigation)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.homePath,
                name: RouteConstants.homeName,
                builder: (context, state) => const HomeView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.browsePath,
                name: RouteConstants.browseName,
                builder: (context, state) => const BrowseView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.requestsPath,
                name: RouteConstants.requestsName,
                builder: (context, state) => const RequestsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.profilePath,
                name: RouteConstants.profileName,
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
