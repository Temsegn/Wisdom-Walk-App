import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/providers/user_provider.dart';
import 'package:wisdomwalk/themes/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('ProfileScreen init with userId: ${widget.userId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (widget.userId != null && widget.userId!.isNotEmpty) {
        userProvider.fetchUserById(
          context: context,
          userId: widget.userId!,
          forceRefresh: true,
          skipRedirect: true,
        );
      } else {
        debugPrint('Invalid userId, redirecting to /dashboard');
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.viewedUser;

    if (widget.userId == null || widget.userId!.isEmpty) {
      debugPrint('ProfileScreen build: Invalid userId: ${widget.userId}');
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: const Center(
          child: Text(
            'Invalid user ID',
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body:
          userProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null || user.id.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userProvider.error != null
                          ? userProvider.error!.contains('404')
                              ? 'User not found'
                              : userProvider.error!
                          : 'No profile data available',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        debugPrint(
                          'Retry fetchUserById for userId: ${widget.userId}',
                        );
                        userProvider.fetchUserById(
                          context: context,
                          userId: widget.userId!,
                          forceRefresh: true,
                          skipRedirect: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.go('/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Back to Dashboard'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                              user.avatarUrl != null
                                  ? NetworkImage(
                                    '${user.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
                                  )
                                  : null,
                          child:
                              user.avatarUrl == null
                                  ? Text(
                                    user.initials,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                        ),
                        if (user.isVerified)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user.displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Location
                    if (user.city != null || user.country != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${user.city ?? ''}${user.city != null && user.country != null ? ', ' : ''}${user.country ?? ''}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    // Wisdom Circle Interests
                    if (user.wisdomCircleInterests.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Interests',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                user.wisdomCircleInterests
                                    .map(
                                      (interest) => Chip(
                                        label: Text(interest),
                                        backgroundColor: AppTheme.lightTaupe
                                            .withOpacity(0.2),
                                        labelStyle: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
