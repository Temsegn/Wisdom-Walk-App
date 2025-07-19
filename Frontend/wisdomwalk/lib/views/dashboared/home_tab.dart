import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:wisdomwalk/models/event_model.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/event_provider.dart';
import 'package:wisdomwalk/providers/notification_provider.dart';
import 'package:wisdomwalk/providers/reflection_provider.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:wisdomwalk/views/settings/profile_settings_screen.dart';
import 'package:wisdomwalk/widgets/add_prayer_button.dart';
import 'package:wisdomwalk/widgets/booking_form.dart';

// Enhanced HomeTab Implementation
class HomeTab extends StatefulWidget {
  final Function(int) onTabTapped; // Added callback parameter
  const HomeTab({Key? key, required this.onTabTapped}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  final TextEditingController _reflectionController = TextEditingController();
  AnimationController? _fadeController;
  AnimationController? _slideController;
  AnimationController? _shimmerController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController!, curve: Curves.easeOutCubic),
    );
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController!, curve: Curves.easeInOut),
    );

    // Start animations with stagger
    _fadeController?.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController?.forward();
    });

    // Fetch data
    Provider.of<EventProvider>(context, listen: false).fetchEvents();
    Provider.of<AnonymousShareProvider>(
      context,
      listen: false,
    ).fetchShares(type: AnonymousShareType.testimony);
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    _fadeController?.dispose();
    _slideController?.dispose();
    _shimmerController?.dispose();
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
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFFA855F7),
                Color(0xFFEC4899),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
          child: const Text(
            'WisdomWalk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 32,
              letterSpacing: 1.5,
            ),
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/notifications');
                      },
                    ),
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
        child: SlideTransition(
          position:
              _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8FAFF), Color(0xFFFFFFFF)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDailyVerse(context),
                      const SizedBox(height: 40),
                      buildFeaturedTestimony(),
                      const SizedBox(height: 40),
                      _buildQuickAccessButtons(context),
                      const SizedBox(height: 40),
                      _buildUpcomingEvents(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _shimmerAnimation ?? const AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF10B981),
                  Color(0xFF059669),
                  Color(0xFF047857),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BookingForm(),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(
                Icons.event_available_rounded,
                color: Colors.white,
                size: 24,
              ),
              label: const Text(
                'Book Session',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFBBF24),
            Color(0xFFF59E0B),
            Color(0xFFEA580C),
            Color(0xFFDC2626),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.4),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.2),
            blurRadius: 64,
            offset: const Offset(0, 32),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Daily Verse',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            verseText,
            style: const TextStyle(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.6,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            verseReference,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showShareModal(context, shareMessage);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
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
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Reflect on the Daily Verse',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                        child: TextFormField(
                          controller: _reflectionController,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'Write your reflection...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            hintStyle: TextStyle(color: Color(0xFF636E72)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your reflection';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF636E72),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6C5CE7,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
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
                                            SnackBar(
                                              content: const Text(
                                                'Reflection saved successfully',
                                              ),
                                              backgroundColor: const Color(
                                                0xFF00B894,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                          _showShareModal(
                                            context,
                                            'My reflection on $verseReference:\n\n${_reflectionController.text.trim()}\n\nJoin me on WisdomWalk: https://wisdomwalk.app',
                                          );
                                          _reflectionController.clear();
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'Save & Share',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFF)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareIcon(
                      context: context,
                      iconPath: 'assets/images/whatsapp_icon.png',
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => _shareTo(context, shareMessage, 'whatsapp'),
                    ),
                    _buildShareIcon(
                      context: context,
                      iconPath: 'assets/images/facebook_icon.png',
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                      onTap: () => _shareTo(context, shareMessage, 'facebook'),
                    ),
                    _buildShareIcon(
                      context: context,
                      iconPath: 'assets/images/twitter_icon.png',
                      label: 'Twitter',
                      color: const Color(0xFF1DA1F2),
                      onTap: () => _shareTo(context, shareMessage, 'twitter'),
                    ),
                    _buildShareIcon(
                      context: context,
                      iconPath: 'assets/images/telegram_icon.png',
                      label: 'Telegram',
                      color: const Color(0xFF0088CC),
                      onTap: () => _shareTo(context, shareMessage, 'telegram'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareIcon({
    required BuildContext context,
    required String iconPath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(_getIconForPlatform(label), color: color, size: 32),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getIconForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'whatsapp':
        return Icons.chat;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email;
      case 'telegram':
        return Icons.send;
      default:
        return Icons.share;
    }
  }

  Future<void> _shareTo(
    BuildContext context,
    String message,
    String platform,
  ) async {
    final encodedMessage = Uri.encodeComponent(message);
    String url;
    String fallbackUrl;

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

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        Navigator.pop(context);
      } else if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.platformDefault,
        );
        Navigator.pop(context);
      } else {
        await Clipboard.setData(ClipboardData(text: message));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $platform. Copied to clipboard.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: message));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing to $platform. Copied to clipboard.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  Widget buildFeaturedTestimony() {
    return Consumer<AnonymousShareProvider>(
      builder: (context, shareProvider, child) {
        if (shareProvider.shares.isEmpty && !shareProvider.isLoading) {
          shareProvider.fetchShares(type: AnonymousShareType.testimony);
        }

        if (shareProvider.isLoading) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            ),
          );
        }

        if (shareProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(24),
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
                Text(
                  shareProvider.error!,
                  style: const TextStyle(
                    color: Color(0xFFD63031),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        () => shareProvider.fetchShares(
                          type: AnonymousShareType.testimony,
                        ),
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
          );
        }

        final testimonies =
            shareProvider.shares
                .where(
                  (share) => share.category == AnonymousShareType.testimony,
                )
                .toList();

        if (testimonies.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[50]!, Colors.white],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[200]!],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No featured testimony available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF636E72),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final testimony = testimonies.reduce(
          (a, b) => a.heartCount > b.heartCount ? a : b,
        );
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.currentUser?.id ?? 'current_user';
        final localStorageService = LocalStorageService();
        final isLiked = testimony.likes.contains(userId);
        final isPraying = testimony.prayers.any(
          (prayer) => prayer['user'] == userId,
        );
        final hasHugged = testimony.virtualHugs.any(
          (hug) => hug['user'] == userId,
        );

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00B894),
                                          Color(0xFF00CEC9),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Text(
                                      'TESTIMONY',
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
                                    _formatTimeAgo(testimony.createdAt),
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
                    if (testimony.title != null &&
                        testimony.title!.isNotEmpty) ...[
                      Text(
                        testimony.title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      testimony.content,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF636E72),
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (testimony.images.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: testimony.images.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  testimony.images[index]['url']!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.grey[200]!,
                                              Colors.grey[100]!,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.error_outline,
                                          color: Color(0xFF636E72),
                                        ),
                                      ),
                                ),
                              ),
                            );
                          },
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
                                isPraying
                                    ? Icons.volunteer_activism
                                    : Icons.volunteer_activism_outlined,
                            label: '${testimony.prayerCount}',
                            color: const Color(0xFF6C5CE7),
                            isActive: isPraying,
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              final token =
                                  await localStorageService.getAuthToken();
                              if (userId == 'current_user' || token == null) {
                                _showLoginPrompt(
                                  context,
                                  'pray for this testimony',
                                );
                                return;
                              }
                              final success = await shareProvider.togglePraying(
                                shareId: testimony.id,
                                userId: userId,
                                message: 'Praying for you ❤️',
                              );
                              if (success && context.mounted) {
                                _showSuccessSnackBar(
                                  context,
                                  isPraying
                                      ? 'Removed from praying list'
                                      : 'You are now praying for this testimony 🙏',
                                  const Color(0xFF6C5CE7),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            icon: Icons.comment_outlined,
                            label: '${testimony.commentsCount}',
                            color: const Color(0xFF74B9FF),
                            isActive: testimony.comments.any(
                              (comment) => comment.userId == userId,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              if (userId == 'current_user') {
                                _showLoginPrompt(
                                  context,
                                  'comment on this testimony',
                                );
                                return;
                              }
                              context.push('/anonymous-share/${testimony.id}');
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            icon:
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                            label: '${testimony.heartCount}',
                            color: const Color(0xFFE17055),
                            isActive: isLiked,
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              final token =
                                  await localStorageService.getAuthToken();
                              if (userId == 'current_user' || token == null) {
                                _showLoginPrompt(
                                  context,
                                  'heart this testimony',
                                );
                                return;
                              }
                              final success = await shareProvider.toggleHeart(
                                shareId: testimony.id,
                                userId: userId,
                              );
                              if (success && context.mounted) {
                                _showSuccessSnackBar(
                                  context,
                                  isLiked
                                      ? 'Removed heart'
                                      : 'Testimony hearted! ❤️',
                                  const Color(0xFFE17055),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionButton(
                            icon:
                                hasHugged
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                            label: '${testimony.hugCount}',
                            color: const Color(0xFFE84393),
                            isActive: hasHugged,
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              final token =
                                  await localStorageService.getAuthToken();
                              if (userId == 'current_user' || token == null) {
                                _showLoginPrompt(context, 'send a virtual hug');
                                return;
                              }
                              final success = await shareProvider
                                  .sendVirtualHug(
                                    shareId: testimony.id,
                                    userId: userId,
                                    scripture: '',
                                  );
                              if (success && context.mounted) {
                                _showSuccessSnackBar(
                                  context,
                                  'Virtual hug sent! 🤗',
                                  const Color(0xFFE84393),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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
                      testimony.isReported
                          ? Icons.report_problem
                          : Icons.report_problem_outlined,
                      color:
                          testimony.isReported
                              ? const Color(0xFFE17055)
                              : const Color(0xFF636E72),
                      size: 20,
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final token = await localStorageService.getAuthToken();
                      if (userId == 'current_user' || token == null) {
                        _showLoginPrompt(context, 'report this testimony');
                        return;
                      }
                      _showReportDialog(testimony, userId);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  void _showReportDialog(AnonymousShareModel testimony, String userId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Report Testimony',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please provide a reason for reporting this testimony.',
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
                  final shareProvider = Provider.of<AnonymousShareProvider>(
                    context,
                    listen: false,
                  );
                  final success = await shareProvider.reportShare(
                    shareId: testimony.id,
                    userId: userId,
                    reason: reason,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showSuccessSnackBar(
                      context,
                      success
                          ? 'Testimony reported successfully 🚨'
                          : 'Failed to report testimony',
                      success
                          ? const Color(0xFFE17055)
                          : const Color(0xFFD63031),
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

  Widget _buildQuickAccessButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.volunteer_activism,
                title: 'Prayer Wall',
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTabTapped(1); // Use callback
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.people,
                title: 'Wisdom Circles',
                gradient: const LinearGradient(
                  colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTabTapped(2); // Use callback
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessButton(
                icon: Icons.chat,
                title: 'Personal Chat',
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTabTapped(5); // Use callback
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
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final now = DateTime.now();

        // Loading state
        if (eventProvider.isLoading) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF6C5CE7)),
              ),
            ),
          );
        }

        // Error state
        if (eventProvider.error != null) {
          return Container(
            padding: const EdgeInsets.all(24),
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
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  eventProvider.error!,
                  style: const TextStyle(
                    color: Color(0xFFD63031),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: eventProvider.fetchEvents,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        // Filter upcoming events: those that haven't ended yet

        final upcomingEvents =
            eventProvider.events.where((event) {
              final duration = _getDuration(event.duration);
              final endTime = event.dateTime.add(duration);
              return now.isBefore(
                endTime,
              ); // Only future or currently live events
            }).toList();

        // Empty state
        if (upcomingEvents.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[50]!, Colors.white],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[200]!],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.event_outlined,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No upcoming events',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF636E72),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Upcoming events list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingEvents.length,
              itemBuilder: (context, index) {
                return buildEventCard(
                  context: context,
                  event: upcomingEvents[index],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Duration _getDuration(Object? duration) {
    // Helper function to safely cast duration or return default
    if (duration is Duration) {
      return duration;
    }
    return const Duration(hours: 1);
  }

  Widget buildEventCard({
    required BuildContext context,
    required EventModel event,
  }) {
    final now = DateTime.now();
    final duration = _getDuration(event.duration);
    final endTime = event.dateTime.add(duration);

    bool isLive = now.isAfter(event.dateTime) && now.isBefore(endTime);
    bool hasEnded = now.isAfter(endTime);
    bool hasStarted = now.isAfter(event.dateTime);

    final timeLeft = event.dateTime.difference(now);

    String formatTimeLeft(Duration duration) {
      if (duration.inDays > 1) return 'Starts in ${duration.inDays} days';
      if (duration.inDays == 1) return 'Starts tomorrow';
      if (duration.inHours >= 1) {
        return 'Starts in ${duration.inHours}h ${duration.inMinutes % 60}m';
      }
      if (duration.inMinutes > 1)
        return 'Starts in ${duration.inMinutes} minutes';
      return 'Starting soon';
    }

    String badgeText = '';
    Color badgeColor = Colors.transparent;

    if (isLive) {
      badgeText = 'LIVE NOW';
      badgeColor = Colors.red;
    } else if (!hasStarted) {
      badgeText = formatTimeLeft(timeLeft);
      badgeColor = const Color(0xFF0984E3);
    } else if (hasEnded) {
      // No badge after event ended; you can change to "Ended" if you want
      badgeText = '';
      badgeColor = Colors.transparent;
    }

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFDCB6E), Color(0xFFE17055)],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.event, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} • '
                    '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')} • '
                    '${event.platform}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 6),
                  badgeText.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 13,
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF636E72),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final uri = Uri.parse(event.link);
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode:
                          kIsWeb
                              ? LaunchMode.platformDefault
                              : LaunchMode.externalApplication,
                    );
                  } else {
                    throw 'Could not launch URL';
                  }
                } catch (_) {
                  await Clipboard.setData(ClipboardData(text: uri.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not open link. Copied to clipboard.',
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 4,
              ),
              child: const Text(
                'Join',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
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
