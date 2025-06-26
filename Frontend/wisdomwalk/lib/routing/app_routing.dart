import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/views/dashboared/dashboard_screen.dart';
import 'package:wisdomwalk/views/login/welcome_screen.dart';
import 'package:wisdomwalk/views/login/login_screen.dart';
import 'package:wisdomwalk/views/login/multi_step_registration.dart';
import 'package:wisdomwalk/views/login/otp-screen.dart';
import 'package:wisdomwalk/views/login/forgot_password_screen.dart';
import 'package:wisdomwalk/views/login/reset_password_screen.dart';
import 'package:wisdomwalk/views/prayer_wall/prayer_detail_screen.dart';
import 'package:wisdomwalk/views/anonymous_share/anonymous_share_detail_screen.dart';
import 'package:wisdomwalk/views/her_move/add_location_request_screen.dart';
import 'package:wisdomwalk/views/her_move/location_request_detail_screen.dart';
import 'package:wisdomwalk/views/her_move/search_screen.dart';
import 'package:wisdomwalk/views/wisdom_circles/wisdom_circle_detail_screen.dart';
import 'package:wisdomwalk/views/profile/profile_screen.dart';
import 'package:wisdomwalk/views/settings/settings_screen.dart';
import 'package:wisdomwalk/views/notifications/notifications_screen.dart';
//  class AppRouter {
//   static GoRouter createRouter() {
//     return GoRouter(
//       initialLocation: '/welcome',
//       routes: [
//         // Authentication Routes
//         GoRoute(
//           path: '/welcome',
//           builder: (context, state) => const WelcomeScreen(),
//         ),
//         GoRoute(
//           path: '/login',
//           builder: (context, state) => const LoginScreen(),
//         ),
//         GoRoute(
//           path: '/register',
//           builder: (context, state) => const MultiStepRegistration(),
//         ),
//         GoRoute(
//           path: '/otp',
//           builder: (context, state) {
//             final Map<String, dynamic> extra =
//                 state.extra as Map<String, dynamic>? ?? {};
//             return OtpScreen(email: extra['email'] as String? ?? '');
//           },
//         ),
//         GoRoute(
//           path: '/forgot-password',
//           builder: (context, state) => const ForgotPasswordScreen(),
//         ),
//         GoRoute(
//           path: '/reset-password',
//           builder: (context, state) {
//             final email = state.extra as String? ?? '';
//             return ResetPasswordScreen(email: email, otp: '');
//           },
//         ),

//         // Main App Routes
//         GoRoute(
//           path: '/dashboard',
//           builder: (context, state) => const DashboardScreen(),
//         ),
//         GoRoute(
//           path: '/prayer-detail/:prayerId',
//           builder: (context, state) {
//             final prayerId = state.pathParameters['prayerId']!;
//             return PrayerDetailScreen(prayerId: prayerId);
//           },
//         ),
//         GoRoute(
//           path: '/anonymous-share-detail/:shareId',
//           builder: (context, state) {
//             final shareId = state.pathParameters['shareId']!;
//             return AnonymousShareDetailScreen(shareId: shareId);
//           },
//         ),
//         GoRoute(
//           path: '/wisdom-circle-detail/:circleId',
//           builder: (context, state) {
//             final circleId = state.pathParameters['circleId']!;
//             return WisdomCircleDetailScreen(circleId: circleId);
//           },
//         ),

//         // Her Move Routes
//         GoRoute(
//           path: '/add-location-request',
//           builder: (context, state) => const AddLocationRequestScreen(),
//         ),
//         GoRoute(
//           path: '/location-request-detail/:requestId',
//           builder: (context, state) {
//             final requestId = state.pathParameters['requestId']!;
//             return LocationRequestDetailScreen(requestId: requestId);
//           },
//         ),
//         GoRoute(
//           path: '/her-move-search',
//           builder: (context, state) => const SearchScreen(),
//         ),

//         // Notification Routes
//         GoRoute(
//           path: '/notifications',
//           builder: (context, state) => const NotificationsScreen(),
//         ),

//         // Search routes
//         GoRoute(
//           path: '/search',
//           builder: (context, state) => const SearchScreen(),
//         ),

//         // Profile & Settings Routes
//         GoRoute(
//           path: '/profile',
//           builder: (context, state) => const ProfileScreen(),
//         ),
//         GoRoute(
//           path: '/settings',
//           builder: (context, state) => const SettingsScreen(),
//         ),
//       ],
//       redirect: (context, state) {
//         final authProvider = Provider.of<AuthProvider>(context, listen: false);
//         final isAuthenticated = authProvider.isAuthenticated;
//         final isLoading = authProvider.isLoading;

//         // Don't redirect while loading
//         if (isLoading) return null;

//         // Public routes that don't require authentication
//         final publicRoutes = [
//           '/welcome',
//           '/login',
//           '/register',
//           '/otp',
//           '/forgot-password',
//           '/reset-password',
//         ];

//         final isPublicRoute = publicRoutes.contains(state.matchedLocation);

//         // If not authenticated and trying to access private route
//         if (!isAuthenticated && !isPublicRoute) {
//           return '/welcome';
//         }

//         // If authenticated and on public route, redirect to dashboard
//         if (isAuthenticated && isPublicRoute) {
//           return '/dashboard';
//         }

//         return null;
//       },
//     );
//   }
// }

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Authentication routes
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const MultiStepRegistration(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};
          return OtpScreen(email: extra['email'] as String? ?? '');
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            email: extra['email'] as String? ?? '',
            otp: extra['otp'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      GoRoute(
        path: '/her-move-search',
        builder: (context, state) => const SearchScreen(),
      ),

      // Main app routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Feature-specific routes
      GoRoute(
        path: '/prayer/:id',
        builder:
            (context, state) =>
                PrayerDetailScreen(prayerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/wisdom-circle/:id',
        builder:
            (context, state) =>
                WisdomCircleDetailScreen(circleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/anonymous-share/:id',
        builder:
            (context, state) => AnonymousShareDetailScreen(
              shareId: state.pathParameters['id']!,
            ),
      ),
      GoRoute(
        path: '/location-request/:id',
        builder:
            (context, state) => LocationRequestDetailScreen(
              requestId: state.pathParameters['id']!,
            ),
      ),
      GoRoute(
        path: '/search-requests',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/add-location-request',
        builder: (context, state) => const AddLocationRequestScreen(),
      ),
      GoRoute(
        path: '/location-request-detail/:id',
        builder:
            (context, state) => LocationRequestDetailScreen(
              requestId: state.pathParameters['id']!,
            ),
      ),
    ],
  );
}
