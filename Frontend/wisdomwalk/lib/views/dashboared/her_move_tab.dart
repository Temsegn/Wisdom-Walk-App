import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/notification_provider.dart';
import 'package:intl/intl.dart';

class HerMoveTab extends StatefulWidget {
  const HerMoveTab({Key? key}) : super(key: key);

  @override
  State<HerMoveTab> createState() => _HerMoveTabState();
}

class _HerMoveTabState extends State<HerMoveTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HerMoveProvider>(context, listen: false).fetchRequests();
      final userId =
          Provider.of<AuthProvider>(context, listen: false).currentUser?.id ??
          'current_user';
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Her Move',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  context.push('/notifications');
                },
              ),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.unreadCount > 0) {
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Consumer<HerMoveProvider>(
        builder: (context, herMoveProvider, child) {
          if (herMoveProvider.isLoading && herMoveProvider.requests.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            );
          }

          if (herMoveProvider.error != null &&
              herMoveProvider.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => herMoveProvider.fetchRequests(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (herMoveProvider.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_takeoff, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No travel requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your travel plans or help others',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/add-location-request');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Your Move'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await herMoveProvider.fetchRequests();
            },
            color: const Color(0xFFE91E63),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: herMoveProvider.requests.length,
              itemBuilder: (context, index) {
                final request = herMoveProvider.requests[index];
                final currentUserId =
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).currentUser?.id ??
                    '';
                final isOwnRequest = request.userId == currentUserId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with user info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage:
                                  request.userAvatar != null
                                      ? NetworkImage(request.userAvatar!)
                                      : null,
                              backgroundColor: const Color(
                                0xFFE91E63,
                              ).withOpacity(0.2),
                              child:
                                  request.userAvatar == null
                                      ? const Icon(
                                        Icons.person,
                                        color: Color(0xFFE91E63),
                                        size: 16,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _getTimeAgo(request.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isOwnRequest)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE91E63,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Your Request',
                                  style: TextStyle(
                                    color: Color(0xFFE91E63),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Location info
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFE91E63),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${request.city}, ${request.country}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Move date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Moving ${DateFormat('MMM d, yyyy').format(request.moveDate)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Spacer(),
                            if (request.responses.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.comment,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${request.responses.length}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          request.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.push(
                                    '/location-request-detail/${request.id}',
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFE91E63),
                                  ),
                                  foregroundColor: const Color(0xFFE91E63),
                                ),
                                child: const Text('View Details'),
                              ),
                            ),
                            if (!isOwnRequest) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.push(
                                      '/location-request-detail/${request.id}',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE91E63),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Offer Help'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-location-request');
        },
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
