import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/chat_model.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/user_provider.dart';
import 'package:wisdomwalk/views/chat/chat_screen.dart';
import 'package:wisdomwalk/widgets/add_anonymous_share_button.dart';

class PrayerWallTab extends StatefulWidget {
  const PrayerWallTab({Key? key}) : super(key: key);

  @override
  State<PrayerWallTab> createState() => _PrayerWallTabState();
}

class _PrayerWallTabState extends State<PrayerWallTab>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _showCommentSection = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    prayerProvider.setFilter('prayer');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _commentControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFF74B9FF)],
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFF8F9FA)],
              ).createShader(bounds),
          child: const Text(
            'Prayer Wall',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE84393), Color(0xFFD63031)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE84393).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAddPrayerDialog(context);
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                'Post Prayer Request',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
            ),
          ),
          child: Consumer<PrayerProvider>(
            builder: (context, prayerProvider, child) {
              if (prayerProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6C5CE7),
                    ),
                  ),
                );
              }

              if (prayerProvider.error != null) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE5E5), Color(0xFFFFF0F0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE17055).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE17055), Color(0xFFD63031)],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading prayers',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFD63031),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          prayerProvider.error!,
                          style: const TextStyle(color: Color(0xFF636E72)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ElevatedButton(
                            onPressed: () => prayerProvider.fetchPrayers(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (prayerProvider.prayers.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[50]!, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.volunteer_activism_outlined,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No prayers yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF636E72),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Be the first to share a prayer request',
                          style: TextStyle(color: Color(0xFF636E72)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  prayerProvider.setFilter('prayer');
                },
                color: const Color(0xFF6C5CE7),
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: prayerProvider.prayers.length,
                  itemBuilder: (context, index) {
                    final prayer = prayerProvider.prayers[index];
                    return _buildPrayerCard(prayer);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard(PrayerModel prayer) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'current_user';
    final commentController = _commentControllers.putIfAbsent(
      prayer.id,
      () => TextEditingController(),
    );
    final showCommentSection = _showCommentSection.putIfAbsent(
      prayer.id,
      () => false,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (prayer.isAnonymous) {
                          _showErrorSnackBar(
                            context,
                            'Cannot view anonymous profiles',
                          );
                          return;
                        }
                        if (userId == 'current_user') {
                          _showLoginPrompt(context, 'view profiles');
                          return;
                        }
                        if (prayer.userId == null || prayer.userId.isEmpty) {
                          debugPrint('Invalid prayer userId: ${prayer.userId}');
                          _showErrorSnackBar(
                            context,
                            'Cannot view profile: Invalid user ID',
                          );
                          return;
                        }
                        debugPrint(
                          'Navigating to profile with userId: ${prayer.userId}',
                        );
                        context.push('/profile/${prayer.userId}');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient:
                              prayer.isAnonymous || prayer.userAvatar == null
                                  ? const LinearGradient(
                                    colors: [
                                      Color(0xFF74B9FF),
                                      Color(0xFF0984E3),
                                    ],
                                  )
                                  : null,
                          borderRadius: BorderRadius.circular(50),
                          image:
                              prayer.isAnonymous || prayer.userAvatar == null
                                  ? null
                                  : DecorationImage(
                                    image: NetworkImage(
                                      '${prayer.userAvatar!}?t=${DateTime.now().millisecondsSinceEpoch}',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        child:
                            prayer.isAnonymous || prayer.userAvatar == null
                                ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prayer.isAnonymous
                                ? 'Anonymous Sister'
                                : (prayer.userName ?? 'Unknown'),
                            style: const TextStyle(
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C5CE7),
                                      Color(0xFFA29BFE),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  'Prayer Request',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatTimeAgo(prayer.createdAt),
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
                  prayer.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF636E72),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon:
                            prayer.prayingUsers.contains(userId)
                                ? Icons.volunteer_activism
                                : Icons.volunteer_activism_outlined,
                        label: '${prayer.prayingUsers.length}',
                        color: const Color(0xFF6C5CE7),
                        isActive: prayer.prayingUsers.contains(userId),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (userId == 'current_user') {
                            _showLoginPrompt(context, 'pray for this request');
                            return;
                          }
                          final prayerProvider = Provider.of<PrayerProvider>(
                            context,
                            listen: false,
                          );
                          final success = await prayerProvider.togglePraying(
                            prayerId: prayer.id,
                            userId: userId,
                            message: 'Praying for you ❤️',
                          );
                          if (success && context.mounted) {
                            _showSuccessSnackBar(
                              context,
                              prayer.prayingUsers.contains(userId)
                                  ? 'Removed from praying list'
                                  : 'You are now praying for this request 🙏',
                              const Color(0xFF6C5CE7),
                            );
                          } else if (context.mounted) {
                            _showErrorSnackBar(
                              context,
                              'Failed to toggle praying: ${prayerProvider.error ?? 'Unknown error'}',
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.comment_outlined,
                        label: '${prayer.comments.length}',
                        color: const Color(0xFF1DA1F2),
                        isActive: showCommentSection,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _showCommentSection[prayer.id] =
                                !showCommentSection;
                            if (!_showCommentSection[prayer.id]!) {
                              commentController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon:
                            prayer.likedUsers.contains(userId)
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                        label: '${prayer.likedUsers.length}',
                        color: const Color(0xFF00B894),
                        isActive: prayer.likedUsers.contains(userId),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          if (userId == 'current_user') {
                            _showLoginPrompt(context, 'like this post');
                            return;
                          }
                          final prayerProvider = Provider.of<PrayerProvider>(
                            context,
                            listen: false,
                          );
                          final success = await prayerProvider.toggleLike(
                            prayerId: prayer.id,
                            userId: userId,
                          );
                          if (success && context.mounted) {
                            _showSuccessSnackBar(
                              context,
                              prayer.likedUsers.contains(userId)
                                  ? 'Removed like'
                                  : 'Post liked! 👍',
                              const Color(0xFF00B894),
                            );
                          } else if (context.mounted) {
                            _showErrorSnackBar(
                              context,
                              'Failed to toggle like: ${prayerProvider.error ?? 'Unknown error'}',
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.chat_outlined,
                        label: 'Chat',
                        color: const Color(0xFFE84393),
                        isActive: false,
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          if (!authProvider.isAuthenticated) {
                            _showLoginPrompt(context, 'start a chat');
                            return;
                          }
                          if (prayer.isAnonymous) {
                            _showErrorSnackBar(
                              context,
                              'Cannot chat with anonymous users',
                            );
                            return;
                          }
                          if (prayer.userId == null || prayer.userId.isEmpty) {
                            debugPrint('Invalid chat userId: ${prayer.userId}');
                            _showErrorSnackBar(
                              context,
                              'Cannot start chat: Invalid user ID',
                            );
                            return;
                          }
                          final userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false,
                          );
                          final targetUser = userProvider.allUsers.firstWhere(
                            (user) => user.id == prayer.userId,
                            orElse: () => UserModel.empty(),
                          );
                          if (targetUser.isBlocked) {
                            _showErrorSnackBar(
                              context,
                              'Cannot chat with blocked users',
                            );
                            return;
                          }
                          try {
                            final chatProvider = Provider.of<ChatProvider>(
                              context,
                              listen: false,
                            );
                            Chat? chat = await chatProvider.getExistingChat(
                              prayer.userId,
                            );
                            if (chat == null) {
                              chat = await chatProvider
                                  .createDirectChatWithGreeting(
                                    prayer.userId,
                                    greeting:
                                        '👋 Hi! I saw your prayer request "${prayer.title ?? prayer.content.substring(0, min(prayer.content.length, 20))}..." and wanted to connect.',
                                  );
                            }
                            if (chat == null || !context.mounted) {
                              _showErrorSnackBar(
                                context,
                                'Failed to start chat',
                              );
                              return;
                            }
                            context.go('/dashboard', extra: {'tab': 5});
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatScreen(chat: chat!),
                                  ),
                                );
                              }
                            });
                          } catch (e) {
                            if (context.mounted) {
                              _showErrorSnackBar(
                                context,
                                'Error starting chat: $e',
                              );
                            }
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
                      color: Colors.grey[100],
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
                              hintText: 'Reply to this prayer…',
                              hintStyle: TextStyle(color: Color(0xFF657786)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            minLines: 1,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF14171A),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1DA1F2),
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
                                _showLoginPrompt(
                                  context,
                                  'comment on this post',
                                );
                                return;
                              }
                              final content = commentController.text.trim();
                              if (content.isEmpty) {
                                _showErrorSnackBar(
                                  context,
                                  'Comment cannot be empty',
                                );
                                return;
                              }
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              final prayerProvider =
                                  Provider.of<PrayerProvider>(
                                    context,
                                    listen: false,
                                  );
                              final success = await prayerProvider.addComment(
                                prayerId: prayer.id,
                                userId: userId,
                                content: content,
                                isAnonymous: false,
                                userName: authProvider.currentUser?.name,
                                userAvatar: authProvider.currentUser?.avatar,
                              );
                              if (success && context.mounted) {
                                commentController.clear();
                                _showSuccessSnackBar(
                                  context,
                                  'Comment added successfully!',
                                  const Color(0xFF1DA1F2),
                                );
                              } else if (context.mounted) {
                                _showErrorSnackBar(
                                  context,
                                  'Failed to add comment: ${prayerProvider.error ?? 'Unknown error'}',
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
                  if (prayer.comments.isNotEmpty)
                    ...prayer.comments.map(
                      (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (userId == 'current_user') {
                                  _showLoginPrompt(context, 'view profiles');
                                  return;
                                }
                                if (comment.isAnonymous == true) {
                                  _showErrorSnackBar(
                                    context,
                                    'Cannot view anonymous profiles',
                                  );
                                  return;
                                }
                                if (comment.userId == null ||
                                    comment.userId.isEmpty) {
                                  debugPrint(
                                    'Invalid comment userId: ${comment.userId}',
                                  );
                                  _showErrorSnackBar(
                                    context,
                                    'Cannot view profile: Invalid user ID',
                                  );
                                  return;
                                }
                                debugPrint(
                                  'Navigating to profile with userId: ${comment.userId}',
                                );
                                context.push('/profile/${comment.userId}');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient:
                                      comment.userAvatar == null
                                          ? const LinearGradient(
                                            colors: [
                                              Color(0xFF1DA1F2),
                                              Color(0xFF0984E3),
                                            ],
                                          )
                                          : null,
                                  borderRadius: BorderRadius.circular(25),
                                  image:
                                      comment.userAvatar != null
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              '${comment.userAvatar!}?t=${DateTime.now().millisecondsSinceEpoch}',
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    comment.userAvatar == null
                                        ? const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.userName ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF14171A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.content,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF657786),
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
                      'No comments yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF657786),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  prayer.isReported
                      ? Icons.report_problem
                      : Icons.report_problem_outlined,
                  color:
                      prayer.isReported
                          ? const Color(0xFFE17055)
                          : const Color(0xFF636E72),
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (userId == 'current_user') {
                    _showLoginPrompt(context, 'report this post');
                    return;
                  }
                  _showReportDialog(context, prayer, userId);
                },
              ),
            ),
          ),
        ],
      ),
    );
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

  void _showLoginPrompt(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please log in to $action'),
        backgroundColor: const Color(0xFFE17055),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD63031),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showReportDialog(
    BuildContext context,
    PrayerModel prayer,
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
                    _showErrorSnackBar(
                      context,
                      'Reason must be at least 10 characters',
                    );
                    return;
                  }
                  final prayerProvider = Provider.of<PrayerProvider>(
                    context,
                    listen: false,
                  );
                  try {
                    final success = await prayerProvider.reportPost(
                      prayerId: prayer.id,
                      userId: userId,
                      reason: reason,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showSuccessSnackBar(
                        context,
                        success
                            ? 'Post reported successfully 🚨'
                            : 'Failed to report post',
                        success
                            ? const Color(0xFFE17055)
                            : const Color(0xFFD63031),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      _showErrorSnackBar(context, 'Failed to report post: $e');
                    }
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

  void _showAddPrayerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8F9FA)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const AddPrayerModal(isAnonymous: false),
            ),
          ),
    );
  }

  void _showEncourageDialog(
    BuildContext context,
    PrayerModel prayer,
    dynamic user,
  ) {
    final TextEditingController encourageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Encourage ${prayer.isAnonymous ? "Anonymous Sister" : prayer.userName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            content: Container(
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
                controller: encourageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Write your encouragement...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
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
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (encourageController.text.trim().isNotEmpty) {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final prayerProvider = Provider.of<PrayerProvider>(
                        context,
                        listen: false,
                      );
                      final userId =
                          authProvider.currentUser?.id ?? 'current_user';

                      final success = await prayerProvider.addComment(
                        prayerId: prayer.id,
                        userId: userId,
                        content: encourageController.text.trim(),
                        isAnonymous: false,
                        userName: authProvider.currentUser?.name,
                        userAvatar: authProvider.currentUser?.avatar,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        _showSuccessSnackBar(
                          context,
                          success
                              ? '💝 Encouragement sent successfully!'
                              : 'Failed to send encouragement',
                          success
                              ? const Color(0xFF00B894)
                              : const Color(0xFFD63031),
                        );
                      }
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
                    'Send',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
