import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:intl/intl.dart';

class PrayerCard extends StatelessWidget {
  final PrayerModel prayer;
  final String currentUserId;
  final VoidCallback onTap;

  const PrayerCard({
    Key? key,
    required this.prayer,
    required this.currentUserId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPraying = prayer.prayingUsers.contains(currentUserId);
    final timeAgo = _getTimeAgo(prayer.createdAt);

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
                _buildAvatar(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.isAnonymous
                            ? 'Anonymous Sister'
                            : prayer.userName ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(prayer.content, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
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
                    const SizedBox(width: 2),
                    Text(
                      '${prayer.prayingUsers.length} praying',
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
                    const SizedBox(width: 2),
                    Text(
                      '${prayer.comments.length} comments',
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

  Widget _buildAvatar(BuildContext context) {
    if (prayer.isAnonymous || prayer.userAvatar == null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(prayer.userAvatar!),
      );
    }
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
}
