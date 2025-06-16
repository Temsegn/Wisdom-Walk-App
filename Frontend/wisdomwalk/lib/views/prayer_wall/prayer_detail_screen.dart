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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
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

    final isPraying = prayer.prayingUsers.contains(
      authProvider.currentUser?.id ?? '',
    );
    final isMyPrayer = prayer.userId == authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Request')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrayerHeader(context, prayer),
                  const SizedBox(height: 16),
                  _buildPrayerContent(context, prayer),
                  const SizedBox(height: 24),
                  _buildPrayerActions(
                    context,
                    prayer,
                    isPraying,
                    prayerProvider,
                    authProvider,
                  ),
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

  Widget _buildPrayerActions(
    BuildContext context,
    PrayerModel prayer,
    bool isPraying,
    PrayerProvider prayerProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context: context,
            icon: '🙏',
            label: 'Praying (${prayer.prayingUsers.length})',
            isActive: isPraying,
            onTap: () {
              prayerProvider.togglePraying(
                prayerId: prayer.id,
                userId: authProvider.currentUser?.id ?? '',
              );
            },
          ),
          _buildActionButton(
            context: context,
            icon: '💬',
            label: 'Encourage',
            isActive: false,
            onTap: () {
              _scrollToComments();
            },
          ),
          _buildActionButton(
            context: context,
            icon: '💬',
            label: 'Chat',
            isActive: false,
            onTap: () {
              _openChatDialog(context, prayer, authProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isActive
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    isActive
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToComments() {
    // Scroll to comments section
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Focus on comment input
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _openChatDialog(
    BuildContext context,
    PrayerModel prayer,
    AuthProvider authProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildChatBottomSheet(context, prayer, authProvider),
    );
  }

  Widget _buildChatBottomSheet(
    BuildContext context,
    PrayerModel prayer,
    AuthProvider authProvider,
  ) {
    final TextEditingController chatController = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Private Chat',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Chat messages area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start a private conversation',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send encouragement directly to ${prayer.isAnonymous ? 'this sister' : prayer.userName ?? 'this person'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Chat input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: InputDecoration(
                      hintText: 'Send a private message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final message = chatController.text.trim();
                      if (message.isNotEmpty) {
                        // TODO: Implement private messaging functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Private messaging feature coming soon!',
                            ),
                          ),
                        );
                        chatController.clear();
                      }
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
