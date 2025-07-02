import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/models/chat_model.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';

import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:wisdomwalk/providers/event_provider.dart';

import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/reflection_provider.dart';
import 'package:wisdomwalk/providers/wisdom_circle_provider.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/views/dashboared/her_move_tab.dart';
import 'package:wisdomwalk/widgets/add_prayer_modal.dart';
import 'package:wisdomwalk/widgets/booking_form.dart';
import 'package:wisdomwalk/widgets/chat_card.dart';
import 'package:wisdomwalk/models/event_model.dart';

import 'package:universal_html/html.dart' as html; // For browser file picking
import 'package:video_player/video_player.dart';

import 'dart:async';
import 'package:wisdomwalk/models/anonymous_share_model.dart';

import 'package:wisdomwalk/providers/notification_provider.dart';
import 'package:url_launcher/url_launcher.dart'; // For sharing links

import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomeTab(),
          PrayerWallTab(),
          WisdomCirclesTab(),
          AnonymousShareTab(),
          HerMoveTab(),
          PersonalChatTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD4A017),
        unselectedItemColor: const Color(0xFF757575),
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            activeIcon: Icon(Icons.volunteer_activism),
            label: 'Prayer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Circles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            activeIcon: Icon(Icons.mail),
            label: 'Share',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Her Move',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}

// HomeTab Implementation

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch events when the HomeTab is initialized
    Provider.of<EventProvider>(context, listen: false).fetchEvents();
    Provider.of<AnonymousShareProvider>(
      context,
      listen: false,
    ).fetchShares(type: AnonymousShareType.testimony);
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'WisdomWalk',
          style: TextStyle(
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF4A4A4A),
                    ),
                    onPressed: () {
                      context.push('/notifications');
                    },
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE91E63),
                          borderRadius: BorderRadius.circular(10),
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
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF4A4A4A)),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDailyVerse(context),
                const SizedBox(height: 24),
                _buildFeaturedTestimony(),
                const SizedBox(height: 24),
                _buildQuickAccessButtons(context),
                const SizedBox(height: 24),
                _buildUpcomingEvents(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 350;
          return FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => BookingForm(),
              );
            },
            icon: Icon(Icons.event_available),
            label: isSmall ? SizedBox.shrink() : Text('Book Session'),
          );
        },
      ),
    );
  }

  Widget _buildDailyVerse(BuildContext context) {
    const String verseText =
        '"She is clothed with strength and dignity, and she laughs without fear of the future."';
    const String verseReference = 'Proverbs 31:25';
    const String shareMessage =
        'Check out today\'s Daily Verse from WisdomWalk:\n\n$verseText\n$verseReference\n\nJoin me on WisdomWalk for more inspiration! https://wisdomwalk.app';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5E1E5), Color(0xFFE6E1F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Verse',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            verseText,
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            verseReference,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4A017),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _showShareModal(context, shareMessage);
                },
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4A017),
                  side: const BorderSide(color: Color(0xFFD4A017)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _showReflectModal(context, verseReference);
                },
                icon: const Icon(Icons.menu_book, size: 16),
                label: const Text('Reflect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A017),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReflectModal(BuildContext context, String verseReference) {
    final _formKey = GlobalKey<FormState>();
    bool _isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reflect on the Daily Verse',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reflectionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Write your reflection...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your reflection';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFFD4A017)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);
                                      final reflectionProvider =
                                          Provider.of<ReflectionProvider>(
                                            context,
                                            listen: false,
                                          );
                                      reflectionProvider.addReflection(
                                        verseReference,
                                        _reflectionController.text.trim(),
                                      );
                                      setState(() => _isLoading = false);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Reflection saved successfully',
                                          ),
                                        ),
                                      );
                                      _showShareModal(
                                        context,
                                        'My reflection on $verseReference:\n\n${_reflectionController.text.trim()}\n\nJoin me on WisdomWalk: https://wisdomwalk.app',
                                      );
                                      _reflectionController
                                          .clear(); // Clear after saving
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A017),
                            foregroundColor: Colors.white,
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text('Save & Share'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showShareModal(BuildContext context, String shareMessage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareIcon(
                    context: context,
                    iconPath: 'assets/images/whatsapp_icon.png',
                    label: 'WhatsApp',
                    onTap: () => _shareTo(context, shareMessage, 'whatsapp'),
                  ),
                  _buildShareIcon(
                    context: context,
                    iconPath: 'assets/images/facebook_icon.png',
                    label: 'Facebook',
                    onTap: () => _shareTo(context, shareMessage, 'facebook'),
                  ),
                  _buildShareIcon(
                    context: context,
                    iconPath: 'assets/images/twitter_icon.png',
                    label: 'Twitter',
                    onTap: () => _shareTo(context, shareMessage, 'twitter'),
                  ),
                  _buildShareIcon(
                    context: context,
                    iconPath: 'assets/images/telegram_icon.png',
                    label: 'Telegram',
                    onTap: () => _shareTo(context, shareMessage, 'telegram'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFFD4A017), fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareIcon({
    required BuildContext context,
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
            ),
            child: Image.asset(iconPath, width: 40, height: 40),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF4A4A4A)),
        ),
      ],
    );
  }

  Future<void> _shareTo(
    BuildContext context,
    String message,
    String platform,
  ) async {
    final encodedMessage = Uri.encodeComponent(message);
    String url;
    String fallbackUrl;

    // Define platform-specific URLs
    switch (platform) {
      case 'whatsapp':
        if (kIsWeb) {
          url = 'https://wa.me/?text=$encodedMessage';
          fallbackUrl = url;
        } else {
          url = 'whatsapp://send?text=$encodedMessage';
          fallbackUrl = 'https://wa.me/?text=$encodedMessage';
        }
        break;
      case 'facebook':
        if (kIsWeb) {
          url =
              'https://www.facebook.com/sharer/sharer.php?quote=$encodedMessage';
          fallbackUrl = url;
        } else {
          // Facebook sharing on mobile typically requires the app's custom scheme
          url = 'fb://share?text=$encodedMessage';
          fallbackUrl =
              'https://www.facebook.com/sharer/sharer.php?quote=$encodedMessage';
        }
        break;
      case 'twitter':
        if (kIsWeb) {
          url = 'https://twitter.com/intent/tweet?text=$encodedMessage';
          fallbackUrl = url;
        } else {
          // Twitter (X) sharing on mobile
          url = 'twitter://post?message=$encodedMessage';
          fallbackUrl = 'https://twitter.com/intent/tweet?text=$encodedMessage';
        }
        break;
      case 'telegram':
        if (kIsWeb) {
          url =
              'https://t.me/share/url?text=$encodedMessage&url=https://wisdomwalk.app';
          fallbackUrl = url;
        } else {
          url = 'tg://msg?text=$encodedMessage';
          fallbackUrl =
              'https://t.me/share/url?text=$encodedMessage&url=https://wisdomwalk.app';
        }
        break;
      default:
        return;
    }

    // Try launching the native app URL
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        // Fallback to web URL if native app is not installed
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.platformDefault,
        );
        Navigator.pop(context);
      } else {
        // Copy to clipboard if both attempts fail
        await Clipboard.setData(ClipboardData(text: message));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $platform. Copied to clipboard.'),
          ),
        );
      }
    } catch (e) {
      // Handle any errors during launching
      await Clipboard.setData(ClipboardData(text: message));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing to $platform. Copied to clipboard.'),
        ),
      );
    }
  }

  // In _HomeTabState class
  // In _HomeTabState class
  Widget _buildFeaturedTestimony() {
    return Consumer<AnonymousShareProvider>(
      builder: (context, shareProvider, child) {
        if (shareProvider.shares.isEmpty && !shareProvider.isLoading) {
          shareProvider.fetchShares(type: AnonymousShareType.testimony);
        }

        if (shareProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (shareProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  shareProvider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      () => shareProvider.fetchShares(
                        type: AnonymousShareType.testimony,
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A017),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final testimonies =
            shareProvider.shares
                .where((share) => share.type == AnonymousShareType.testimony)
                .toList();
        if (testimonies.isEmpty) {
          return const Center(
            child: Text(
              'No featured testimony available',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final testimony = testimonies.reduce(
          (a, b) => a.heartCount > b.heartCount ? a : b,
        );
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id ?? 'current_user';
        final isLiked = testimony.hearts.contains(userId);
        final isPraying = testimony.prayingUsers.contains(userId);
        final hasHugged = testimony.virtualHugs.contains(userId);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE8E2DB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E1E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: Color(0xFFD4A017),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sister Spotlight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      Text(
                        'Anonymous Sister',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : const Color(0xFFD4A017),
                    ),
                    onPressed: () async {
                      final success = await shareProvider.toggleHeart(
                        shareId: testimony.id,
                        userId: userId,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isLiked
                                  ? 'Removed heart from testimony'
                                  : 'Hearted testimony!',
                            ),
                            backgroundColor: isLiked ? Colors.grey : Colors.red,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to update heart'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                testimony.content,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width:
                            constraints.maxWidth > 400
                                ? null
                                : constraints.maxWidth * 0.3,
                        child: TextButton.icon(
                          onPressed: () async {
                            final success = await shareProvider.toggleHeart(
                              shareId: testimony.id,
                              userId: userId,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isLiked ? 'Removed heart' : 'Hearted!',
                                  ),
                                  backgroundColor:
                                      isLiked ? Colors.grey : Colors.red,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update heart'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color:
                                isLiked ? Colors.red : const Color(0xFFD4A017),
                          ),
                          label: Flexible(
                            child: Text(
                              '${testimony.heartCount} Hearts',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:
                            constraints.maxWidth > 400
                                ? null
                                : constraints.maxWidth * 0.3,
                        child: TextButton.icon(
                          onPressed: () async {
                            final success = await shareProvider.togglePraying(
                              shareId: testimony.id,
                              userId: userId,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isPraying
                                        ? 'Removed prayer'
                                        : 'Praying for this',
                                  ),
                                  backgroundColor:
                                      isPraying
                                          ? Colors.grey
                                          : const Color(0xFFD4A017),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update prayer'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.volunteer_activism_outlined,
                            size: 16,
                            color:
                                isPraying
                                    ? const Color(0xFFD4A017)
                                    : Colors.grey,
                          ),
                          label: Flexible(
                            child: Text(
                              '${testimony.prayerCount} Prayers',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:
                            constraints.maxWidth > 400
                                ? null
                                : constraints.maxWidth * 0.3,
                        child: TextButton.icon(
                          onPressed: () async {
                            final success = await shareProvider.sendVirtualHug(
                              shareId: testimony.id,
                              userId: userId,
                            );
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Virtual hug sent!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to send virtual hug'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.favorite,
                            size: 16,
                            color: hasHugged ? Colors.pink : Colors.grey,
                          ),
                          label: Flexible(
                            child: Text(
                              '${testimony.hugCount} Hugs',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4A017),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/anonymous-share/${testimony.id}');
                        },
                        child: const Text(
                          'Read Full Testimony',
                          style: TextStyle(
                            color: Color(0xFFD4A017),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.volunteer_activism,
                title: 'Prayer Wall',
                color: const Color(0xFFF5E1E5),
                onTap: () {
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState._onTabTapped(1);
                  } else {
                    debugPrint('DashboardScreenState not found');
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.people,
                title: 'Wisdom Circles',
                color: const Color(0xFFE6E1F5),
                onTap: () {
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState._onTabTapped(2);
                  } else {
                    debugPrint('DashboardScreenState not found');
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.chat,
                title: 'Personal Chat',
                color: const Color(0xFFFDF6F0),
                onTap: () {
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState._onTabTapped(5);
                  } else {
                    debugPrint('DashboardScreenState not found');
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E2DB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4A017), size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // In _HomeTabState class
  Widget _buildUpcomingEvents() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  eventProvider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => eventProvider.fetchEvents(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A017),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (eventProvider.events.isEmpty) {
          return const Center(
            child: Text(
              'No upcoming events',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventProvider.events[index];
                return _buildEventCard(
                  context: context,
                  event: event,
                  eventProvider: eventProvider,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required EventModel event,
    required EventProvider eventProvider,
  }) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'current_user';
    final isJoined = event.participants.contains(userId);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8E2DB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E1E5).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.event, color: Color(0xFFD4A017)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(event.dateTime)} • ${_formatTime(event.dateTime)} • ${event.platform}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isJoined) {
                // Launch the event link
                String url = event.link;
                String? nativeUrl;

                // Handle Zoom specifically
                if (event.platform.toLowerCase() == 'zoom') {
                  // Extract meeting ID and password from the URL if possible
                  final uri = Uri.parse(url);
                  final meetingId = uri.pathSegments.lastWhere(
                    (segment) => RegExp(r'^\d+$').hasMatch(segment),
                    orElse: () => '',
                  );
                  final pwd = uri.queryParameters['pwd'] ?? '';
                  if (meetingId.isNotEmpty) {
                    nativeUrl =
                        'zoomus://zoom.us/join?confno=$meetingId&pwd=$pwd';
                  }
                }

                // Debug logs
                print('Attempting to launch event: ${event.title}');
                print('Platform: ${event.platform}');
                print('Native URL: $nativeUrl');
                print('Web URL: $url');

                // Try native Zoom URL on non-web platforms
                if (!kIsWeb &&
                    nativeUrl != null &&
                    event.platform.toLowerCase() == 'zoom') {
                  try {
                    print('Checking native URL: $nativeUrl');
                    if (await canLaunchUrl(Uri.parse(nativeUrl))) {
                      print('Launching native URL: $nativeUrl');
                      await launchUrl(
                        Uri.parse(nativeUrl),
                        mode: LaunchMode.externalApplication,
                      );
                      return;
                    } else {
                      print('Native URL not supported: $nativeUrl');
                    }
                  } catch (e) {
                    print('Error launching native URL ($nativeUrl): $e');
                  }
                }

                // Try web URL
                try {
                  print('Checking web URL: $url');
                  if (await canLaunchUrl(Uri.parse(url))) {
                    print('Launching web URL: $url');
                    await launchUrl(
                      Uri.parse(url),
                      mode:
                          kIsWeb
                              ? LaunchMode.platformDefault
                              : LaunchMode.externalApplication,
                    );
                  } else {
                    print('Web URL not supported: $url');
                    // Copy to clipboard
                    await Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Could not open ${event.platform}. Copied to clipboard.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error launching web URL ($url): $e');
                  // Copy to clipboard
                  await Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Could not open ${event.platform}. Copied to clipboard.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                // Join the event
                final success = await eventProvider.toggleJoinEvent(
                  event.id,
                  userId,
                );
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully joined ${event.title}!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to join ${event.title}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isJoined ? Colors.green : const Color(0xFFD4A017),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(isJoined ? 'Join Now' : 'Join'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class PrayerWallTab extends StatefulWidget {
  const PrayerWallTab({Key? key}) : super(key: key);

  @override
  State<PrayerWallTab> createState() => _PrayerWallTabState();
}

class _PrayerWallTabState extends State<PrayerWallTab> {
  @override
  void initState() {
    super.initState();
    // Fetch prayers when the tab is initialized
    final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
    print(
      'PrayerWallTab initState: Setting filter to "prayer" and fetching prayers',
    );
    prayerProvider.setFilter('prayer'); // Explicitly set filter to 'prayer'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Prayer Wall',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddPrayerDialog(context);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Post Prayer Request',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
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
      body: Consumer<PrayerProvider>(
        builder: (context, prayerProvider, child) {
          if (prayerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prayerProvider.error != null) {
            print('PrayerWallTab: Error - ${prayerProvider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    prayerProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => prayerProvider.setFilter('prayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (prayerProvider.prayers.isEmpty) {
            print('PrayerWallTab: No prayers found');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No prayers yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share a prayer request',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          print(
            'PrayerWallTab: Displaying ${prayerProvider.prayers.length} prayers',
          );
          return RefreshIndicator(
            onRefresh: () async {
              print('RefreshIndicator: Refreshing prayers');
              prayerProvider.setFilter('prayer');
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prayerProvider.prayers.length,
              itemBuilder: (context, index) {
                final prayer = prayerProvider.prayers[index];
                return _buildPrayerCard(prayer);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerCard(PrayerModel prayer) {
    // Unchanged from your original code
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                child:
                    prayer.isAnonymous || prayer.userAvatar == null
                        ? const Icon(Icons.person, color: Colors.black54)
                        : null,
                backgroundImage:
                    prayer.isAnonymous || prayer.userAvatar == null
                        ? null
                        : NetworkImage(prayer.userAvatar!),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Prayer Request',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimeAgo(prayer.createdAt),
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
          Text(
            prayer.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.volunteer_activism,
                      label: 'Praying (${prayer.prayingUsers.length})',
                      color: const Color(0xFF9C27B0),
                      maxWidth: constraints.maxWidth / 3 - 8,
                      onPressed: () async {
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

                        final success = await prayerProvider.togglePraying(
                          prayerId: prayer.id,
                          userId: userId,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                prayer.prayingUsers.contains(userId)
                                    ? '🙏 You are now praying for this request'
                                    : '✨ Removed from praying list',
                              ),
                              backgroundColor: const Color(0xFF9C27B0),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: 'Encourage',
                      color: Colors.grey[600]!,
                      maxWidth: constraints.maxWidth / 3 - 8,
                      onPressed: () {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        _showEncourageDialog(
                          context,
                          prayer,
                          authProvider.currentUser,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.chat,
                      label: 'Chat',
                      color: const Color(0xFF2196F3),
                      maxWidth: constraints.maxWidth / 3 - 8,
                      onPressed: () {
                        context.push('/prayer/${prayer.id}');
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEncourageDialog(
    BuildContext context,
    PrayerModel prayer,
    dynamic user,
  ) {
    // Unchanged from your original code
    final TextEditingController encourageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Encourage ${prayer.isAnonymous ? "Anonymous Sister" : prayer.userName}',
            ),
            content: TextField(
              controller: encourageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your encouragement...',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
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

                    Navigator.pop(context);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('💝 Encouragement sent successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to send encouragement'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                ),
                child: const Text('Send'),
              ),
            ],
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required double maxWidth,
  }) {
    // Unchanged from your original code
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    // Unchanged from your original code
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
    // Unchanged from your original code
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const AddPrayerModal(isAnonymous: false),
          ),
    );
  }
}

// WisdomCirclesTab Implementation
class WisdomCirclesTab extends StatelessWidget {
  const WisdomCirclesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Join topic-based communities for deeper connection',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const Text(
              'My Circles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<WisdomCircleProvider>(
              builder: (context, provider, child) {
                final myCircles =
                    provider.circles
                        .where(
                          (circle) =>
                              provider.joinedCircles.contains(circle.id),
                        )
                        .toList();

                if (myCircles.isEmpty && provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children:
                      myCircles.map((circle) {
                        return WisdomCircleCard(
                          circle: circle,
                          isJoined: true,
                          onTap:
                              () => context.push('/wisdom-circle/${circle.id}'),
                        );
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Discover New Circles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer<WisdomCircleProvider>(
              builder: (context, provider, child) {
                final discoverCircles =
                    provider.circles
                        .where(
                          (circle) =>
                              !provider.joinedCircles.contains(circle.id),
                        )
                        .toList();

                if (discoverCircles.isEmpty && provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children:
                      discoverCircles.map((circle) {
                        return WisdomCircleCard(
                          circle: circle,
                          isJoined: false,
                          onTap: () {
                            final provider = Provider.of<WisdomCircleProvider>(
                              context,
                              listen: false,
                            );
                            provider.joinCircle(
                              circleId: circle.id,
                              userId: 'user123',
                            );
                          },
                        );
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Live Chats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLiveChatItem(
              'Marriage & Ministry',
              'Building Strong Foundations',
              'Tonight 8PM',
              Colors.purple,
            ),
            _buildLiveChatItem(
              'Healing & Hope',
              'Finding Peace in Storms',
              'Tomorrow 7PM',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveChatItem(
    String title,
    String subtitle,
    String time,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.videocam, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// WisdomCircleCard Implementation
class WisdomCircleCard extends StatefulWidget {
  final WisdomCircleModel circle;
  final bool isJoined;
  final VoidCallback onTap;

  const WisdomCircleCard({
    Key? key,
    required this.circle,
    required this.isJoined,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WisdomCircleCard> createState() => _WisdomCircleCardState();
}

class _WisdomCircleCardState extends State<WisdomCircleCard> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WisdomCircleProvider>(context, listen: false);
    final hasNewMessages = true; // Simulate new messages for demo
    final sampleMessage =
        'Ms: "Thank you all for the prayers! ✨"'; // Sample message

    Color cardColor = _getCardColor();
    String buttonText = widget.isJoined ? 'Open' : 'Join';
    Color buttonColor = widget.isJoined ? Colors.green : Colors.grey[300]!;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
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
                  radius: 16,
                  backgroundColor: _getIconColor(),
                  child: Text(
                    widget.circle.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.circle.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.circle.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (widget.isJoined) {
                      widget.onTap();
                    } else {
                      await provider.joinCircle(
                        circleId: widget.circle.id,
                        userId: 'user123',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Joined ${widget.circle.name}!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor:
                        widget.isJoined ? Colors.white : Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ⓘ ${widget.circle.memberCount} members ${hasNewMessages ? '⭕ 3 new messages' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              sampleMessage,
              style: TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor() {
    switch (widget.circle.id) {
      case '1': // Single & Purposeful
        return const Color(0xFFFFE4E6); // Light pink
      case '2': // Marriage & Ministry
        return const Color(0xFFE8E4FF); // Light purple
      case '3': // Motherhood in Christ
        return const Color(0xFFE4F3FF); // Light blue
      case '4': // Healing & Forgiveness
        return const Color(0xFFE4FFE8); // Light green
      case '5': // Mental Health & Faith
        return const Color(0xFFFFF4E4); // Light orange
      default:
        return const Color(0xFFF5F5F5); // Light gray
    }
  }

  Color _getIconColor() {
    switch (widget.circle.id) {
      case '1':
        return const Color(0xFFE91E63); // Pink
      case '2':
        return const Color(0xFF9C27B0); // Purple
      case '3':
        return const Color(0xFF2196F3); // Blue
      case '4':
        return const Color(0xFF4CAF50); // Green
      case '5':
        return const Color(0xFFFF9800); // Orange
      default:
        return Colors.grey;
    }
  }
}

// AnonymousShareTab Implementation

class AnonymousShareTab extends StatefulWidget {
  const AnonymousShareTab({Key? key}) : super(key: key);

  @override
  State<AnonymousShareTab> createState() => _AnonymousShareTabState();
}

class _AnonymousShareTabState extends State<AnonymousShareTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Add "All" tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnonymousShareProvider>(
      builder: (context, shareProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Anonymous Share',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  context.push('/settings');
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFD4A017),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFD4A017),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Confessions'),
                Tab(text: 'Testimonies'),
                Tab(text: 'Struggles'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildShareList(null), // All shares
              _buildShareList('confession'),
              _buildShareList('testimony'),
              _buildShareList('struggle'),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showShareAnonymouslyModal(context, shareProvider);
            },
            backgroundColor: const Color(0xFFD4A017),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildShareList(String? type) {
    return Consumer<AnonymousShareProvider>(
      builder: (context, shareProvider, child) {
        if (type == null) {
          shareProvider.fetchAllShares(); // Fetch all shares for "All" tab
        } else {
          shareProvider.fetchShares(
            type: AnonymousShareType.values.firstWhere(
              (t) => t.toString().split('.').last == type,
            ),
          );
        }

        final shares = shareProvider.shares;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id ?? 'current_user';

        if (shares.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${type ?? 'shares'} yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to share anonymously',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (type == null) {
              await shareProvider.fetchAllShares();
            } else {
              await shareProvider.fetchShares(
                type: AnonymousShareType.values.firstWhere(
                  (t) => t.toString().split('.').last == type,
                ),
              );
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shares.length,
            itemBuilder: (context, index) {
              final share = shares[index];
              final isLiked = share.hearts.contains(userId);
              final isPraying = share.prayingUsers.contains(userId);
              final hasHugged = share.virtualHugs.contains(userId);

              return GestureDetector(
                onTap: () {
                  context.push('/anonymous-share/${share.id}');
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                color: _getTypeColor(
                                  share.type.toString().split('.').last,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                share.type
                                    .toString()
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: _getTypeColor(
                                    share.type.toString().split('.').last,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTimeAgo(share.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          share.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                final success = await shareProvider.toggleHeart(
                                  shareId: share.id,
                                  userId: userId,
                                );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isLiked ? 'Removed heart' : 'Hearted!',
                                      ),
                                      backgroundColor:
                                          isLiked ? Colors.grey : Colors.red,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to update heart'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color:
                                    isLiked
                                        ? Colors.red
                                        : const Color(0xFFD4A017),
                              ),
                              label: Text(
                                '${share.heartCount} Hearts',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4A017),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    isLiked
                                        ? Colors.red
                                        : const Color(0xFFD4A017),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: () async {
                                final success = await shareProvider
                                    .togglePraying(
                                      shareId: share.id,
                                      userId: userId,
                                    );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isPraying
                                            ? 'Removed prayer'
                                            : 'Praying for this',
                                      ),
                                      backgroundColor:
                                          isPraying
                                              ? Colors.grey
                                              : const Color(0xFFD4A017),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to update prayer'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.volunteer_activism_outlined,
                                size: 18,
                                color:
                                    isPraying
                                        ? const Color(0xFFD4A017)
                                        : Colors.grey,
                              ),
                              label: Text(
                                '${share.prayerCount} Prayers',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4A017),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    isPraying
                                        ? const Color(0xFFD4A017)
                                        : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: () async {
                                final success = await shareProvider
                                    .sendVirtualHug(
                                      shareId: share.id,
                                      userId: userId,
                                    );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Virtual hug sent!'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to send virtual hug',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.favorite,
                                size: 18,
                                color: hasHugged ? Colors.pink : Colors.grey,
                              ),
                              label: Text(
                                '${share.hugCount} Hugs',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4A017),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    hasHugged ? Colors.pink : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showShareAnonymouslyModal(
    BuildContext context,
    AnonymousShareProvider shareProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareAnonymouslyModal(shareProvider: shareProvider),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'confession':
        return Colors.purple;
      case 'testimony':
        return Colors.green;
      case 'struggle':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
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

class ShareAnonymouslyModal extends StatefulWidget {
  final AnonymousShareProvider shareProvider;

  const ShareAnonymouslyModal({Key? key, required this.shareProvider})
    : super(key: key);

  @override
  State<ShareAnonymouslyModal> createState() => _ShareAnonymouslyModalState();
}

class _ShareAnonymouslyModalState extends State<ShareAnonymouslyModal> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  AnonymousShareType _selectedType = AnonymousShareType.testimony;
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share Anonymously',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your identity is completely protected. All posts are reviewed for safety.',
              style: TextStyle(color: Colors.purple),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AnonymousShareType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Category'),
              items:
                  AnonymousShareType.values.map((type) {
                    return DropdownMenuItem<AnonymousShareType>(
                      value: type,
                      child: Text(type.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Share your heart...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Please enter your content';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Share Anonymously'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitShare() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in to share')));
      setState(() => _isLoading = false);
      return;
    }

    final success = await widget.shareProvider.addShare(
      userId: user.id,
      content: _contentController.text.trim(),
      type: _selectedType,
    );

    setState(() => _isLoading = false);
    if (success) {
      Navigator.pop(context); // Close the modal
      final newShare = widget.shareProvider.shares.firstWhere(
        (share) =>
            share.userId == user.id &&
            share.content == _contentController.text.trim(),
      );
      context.push(
        '/anonymous-share/${newShare.id}',
      ); // Navigate to the new share's detail page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Share posted successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to post share')));
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

// PersonalChatTab Implementation

// Define custom color constants
const Color grey600 = Color(0xFF757575); // Approximate grey[600]
const Color blue700 = Color(0xFF1976D2); // Exact blue[700]

class PersonalChatTab extends StatefulWidget {
  const PersonalChatTab({Key? key}) : super(key: key);

  @override
  State<PersonalChatTab> createState() => _PersonalChatTabState();
}

class _PersonalChatTabState extends State<PersonalChatTab> {
  final TextEditingController _messageController = TextEditingController();
  dynamic _selectedFile; // Use dynamic for both html.File and File
  VideoPlayerController? _videoController; // For video playback
  bool _isDebug = true; // Manual debug flag

  @override
  void dispose() {
    _messageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.selectedChat != null) {
          return _buildChatScreen(context, chatProvider);
        }
        return _buildSistersListScreen(context, chatProvider);
      },
    );
  }

  Widget _buildSistersListScreen(
    BuildContext context,
    ChatProvider chatProvider,
  ) {
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Sisters',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              if (_isDebug) print('Search button pressed');
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              if (_isDebug) print('More options button pressed');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chatProvider.chats.length,
        itemBuilder: (context, index) {
          final chat = chatProvider.chats[index];

          return ChatCard(
            chat: chat,
            onTap: () {
              if (_isDebug) print('Tapped ${chat.name} with id: ${chat.id}');

              chatProvider.selectChat(chat.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isDebug) print('New chat button pressed');
        },
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatScreen(BuildContext context, ChatProvider chatProvider) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[50],
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            chatProvider.selectChat(null);
            setState(() {
              _selectedFile = null;
              _videoController?.dispose();
              _videoController = null;
            });
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueGrey[200],
              radius: 20,
              child: Text(
                chatProvider.selectedChat!.name[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatProvider.selectedChat!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.black87),
            onPressed: chatProvider.makeCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black87),
            onPressed: chatProvider.startVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              if (_isDebug) print('More options in chat screen pressed');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.selectedChat!.messages.length,
              itemBuilder: (context, index) {
                final message = chatProvider.selectedChat!.messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFB0BEC5)),
              ), // grey[300] approximated
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: grey600),
                  onPressed: () async {
                    if (kIsWeb) {
                      // Browser file picking
                      html.FileUploadInputElement input =
                          html.FileUploadInputElement()
                            ..accept = '.jpg,.jpeg,.png,.mp4,.mp3,.pdf';
                      input.click();
                      input.onChange.listen((event) {
                        final files = input.files;
                        if (files != null && files.isNotEmpty) {
                          final file = files[0];
                          final reader = html.FileReader();
                          reader.readAsArrayBuffer(file);
                          reader.onLoadEnd.listen((event) {
                            int fileSizeInBytes = file.size;
                            const maxSizeInBytes = 16 * 1024 * 1024; // 16MB
                            if (fileSizeInBytes <= maxSizeInBytes) {
                              setState(() {
                                _selectedFile = file; // Store as html.File
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('File selected successfully!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'File size exceeds 16MB limit.',
                                  ),
                                ),
                              );
                            }
                          });
                        }
                      });
                    } else {
                      // Native file picking (for non-browser, though not applicable here)
                      // This block won't run in browser, but kept for completeness
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'jpg',
                              'jpeg',
                              'png',
                              'mp4',
                              'pdf',
                            ],
                          );
                      if (result != null) {
                        setState(() {
                          _selectedFile =
                              result
                                  .files
                                  .single; // Use FilePickerResult for native
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File selected successfully!'),
                          ),
                        );
                      }
                    }
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5), // grey[100] approximated
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Fixed with const
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: blue700,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        chatProvider.sendMessage(_messageController.text);
                        _messageController.clear();
                      }
                      if (_selectedFile != null) {
                        await chatProvider.sendFile(
                          chatProvider.selectedChat!.id,
                          _selectedFile,
                        );
                        setState(() {
                          _selectedFile = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(MessageModel message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.blueGrey[200],
                radius: 16,
                child: Text(
                  message.senderId[0],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                if (message.filePath != null) _buildFileAttachment(message),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        message.isMe
                            ? blue700
                            : const Color(0xFFECEFF1), // grey[200] approximated
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(message.isMe ? 12 : 4),
                      bottomRight: Radius.circular(message.isMe ? 4 : 12),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    message.time,
                    style: TextStyle(
                      color: message.isMe ? Colors.white70 : grey600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 12,
                child: const Text(
                  'M',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileAttachment(MessageModel message) {
    if (message.fileType == 'video') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SizedBox(
          height: 200,
          child:
              _videoController == null || !_videoController!.value.isInitialized
                  ? FutureBuilder(
                    future: _initializeVideoController(message.filePath!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoController!),
                            IconButton(
                              icon: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: () {
                                _videoController!.play();
                              },
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                  : Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_videoController!),
                      IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {
                          _videoController!.play();
                        },
                      ),
                    ],
                  ),
        ),
      );
    } else if (message.fileType == 'image') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Image.network(
          message.filePath!, // Use network image for browser
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      );
    } else if (message.fileType == 'pdf') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: Text('PDF Preview')),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _initializeVideoController(String filePath) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.network(
        filePath,
      ) // Use network for browser
      ..initialize()
          .then((_) {
            setState(() {});
          })
          .catchError((error) {
            if (_isDebug) print('Video initialization error: $error');
          });
  }
}
