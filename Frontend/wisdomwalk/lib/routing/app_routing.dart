// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:wisdomwalk/providers/auth_provider.dart';
// import 'package:wisdomwalk/views/dashboared/dashboard_screen.dart';
// import 'package:wisdomwalk/views/login/welcome_screen.dart';
// import 'package:wisdomwalk/views/login/login_screen.dart';
// import 'package:wisdomwalk/views/login/multi_step_registration.dart';
// import 'package:wisdomwalk/views/login/otp-screen.dart';
// import 'package:wisdomwalk/views/login/forgot_password_screen.dart';
// import 'package:wisdomwalk/views/login/reset_password_screen.dart';
// import 'package:wisdomwalk/views/prayer_wall/prayer_detail_screen.dart';
// import 'package:wisdomwalk/views/anonymous_share/anonymous_share_detail_screen.dart';
// import 'package:wisdomwalk/views/her_move/add_location_request_screen.dart';
// import 'package:wisdomwalk/views/her_move/location_request_detail_screen.dart';
// import 'package:wisdomwalk/views/her_move/search_screen.dart';
// import 'package:wisdomwalk/views/wisdom_circles/wisdom_circle_detail_screen.dart';
// import 'package:wisdomwalk/views/profile/profile_screen.dart';
// import 'package:wisdomwalk/views/settings/settings_screen.dart';
// import 'package:wisdomwalk/views/notifications/notifications_screen.dart';
// import 'package:wisdomwalk/widgets/pending_screen.dart';

// class AppRouter {
//   static final GoRouter router = GoRouter(
//     initialLocation: '/',
//     routes: [
//       GoRoute(
//         path: '/',
//         builder: (context, state) {
//           final authProvider = Provider.of<AuthProvider>(context);
//           print(
//             'Root route: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}',
//           );
//           return authProvider.isLoading
//               ? const Scaffold(body: Center(child: CircularProgressIndicator()))
//               : authProvider.isAuthenticated
//               ? const DashboardScreen()
//               : const WelcomeScreen();
//         },
//       ),
//       GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
//       GoRoute(
//         path: '/register',
//         builder: (context, state) => const MultiStepRegistration(),
//       ),
//       GoRoute(
//         path: '/otp',
//         builder: (context, state) {
//           final Map<String, dynamic> extra =
//               state.extra as Map<String, dynamic>? ?? {};
//           return OtpScreen(email: extra['email'] as String? ?? '');
//         },
//       ),
//       GoRoute(
//         path: '/forgot-password',
//         builder: (context, state) => const ForgotPasswordScreen(),
//       ),
//       GoRoute(
//         path: '/reset-password',
//         builder: (context, state) {
//           final Map<String, dynamic> extra =
//               state.extra as Map<String, dynamic>? ?? {};
//           return ResetPasswordScreen(
//             email: extra['email'] as String? ?? '',
//             otp: extra['otp'] as String? ?? '',
//           );
//         },
//       ),
//       GoRoute(
//         path: '/notifications',
//         builder: (context, state) => const NotificationsScreen(),
//       ),
//       GoRoute(
//         path: '/her-move-search',
//         builder: (context, state) => const SearchScreen(),
//       ),
//       GoRoute(
//         path: '/dashboard',
//         builder: (context, state) => const DashboardScreen(),
//       ),
//       GoRoute(
//         path: '/profile',
//         builder: (context, state) => const ProfileScreen(),
//       ),
//       GoRoute(
//         path: '/settings',
//         builder: (context, state) => const SettingsScreen(),
//       ),
//       GoRoute(
//         path: '/prayer/:id',
//         builder:
//             (context, state) =>
//                 PrayerDetailScreen(prayerId: state.pathParameters['id']!),
//       ),
//       GoRoute(
//         path: '/wisdom-circle/:id',
//         builder:
//             (context, state) =>
//                 WisdomCircleDetailScreen(circleId: state.pathParameters['id']!),
//       ),
//       GoRoute(
//         path: '/anonymous-share/:id',
//         builder:
//             (context, state) => AnonymousShareDetailScreen(
//               shareId: state.pathParameters['id']!,
//             ),
//       ),
//       GoRoute(
//         path: '/location-request/:id',
//         builder:
//             (context, state) => LocationRequestDetailScreen(
//               requestId: state.pathParameters['id']!,
//             ),
//       ),
//       GoRoute(
//         path: '/search-requests',
//         builder: (context, state) => const SearchScreen(),
//       ),
//       GoRoute(
//         path: '/pending-screen',
//         builder: (context, state) => const PendingScreen(),
//       ),
//       GoRoute(
//         path: '/add-location-request',
//         builder: (context, state) => const AddLocationRequestScreen(),
//       ),
//       GoRoute(
//         path: '/location-request-detail/:id',
//         builder:
//             (context, state) => LocationRequestDetailScreen(
//               requestId: state.pathParameters['id']!,
//             ),
//       ),
//     ],
//     redirect: (context, state) async {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final isAuthenticated = authProvider.isAuthenticated;
//       final isLoading = authProvider.isLoading;
//       final path = state.fullPath ?? '/';

//       print(
//         'AppRouter redirect: isLoading=$isLoading, isAuthenticated=$isAuthenticated, path=$path',
//       );

//       if (isLoading) {
//         return null; // Wait for loading to complete
//       }

//       final publicRoutes = [
//         '/',
//         '/login',
//         '/register',
//         '/otp',
//         '/forgot-password',
//         '/reset-password',
//       ];

//       if (!isAuthenticated && !publicRoutes.contains(path)) {
//         print('Redirecting to /welcome (not authenticated)');
//         return '/welcome';
//       }

//       if (isAuthenticated && publicRoutes.contains(path)) {
//         print('Redirecting to /dashboard (authenticated)');
//         return '/dashboard';
//       }

//       return null;
//     },
//     errorBuilder:
//         (context, state) =>
//             Scaffold(body: Center(child: Text('Error: ${state.error}'))),
//   );
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/user_provider.dart';
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
import 'package:wisdomwalk/widgets/pending_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          final authProvider = Provider.of<AuthProvider>(context);
          final userProvider = Provider.of<UserProvider>(context);
          debugPrint(
            'Root route: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}, '
            'isAdminVerified=${userProvider.currentUser.isVerified}, isBlocked=${userProvider.currentUser.isBlocked}',
          );
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!authProvider.isAuthenticated) {
            return const WelcomeScreen();
          }
          if (!userProvider.currentUser.isVerified ||
              userProvider.currentUser.isBlocked) {
            return const PendingScreen();
          }
          return const DashboardScreen();
        },
      ),
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
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final authProvider = Provider.of<AuthProvider>(context);
          final userProvider = Provider.of<UserProvider>(context);
          debugPrint(
            'Dashboard route: isLoading=${authProvider.isLoading}, isAuthenticated=${authProvider.isAuthenticated}, '
            'isAdminVerified=${userProvider.currentUser.isVerified}, isBlocked=${userProvider.currentUser.isBlocked}',
          );
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!authProvider.isAuthenticated) {
            return const WelcomeScreen();
          }
          if (!userProvider.currentUser.isVerified ||
              userProvider.currentUser.isBlocked) {
            return const PendingScreen();
          }
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'];
          debugPrint('AppRouter: Navigating to /profile/$userId');
          return ProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
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
        path: '/pending-screen',
        builder: (context, state) => const PendingScreen(),
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
    redirect: (context, state) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;
      final path = state.fullPath ?? '/';

      debugPrint(
        'AppRouter redirect: isLoading=$isLoading, isAuthenticated=$isAuthenticated, '
        'isAdminVerified=${userProvider.currentUser.isVerified}, isBlocked=${userProvider.currentUser.isBlocked}, path=$path',
      );

      if (isLoading) {
        return null;
      }

      final publicRoutes = [
        '/',
        '/login',
        '/register',
        '/otp',
        '/forgot-password',
        '/reset-password',
      ];

      if (!isAuthenticated && !publicRoutes.contains(path)) {
        debugPrint('Redirecting to /login (not authenticated)');
        return '/login';
      }

      if (isAuthenticated && publicRoutes.contains(path)) {
        if (!userProvider.currentUser.isVerified ||
            userProvider.currentUser.isBlocked) {
          debugPrint(
            'Redirecting to /pending-screen (authenticated but not admin-verified or blocked)',
          );
          return '/pending-screen';
        }
        debugPrint(
          'Redirecting to /dashboard (authenticated and admin-verified)',
        );
        return '/dashboard';
      }

      if (isAuthenticated &&
          (!userProvider.currentUser.isVerified ||
              userProvider.currentUser.isBlocked)) {
        debugPrint(
          'Redirecting to /pending-screen (not admin-verified or blocked)',
        );
        return '/pending-screen';
      }

      return null;
    },
    errorBuilder:
        (context, state) =>
            Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}
