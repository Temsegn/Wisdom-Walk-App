import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:intl/intl.dart';

class PrayerDetailScreen extends StatefulWidget {
  final String prayerId;

  const PrayerDetailScreen({Key? key, required this.prayerId})
    : super(key: key);

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final prayers = prayerProvider.prayers;
    final prayer = prayers.firstWhere(
      (p) => p.id == widget.prayerId,
      orElse:
          () => PrayerModel(
            id: '',
            userId: '',
            content: '',
            createdAt: DateTime.now(),
          ),
    );

    if (prayer.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prayer Request')),
        body: const Center(child: Text('Prayer request not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Request')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrayerHeader(context, prayer),
                  const SizedBox(height: 16),
                  _buildPrayerContent(context, prayer),
                  const SizedBox(height: 24),
                  _buildCommentsSection(context, prayer),
                ],
              ),
            ),
          ),
          _buildCommentInput(context, prayerProvider, authProvider),
        ],
      ),
    );
  }

  Widget _buildPrayerHeader(BuildContext context, PrayerModel prayer) {
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');

    return Row(
      children: [
        _buildAvatar(context, prayer),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayer.isAnonymous
                    ? 'Anonymous Sister'
                    : prayer.userName ?? 'Unknown',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                dateFormat.format(prayer.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, PrayerModel prayer) {
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

  Widget _buildPrayerContent(BuildContext context, PrayerModel prayer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(prayer.content, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Widget _buildCommentsSection(BuildContext context, PrayerModel prayer) {
    if (prayer.comments.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.comment_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No comments yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: prayer.comments.length,
          itemBuilder: (context, index) {
            final comment = prayer.comments[index];
            return _buildCommentItem(context, comment);
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(BuildContext context, PrayerComment comment) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentAvatar(context, comment),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.isAnonymous
                          ? 'Anonymous Sister'
                          : comment.userName ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentAvatar(BuildContext context, PrayerComment comment) {
    if (comment.isAnonymous || comment.userAvatar == null) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(comment.userAvatar!),
      );
    }
  }

  Widget _buildCommentInput(
    BuildContext context,
    PrayerProvider prayerProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _isAnonymous,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value ?? false;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              const Text('Comment anonymously'),
            ],
          ),
          Row(
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
                onPressed: () {
                  _submitComment(prayerProvider, authProvider);
                },
                icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitComment(
    PrayerProvider prayerProvider,
    AuthProvider authProvider,
  ) {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      return;
    }

    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    prayerProvider
        .addComment(
          prayerId: widget.prayerId,
          userId: user.id,
          content: comment,
          isAnonymous: _isAnonymous,
          userName: _isAnonymous ? null : user.fullName,
          userAvatar: _isAnonymous ? null : user.avatarUrl,
        )
        .then((success) {
          if (success) {
            _commentController.clear();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(prayerProvider.error ?? 'Failed to add comment'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }
}
