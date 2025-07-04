import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';

class AnonymousShareDetailScreen extends StatefulWidget {
  final String shareId;

  const AnonymousShareDetailScreen({Key? key, required this.shareId})
    : super(key: key);

  @override
  State<AnonymousShareDetailScreen> createState() =>
      _AnonymousShareDetailScreenState();
}

class _AnonymousShareDetailScreenState
    extends State<AnonymousShareDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final LocalStorageService _localStorageService = LocalStorageService();
  int visibleComments = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnonymousShareProvider>(
        context,
        listen: false,
      ).fetchShareDetails(widget.shareId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showMoreComments() {
    setState(() {
      visibleComments += 5;
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isActive ? color : color.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : color.withOpacity(0.7),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(
    BuildContext context,
    AnonymousShareModel share,
    String userId,
  ) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for reporting this post.'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'Enter reason (10-1000 characters)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 1000,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reason must be at least 10 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final shareProvider = Provider.of<AnonymousShareProvider>(
                  context,
                  listen: false,
                );
                final success = await shareProvider.reportShare(
                  shareId: share.id,
                  userId: userId,
                  reason: reason,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Post reported successfully 🚨'
                            : 'Failed to report post',
                      ),
                      backgroundColor: success ? Colors.red : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportButton(AnonymousShareModel share, String userId) {
    return IconButton(
      icon: Icon(
        share.isReported ? Icons.report_problem : Icons.report_problem_outlined,
        color: share.isReported ? Colors.red : Colors.grey,
        size: 20,
      ),
      onPressed: () async {
        final token = await _localStorageService.getAuthToken();
        if (userId == 'current_user' || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to report this post'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        _showReportDialog(context, share, userId);
      },
    );
  }

  Color _getTypeColor(AnonymousShareType? type) {
    switch (type) {
      case AnonymousShareType.confession:
        return const Color(0xFF9C27B0);
      case AnonymousShareType.testimony:
        return const Color(0xFF4CAF50);
      case AnonymousShareType.struggle:
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareProvider = Provider.of<AnonymousShareProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final share = shareProvider.selectedShare;
    final isLoading = shareProvider.isLoading;
    final error = shareProvider.error;
    final userId = authProvider.currentUser?.id ?? 'current_user';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          share != null
              ? 'Anonymous ${share.category?.toString().split('.').last.toUpperCase() ?? 'Share'}'
              : 'Anonymous Share',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading share details',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(error, style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        shareProvider.fetchShareDetails(widget.shareId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : share == null
              ? const Center(child: Text('Share not found'))
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey[300],
                                      radius: 25,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Anonymous Sister',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getTypeColor(
                                                    share.category,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  share.category
                                                          ?.toString()
                                                          .split('.')
                                                          .last
                                                          .toUpperCase() ??
                                                      'SHARE',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatTimeAgo(share.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (share.title != null &&
                                    share.title!.isNotEmpty)
                                  Text(
                                    share.title!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                if (share.title != null &&
                                    share.title!.isNotEmpty)
                                  const SizedBox(height: 8),
                                Text(
                                  share.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                if (share.images.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                          share.images
                                              .map(
                                                (img) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 8,
                                                      ),
                                                  child: Image.network(
                                                    img['url']!,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.error,
                                                        ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildActionButton(
                                        icon:
                                            share.prayers.any(
                                                  (prayer) =>
                                                      prayer['user'] == userId,
                                                )
                                                ? Icons.volunteer_activism
                                                : Icons
                                                    .volunteer_activism_outlined,
                                        label: ' (${share.prayerCount})',
                                        color: const Color(0xFF9C27B0),
                                        isActive: share.prayers.any(
                                          (prayer) => prayer['user'] == userId,
                                        ),
                                        onPressed: () async {
                                          final token =
                                              await _localStorageService
                                                  .getAuthToken();
                                          if (userId == 'current_user' ||
                                              token == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please log in to pray for this share',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          final success = await shareProvider
                                              .togglePraying(
                                                shareId: share.id,
                                                userId: userId,
                                                message: 'Praying for you ❤️',
                                              );
                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  share.prayers.any(
                                                        (prayer) =>
                                                            prayer['user'] ==
                                                            userId,
                                                      )
                                                      ? 'Removed from praying list'
                                                      : 'You are now praying for this share 🙏',
                                                ),
                                                backgroundColor: const Color(
                                                  0xFF9C27B0,
                                                ),
                                              ),
                                            );
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to toggle praying: ${shareProvider.error ?? 'Unknown error'}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 7),
                                      _buildActionButton(
                                        icon: Icons.comment_outlined,
                                        label: '(${share.commentsCount})',
                                        color: const Color(0xFF2196F3),
                                        isActive: share.comments.any(
                                          (comment) => comment.userId == userId,
                                        ),
                                        onPressed: () {
                                          if (userId == 'current_user') {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please log in to comment on this share',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          _commentController.clear();
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(FocusNode());
                                        },
                                      ),
                                      const SizedBox(width: 7),
                                      _buildActionButton(
                                        icon:
                                            share.likes.contains(userId)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                        label: '(${share.heartCount})',
                                        color: const Color(0xFF2196F3),
                                        isActive: share.likes.contains(userId),
                                        onPressed: () async {
                                          final token =
                                              await _localStorageService
                                                  .getAuthToken();
                                          if (userId == 'current_user' ||
                                              token == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please log in to heart this share',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          final success = await shareProvider
                                              .toggleHeart(
                                                shareId: share.id,
                                                userId: userId,
                                              );
                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  share.likes.contains(userId)
                                                      ? 'Removed heart'
                                                      : 'Share hearted! ❤️',
                                                ),
                                                backgroundColor: const Color(
                                                  0xFF2196F3,
                                                ),
                                              ),
                                            );
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to toggle heart: ${shareProvider.error ?? 'Unknown error'}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 7),
                                      _buildActionButton(
                                        icon: Icons.chat_outlined,
                                        label: 'Chat',
                                        color: const Color(0xFF4CAF50),
                                        isActive: false,
                                        onPressed: () {
                                          context.push('/chat/${share.id}');
                                        },
                                      ),
                                      const SizedBox(width: 7),
                                      _buildActionButton(
                                        icon:
                                            share.virtualHugs.any(
                                                  (hug) =>
                                                      hug['user'] == userId,
                                                )
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                        label: '(${share.hugCount})',
                                        color: const Color(0xFFE91E63),
                                        isActive: share.virtualHugs.any(
                                          (hug) => hug['user'] == userId,
                                        ),
                                        onPressed: () async {
                                          final token =
                                              await _localStorageService
                                                  .getAuthToken();
                                          if (userId == 'current_user' ||
                                              token == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please log in to send a virtual hug',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          final success = await shareProvider
                                              .sendVirtualHug(
                                                shareId: share.id,
                                                userId: userId,
                                                scripture: '',
                                              );
                                          if (success && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Virtual hug sent! 🤗',
                                                ),
                                                backgroundColor: Color(
                                                  0xFFE91E63,
                                                ),
                                              ),
                                            );
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Failed to send virtual hug: ${shareProvider.error ?? 'Unknown error'}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (share.comments.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Divider(),
                                      ...share.comments
                                          .take(visibleComments)
                                          .map(
                                            (comment) => Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.person,
                                                      size: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          comment.userName ??
                                                              'Anonymous Sister',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                        Text(
                                                          comment.content,
                                                          style: const TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        Text(
                                                          _formatTimeAgo(
                                                            comment.createdAt,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      if (share.comments.length >
                                          visibleComments)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: TextButton(
                                            onPressed: _showMoreComments,
                                            child: Text(
                                              'See More (${share.comments.length - visibleComments} more)',
                                              style: const TextStyle(
                                                color: Color(0xFF2196F3),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: _buildReportButton(share, userId),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color:
                              Theme.of(context).dividerTheme.color ??
                              Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            final comment = _commentController.text.trim();
                            if (comment.isEmpty) return;

                            final token =
                                await _localStorageService.getAuthToken();
                            if (userId == 'current_user' || token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please log in to comment'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final success = await shareProvider.addComment(
                              shareId: widget.shareId,
                              userId: userId,
                              content: comment,
                            );

                            if (success && context.mounted) {
                              _commentController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Comment added successfully!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    shareProvider.error ??
                                        'Failed to add comment',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
