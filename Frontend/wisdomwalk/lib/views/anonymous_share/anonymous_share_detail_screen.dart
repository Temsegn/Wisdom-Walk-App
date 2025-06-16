import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    final shareProvider = Provider.of<AnonymousShareProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final share = shareProvider.selectedShare;
    final isLoading = shareProvider.isLoading;
    final error = shareProvider.error;

    return Scaffold(
      appBar: AppBar(title: Text(_getTypeTitle(share?.type))),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading share details',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShareHeader(context, share),
                          const SizedBox(height: 16),
                          _buildShareContent(context, share),
                          const SizedBox(height: 24),
                          _buildShareActions(
                            context,
                            share,
                            authProvider.currentUser?.id ?? '',
                            shareProvider,
                          ),
                          const SizedBox(height: 24),
                          _buildCommentsSection(context, share),
                        ],
                      ),
                    ),
                  ),
                  _buildCommentInput(context, shareProvider, authProvider),
                ],
              ),
    );
  }

  String _getTypeTitle(AnonymousShareType? type) {
    if (type == null) return 'Anonymous Share';

    switch (type) {
      case AnonymousShareType.confession:
        return 'Anonymous Confession';
      case AnonymousShareType.testimony:
        return 'Anonymous Testimony';
      case AnonymousShareType.struggle:
        return 'Anonymous Struggle';
    }
  }

  Widget _buildShareHeader(BuildContext context, AnonymousShareModel share) {
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');
    final typeColor = _getTypeColor(share.type);
    final typeIcon = _getTypeIcon(share.type);
    final typeLabel = _getTypeLabel(share.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(typeIcon, color: typeColor, size: 16),
              const SizedBox(width: 4),
              Text(
                typeLabel,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Anonymous Sister',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          dateFormat.format(share.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildShareContent(BuildContext context, AnonymousShareModel share) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(share.content, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Widget _buildShareActions(
    BuildContext context,
    AnonymousShareModel share,
    String currentUserId,
    AnonymousShareProvider shareProvider,
  ) {
    final hasHeart = share.hearts.contains(currentUserId);
    final isPraying = share.prayingUsers.contains(currentUserId);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            shareProvider.toggleHeart(shareId: share.id, userId: currentUserId);
          },
          icon: Icon(
            hasHeart ? Icons.favorite : Icons.favorite_border,
            color: hasHeart ? Colors.red : null,
          ),
          label: Text('${share.hearts.length} Hearts'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                hasHeart
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
            foregroundColor:
                hasHeart ? Colors.red : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            shareProvider.togglePraying(
              shareId: share.id,
              userId: currentUserId,
            );
          },
          icon: Icon(isPraying ? Icons.check_circle : Icons.volunteer_activism),
          label: Text(isPraying ? 'Praying' : 'I\'ll Pray'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isPraying
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.surface,
            foregroundColor:
                isPraying ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {
            // Send virtual hug
            _sendVirtualHug(context, shareProvider, currentUserId);
          },
          icon: const Icon(Icons.favorite),
          label: const Text('Virtual Hug'),
        ),
      ],
    );
  }

  Widget _buildCommentsSection(
    BuildContext context,
    AnonymousShareModel share,
  ) {
    if (share.comments.isEmpty) {
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
          itemCount: share.comments.length,
          itemBuilder: (context, index) {
            final comment = share.comments[index];
            return _buildCommentItem(context, comment);
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(
    BuildContext context,
    AnonymousShareComment comment,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Anonymous Sister',
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

  Widget _buildCommentInput(
    BuildContext context,
    AnonymousShareProvider shareProvider,
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
            onPressed: () {
              _submitComment(shareProvider, authProvider);
            },
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }

  void _submitComment(
    AnonymousShareProvider shareProvider,
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

    shareProvider
        .addComment(shareId: widget.shareId, userId: user.id, content: comment)
        .then((success) {
          if (success) {
            _commentController.clear();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(shareProvider.error ?? 'Failed to add comment'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  void _sendVirtualHug(
    BuildContext context,
    AnonymousShareProvider shareProvider,
    String currentUserId,
  ) {
    shareProvider
        .sendVirtualHug(shareId: widget.shareId, userId: currentUserId)
        .then((success) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Virtual hug sent! 🤗'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  shareProvider.error ?? 'Failed to send virtual hug',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
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
