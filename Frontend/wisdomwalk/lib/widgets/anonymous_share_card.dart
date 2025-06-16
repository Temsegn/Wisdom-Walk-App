import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:intl/intl.dart';

class AnonymousShareCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasHeart = share.hearts.contains(currentUserId);
    final isPraying = share.prayingUsers.contains(currentUserId);
    final timeAgo = _getTimeAgo(share.createdAt);
    final typeColor = _getTypeColor(share.type);
    final typeIcon = _getTypeIcon(share.type);
    final typeLabel = _getTypeLabel(share.type);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E2DB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(typeIcon, color: typeColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(timeAgo, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              share.content,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color:
                          hasHeart
                              ? Colors.red
                              : Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${share.hearts.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.volunteer_activism,
                      size: 16,
                      color:
                          isPraying
                              ? Theme.of(context).primaryColor
                              : Theme.of(
                                context,
                              ).colorScheme.onBackground.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${share.prayingUsers.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${share.comments.length} comments',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getTypeColor(AnonymousShareType type) {
    switch (type) {
      case AnonymousShareType.confession:
        return Colors.blue;
      case AnonymousShareType.testimony:
        return Colors.green;
      case AnonymousShareType.struggle:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon(AnonymousShareType type) {
    switch (type) {
      case AnonymousShareType.confession:
        return Icons.chat_bubble_outline;
      case AnonymousShareType.testimony:
        return Icons.star_outline;
      case AnonymousShareType.struggle:
        return Icons.healing;
    }
  }

  String _getTypeLabel(AnonymousShareType type) {
    switch (type) {
      case AnonymousShareType.confession:
        return 'Confession';
      case AnonymousShareType.testimony:
        return 'Testimony';
      case AnonymousShareType.struggle:
        return 'Struggle';
    }
  }
}
