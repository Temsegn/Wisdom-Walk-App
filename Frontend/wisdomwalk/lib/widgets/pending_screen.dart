// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:lottie/lottie.dart';
// import '../providers/user_provider.dart';

// class PendingScreen extends StatefulWidget {
//   const PendingScreen({Key? key}) : super(key: key);

//   @override
//   _PendingScreenState createState() => _PendingScreenState();
// }

// class _PendingScreenState extends State<PendingScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);

//     // Periodically check user status
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     Future.microtask(() async {
//       while (mounted) {
//         final userId = userProvider.userId;
//         if (userId == null) {
//           debugPrint('User ID not found');
//           return;
//         }
//         await userProvider.fetchCurrentUser(forceRefresh: true);
//         if (userProvider.currentUser.isVerified &&
//             !userProvider.currentUser.isBlocked) {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/dashboard',
//             (route) => false,
//           );
//           break;
//         }
//         await Future.delayed(const Duration(seconds: 10));
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.blue.shade300, Colors.purple.shade300],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Lottie.asset(
//                   'assets/pending_animation.json',
//                   width: 200,
//                   height: 200,
//                   fit: BoxFit.contain,
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Account Verification Pending',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'You are not verified to do this task. Please wait until we approve your account (48 hours).',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                     color: Colors.white70,
//                     fontSize: 16,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),
//                 FadeTransition(
//                   opacity: _controller,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Text(
//                       'We\'re reviewing your account. You\'ll be redirected to the dashboard once approved.',
//                       style: TextStyle(color: Colors.white, fontSize: 14),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({Key? key}) : super(key: key);

  @override
  _PendingScreenState createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPolling = true;
  static const int _maxRetries = 3;
  static const Duration _pollInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _startPolling();
  }

  void _startPolling() {
    Future.microtask(() async {
      int retryCount = 0;
      while (_isPolling && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (!authProvider.isAuthenticated) {
          debugPrint('User not authenticated, redirecting to login');
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
          break;
        }

        try {
          await userProvider.fetchCurrentUser(
            forceRefresh: true,
            context: context,
          );
          debugPrint(
            'PendingScreen: isVerified=${userProvider.currentUser.isVerified}, '
            'isBlocked=${userProvider.currentUser.isBlocked}, verificationStatus=${userProvider.currentUser.verificationStatus}',
          );

          if (userProvider.currentUser.isVerified &&
              !userProvider.currentUser.isBlocked) {
            debugPrint('User admin-verified, redirecting to dashboard');
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (route) => false,
              );
            }
            break;
          }

          if (userProvider.error != null) {
            debugPrint('Error fetching user status: ${userProvider.error}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${userProvider.error}')),
              );
            }
            retryCount++;
            if (retryCount >= _maxRetries) {
              debugPrint('Max retries reached, redirecting to login');
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
              break;
            }
          } else {
            retryCount = 0;
          }
        } catch (e) {
          debugPrint('Unexpected error in polling: $e');
          retryCount++;
          if (retryCount >= _maxRetries) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to check verification status'),
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
            break;
          }
        }

        await Future.delayed(_pollInterval);
      }
    });
  }

  @override
  void dispose() {
    _isPolling = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/pending_animation.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  'Account Verification Pending',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  userProvider.currentUser.verificationStatus == 'rejected'
                      ? 'Your account verification was rejected. Please contact support.'
                      : 'Your account is under review. This may take up to 48 hours.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _controller,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userProvider.currentUser.verificationStatus == 'rejected'
                          ? 'Verification rejected. Awaiting further action.'
                          : 'We\'re reviewing your account. You\'ll be redirected to the dashboard once approved.',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    _isPolling = false;
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).logout(context: context);
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
