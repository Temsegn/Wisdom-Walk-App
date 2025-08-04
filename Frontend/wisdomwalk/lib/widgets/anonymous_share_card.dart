import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/anonymous_share_model.dart';
import '../providers/anonymous_share_provider.dart';

class AnonymousShareCard extends StatefulWidget {
  final AnonymousShareModel share;
  final String currentUserId;
  final VoidCallback onTap;

  const AnonymousShareCard({
    Key? key,
    required this.share,
    required this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnonymousShareCardState createState() => _AnonymousShareCardState();
}

class _AnonymousShareCardState extends State<AnonymousShareCard> {
  int visibleComments = 6;
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _showCommentSection = {};

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
    return Container(
      decoration: BoxDecoration(
        gradient:
            isActive
                ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                : LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isActive ? Colors.white : color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Report Post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for reporting this post.',
                style: TextStyle(color: Color(0xFF636E72)),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[50]!, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF74B9FF).withOpacity(0.3),
                  ),
                ),
                child: TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Enter reason (10-1000 characters)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                  maxLength: 1000,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF636E72)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE17055), Color(0xFFD63031)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final reason = reasonController.text.trim();
                  if (reason.length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Reason must be at least 10 characters',
                        ),
                        backgroundColor: const Color(0xFFD63031),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                        backgroundColor:
                            success
                                ? const Color(0xFFE17055)
                                : const Color(0xFFD63031),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Report',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
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
  void initState() {
    super.initState();
    _commentControllers[widget.share.id] = TextEditingController();
    _showCommentSection[widget.share.id] = false;
  }

  @override
  void dispose() {
    _commentControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final share = widget.share;
    final userId = widget.currentUserId;
    final commentController = _commentControllers[share.id]!;
    final showCommentSection = _showCommentSection[share.id]!;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1DA1F2), Color(0xFF0984E3)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Anonymous Sister',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getTypeColor(share.category),
                                      _getTypeColor(
                                        share.category,
                                      ).withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
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
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatTimeAgo(share.createdAt),
                                style: const TextStyle(
                                  color: Color(0xFF636E72),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  share.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF636E72),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
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
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.network(
                                    img['url']!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon:
                            share.prayers.any(
                                  (prayer) => prayer['user'] == userId,
                                )
                                ? Icons.volunteer_activism
                                : Icons.volunteer_activism_outlined,
                        label: '(${share.prayerCount})',
                        color: const Color(0xFF9C27B0),
                        isActive: share.prayers.any(
                          (prayer) => prayer['user'] == userId,
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (userId == 'current_user') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please log in to pray for this share',
                                ),
                                backgroundColor: const Color(0xFFD63031),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          final shareProvider =
                              Provider.of<AnonymousShareProvider>(
                                context,
                                listen: false,
                              );
                          final success = await shareProvider.togglePraying(
                            shareId: share.id,
                            userId: userId,
                            message: 'Praying for you ❤️',
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  share.prayers.any(
                                        (prayer) => prayer['user'] == userId,
                                      )
                                      ? 'Removed from praying list'
                                      : 'You are now praying for this share 🙏',
                                ),
                                backgroundColor: const Color(0xFF9C27B0),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to toggle praying: ${shareProvider.error ?? 'Unknown error'}',
                                ),
                                backgroundColor: const Color(0xFFD63031),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.comment_outlined,
                        label: '(${share.commentsCount})',
                        color: const Color(0xFF1DA1F2), // X's blue
                        isActive: showCommentSection,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _showCommentSection[share.id] = !showCommentSection;
                            if (!_showCommentSection[share.id]!) {
                              commentController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon:
                            share.likes.contains(userId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                        label: '(${share.heartCount})',
                        color: const Color(0xFF2196F3),
                        isActive: share.likes.contains(userId),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (userId == 'current_user') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please log in to heart this share',
                                ),
                                backgroundColor: const Color(0xFFD63031),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          final shareProvider =
                              Provider.of<AnonymousShareProvider>(
                                context,
                                listen: false,
                              );
                          final success = await shareProvider.toggleHeart(
                            shareId: share.id,
                            userId: userId,
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  share.likes.contains(userId)
                                      ? 'Removed heart'
                                      : 'Share hearted! ❤️',
                                ),
                                backgroundColor: const Color(0xFF2196F3),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to toggle heart: ${shareProvider.error ?? 'Unknown error'}',
                                ),
                                backgroundColor: const Color(0xFFD63031),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),

                      _buildActionButton(
                        icon:
                            share.virtualHugs.any(
                                  (hug) => hug['user'] == userId,
                                )
                                ? Icons.favorite
                                : Icons.favorite_border,
                        label: '(${share.hugCount})',
                        color: const Color(0xFFE91E63),
                        isActive: share.virtualHugs.any(
                          (hug) => hug['user'] == userId,
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (userId == 'current_user') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please log in to send a virtual hug',
                                ),
                                backgroundColor: const Color(0xFFD63031),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }
                          final shareProvider =
                              Provider.of<AnonymousShareProvider>(
                                context,
                                listen: false,
                              );
                          final success = await shareProvider.sendVirtualHug(
                            shareId: share.id,
                            userId: userId,
                            scripture: '',
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Virtual hug sent! 🤗'),
                                backgroundColor: const Color(0xFFE91E63),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to send virtual hug: ${shareProvider.error ?? 'Unknown error'}',
                                ),
                                backgroundColor: const Color(0xFFD63031),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (showCommentSection) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Colors.grey[100], // Light gray like X's reply field
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: 'Reply to this share…',
                              hintStyle: TextStyle(
                                color: Color(0xFF657786),
                              ), // X's hint color
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null, // Expand as needed
                            minLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF14171A), // X's text color
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1DA1F2), // X's blue
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x331DA1F2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () async {
                              if (userId == 'current_user') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Please log in to comment on this share',
                                    ),
                                    backgroundColor: const Color(0xFFD63031),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final content = commentController.text.trim();
                              if (content.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Comment cannot be empty',
                                    ),
                                    backgroundColor: const Color(0xFFD63031),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final shareProvider =
                                  Provider.of<AnonymousShareProvider>(
                                    context,
                                    listen: false,
                                  );
                              final success = await shareProvider.addComment(
                                shareId: share.id,
                                userId: userId,
                                content: content,
                              );
                              if (success && context.mounted) {
                                commentController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Comment added successfully!',
                                    ),
                                    backgroundColor: const Color(0xFF1DA1F2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to add comment: ${shareProvider.error ?? 'Unknown error'}',
                                    ),
                                    backgroundColor: const Color(0xFFD63031),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[200]!, Colors.grey[100]!],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (share.comments.isNotEmpty)
                    ...share.comments
                        .take(visibleComments)
                        .map(
                          (comment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1DA1F2),
                                        Color(0xFF0984E3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white,
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
                                          fontSize: 14,
                                          color: Color(
                                            0xFF14171A,
                                          ), // X's text color
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.content,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(
                                            0xFF657786,
                                          ), // X's secondary text
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                  else
                    const Text(
                      'see more comments  on the details page',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF657786), // X's secondary text
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (share.comments.length > visibleComments)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: _showMoreComments,
                        child: Text(
                          'See More (${share.comments.length - visibleComments} more)',
                          style: const TextStyle(
                            color: Color(0xFF1DA1F2), // X's blue
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  share.isReported
                      ? Icons.report_problem
                      : Icons.report_problem_outlined,
                  color:
                      share.isReported
                          ? const Color(0xFFE17055)
                          : const Color(0xFF636E72),
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (userId == 'current_user') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Please log in to report this post',
                        ),
                        backgroundColor: const Color(0xFFD63031),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }
                  _showReportDialog(context, share, userId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
