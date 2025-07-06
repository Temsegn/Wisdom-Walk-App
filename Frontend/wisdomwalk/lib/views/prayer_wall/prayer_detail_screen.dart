import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:intl/intl.dart';

class PrayerDetailScreen extends StatefulWidget {
  final String prayerId;

  const PrayerDetailScreen({Key? key, required this.prayerId}) : super(key: key);

  @override
  State<PrayerDetailScreen> createState() => _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends State<PrayerDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final prayers = prayerProvider.prayers;
    final prayer = prayers.firstWhere(
      (p) => p.id == widget.prayerId,
      orElse: () => PrayerModel(
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
      appBar: AppBar(
        title: const Text('Prayer Request'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPrayerHeader(context, prayer),
                        const SizedBox(height: 16),
                        _buildPrayerContent(context, prayer),
                        const SizedBox(height: 24),
                        Text(
                          'Comments',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                      ],
                    ),
                  ),
                ),
                if (prayer.comments.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mode_comment_outlined,
                            size: 48,
                            color: colors.outline.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No comments yet\nBe the first to pray for this request',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment = prayer.comments[index];
                        return _buildCommentItem(context, comment);
                      },
                      childCount: prayer.comments.length,
                    ),
                  ),
              ],
            ),
          ),
          _buildCommentInput(context, prayerProvider, authProvider),
        ],
      ),
    );
  }

  Widget _buildPrayerHeader(BuildContext context, PrayerModel prayer) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: prayer.isAnonymous
                ? theme.colorScheme.secondary.withOpacity(0.2)
                : theme.colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              prayer.isAnonymous ? Icons.visibility_off : Icons.person,
              color: prayer.isAnonymous
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayer.isAnonymous
                    ? 'Anonymous'
                    : prayer.userName ?? 'Unknown',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateFormat.format(prayer.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerContent(BuildContext context, PrayerModel prayer) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        prayer.content,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildCommentItem(BuildContext context, PrayerComment comment) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: comment.isAnonymous
                          ? colors.secondary.withOpacity(0.2)
                          : colors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        comment.isAnonymous ? Icons.visibility_off : Icons.person,
                        size: 16,
                        color: comment.isAnonymous
                            ? colors.secondary
                            : colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comment.isAnonymous
                          ? 'Anonymous'
                          : comment.userName ?? 'Unknown',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    dateFormat.format(comment.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    PrayerProvider prayerProvider,
    AuthProvider authProvider,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                  },
                  activeColor: colors.primary,
                ),
              ),
              Text(
                'Comment anonymously',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a prayer comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: colors.primary),
                      onPressed: () {
                        _submitComment(prayerProvider, authProvider);
                      },
                    ),
                  ),
                  maxLines: null,
                ),
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
        SnackBar(
          content: const Text('You must be logged in to comment'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    prayerProvider.error ?? 'Failed to add comment'),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        });
  }
}