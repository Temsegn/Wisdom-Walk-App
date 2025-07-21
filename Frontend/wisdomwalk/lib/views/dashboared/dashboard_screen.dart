import 'dart:math';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/models/chat_model.dart';
import 'package:wisdomwalk/models/user_model.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/chat_provider.dart';
import 'package:wisdomwalk/providers/event_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/reflection_provider.dart';
import 'package:wisdomwalk/providers/user_provider.dart';
import 'package:wisdomwalk/providers/wisdom_circle_provider.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:wisdomwalk/views/chat/chat_screen.dart';
import 'package:wisdomwalk/views/dashboared/her_move_tab.dart';
import 'package:wisdomwalk/views/dashboared/home_tab.dart';
import 'package:wisdomwalk/views/dashboared/prayer_wall_tab.dart';
import 'package:wisdomwalk/views/settings/profile_settings_screen.dart';
import 'package:wisdomwalk/widgets/add_prayer_modal.dart';
import 'package:wisdomwalk/widgets/anonymous_share_card.dart';
import 'package:wisdomwalk/widgets/booking_form.dart';
import 'package:wisdomwalk/models/event_model.dart';
import 'package:universal_html/html.dart' as html;
import 'package:video_player/video_player.dart';
import 'package:wisdomwalk/views/chat/chat_list_screen.dart';
import 'dart:async';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:wisdomwalk/providers/notification_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  AnimationController? _animationController;
  AnimationController? _breathingController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOutCubic,
      ),
    );
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController!, curve: Curves.easeInOut),
    );

    // Check for initial tab from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = ModalRoute.of(context)?.settings.arguments as Map?;
      final tabIndex = extra?['tab'] as int? ?? 0;
      if (tabIndex != _currentIndex) {
        _onTabTapped(tabIndex);
      }
    });
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle tab changes from route updates
    final extra = ModalRoute.of(context)?.settings.arguments as Map?;
    final tabIndex = extra?['tab'] as int? ?? _currentIndex;
    if (tabIndex != _currentIndex) {
      _onTabTapped(tabIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController?.dispose();
    _breathingController?.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    print('Tapped index: $index');
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
      _pageController.jumpToPage(index);
      _animationController?.forward().then(
        (_) => _animationController?.reverse(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _scaleAnimation ?? const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation?.value ?? 1.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FAFF),
                    Color(0xFFEEF2FF),
                    Color(0xFFE0E7FF),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  print('Page changed to: $index');
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  HomeTab(), // Pass the callback
                  PrayerWallTab(),
                  WisdomCirclesTab(),
                  AnonymousShareTab(),
                  HerMoveTab(),
                  ChatListScreen(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: const Color(0xFF94A3B8),
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 26),
            activeIcon: Icon(Icons.home_rounded, size: 26),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined, size: 26),
            activeIcon: Icon(Icons.volunteer_activism_rounded, size: 26),
            label: 'Prayer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded, size: 26),
            activeIcon: Icon(Icons.people_rounded, size: 26),
            label: 'Circles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline_rounded, size: 26),
            activeIcon: Icon(Icons.mail_rounded, size: 26),
            label: 'Share',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined, size: 26),
            activeIcon: Icon(Icons.map_rounded, size: 26),
            label: 'Her Move',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded, size: 26),
            activeIcon: Icon(Icons.chat_bubble_rounded, size: 26),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubicEmphasized,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFA855F7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          size: 26,
        ),
      ),
      activeIcon: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubicEmphasized,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 16,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0xFF6366F1).withOpacity(0.2),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(activeIcon, color: Colors.white, size: 26),
      ),
      label: label,
    );
  }
}

// Enhanced HomeTab Implementation
class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

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
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState._onTabTapped(1);
                  }
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
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState._onTabTapped(2);
                  }
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
                  final dashboardState =
                      context.findAncestorStateOfType<_DashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState._onTabTapped(5);
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
                          _showLoginPrompt(context, 'view your profile');
                          return;
                        }
                        if (prayer.userId != userId) {
                          _showErrorSnackBar(
                            context,
                            'You can only view your own profile',
                          );
                          return;
                        }
                        context.push('/profile');
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
                                    image: NetworkImage(prayer.userAvatar!),
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
                        color: const Color(0xFF1DA1F2), // X's blue color
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

                          // Check if user is logged in
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          if (!authProvider.isAuthenticated) {
                            _showLoginPrompt(context, 'start a chat');
                            return;
                          }

                          // Check if the prayer is anonymous
                          if (prayer.isAnonymous) {
                            _showErrorSnackBar(
                              context,
                              'Cannot chat with anonymous users',
                            );
                            return;
                          }

                          // Prevent chatting with self       //////////////////////////////////////////
                          // if (prayer.userId == authProvider.userId) {
                          //   _showErrorSnackBar(context, 'You cannot chat with yourself');
                          //   return;
                          // }

                          // Check if the target user is blocked
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

                            // Check for existing chat or create a new one
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

                            // Navigate to the chat tab in DashboardScreen
                            context.go(
                              '/dashboard',
                              extra: {'tab': 5},
                            ); // Select chat tab (index 5)

                            // Push ChatScreen after a slight delay to ensure tab switch
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
                              hintText: 'Reply to this prayer…',
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
                                  _showLoginPrompt(
                                    context,
                                    'view your profile',
                                  );
                                  return;
                                }
                                if (comment.userId != userId) {
                                  _showErrorSnackBar(
                                    context,
                                    'You can only view your own profile',
                                  );
                                  return;
                                }
                                context.push('/profile');
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
                                              comment.userAvatar!,
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
                      'No comments yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF657786), // X's secondary text
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

class WisdomCirclesTab extends StatefulWidget {
  const WisdomCirclesTab({Key? key}) : super(key: key);

  @override
  State<WisdomCirclesTab> createState() => _WisdomCirclesTabState();
}

class _WisdomCirclesTabState extends State<WisdomCirclesTab>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
              colors: [Color(0xFF74B9FF), Color(0xFF0984E3), Color(0xFF6C5CE7)],
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFF8F9FA)],
              ).createShader(bounds),
          child: const Text(
            'Wisdom Circles',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
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
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F4FD), Color(0xFFF0F8FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF74B9FF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Join topic-based communities for deeper connection',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2D3436),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'My Circles',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF74B9FF),
                              ),
                            ),
                          ),
                        );
                      }

                      if (myCircles.isEmpty) {
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF74B9FF),
                                      Color(0xFF0984E3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.people_outline,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No circles joined yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF636E72),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Discover and join circles below',
                                style: TextStyle(color: Color(0xFF636E72)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children:
                            myCircles.map((circle) {
                              return WisdomCircleCard(
                                circle: circle,
                                isJoined: true,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.push('/wisdom-circle/${circle.id}');
                                },
                              );
                            }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Discover New Circles',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF74B9FF),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children:
                            discoverCircles.map((circle) {
                              return WisdomCircleCard(
                                circle: circle,
                                isJoined: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  final provider =
                                      Provider.of<WisdomCircleProvider>(
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
                  const SizedBox(height: 32),
                  const Text(
                    'Upcoming Live Chats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLiveChatItem(
                    'Marriage & Ministry',
                    'Building Strong Foundations',
                    'Tonight 8PM',
                    const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                  ),
                  _buildLiveChatItem(
                    'Healing & Hope',
                    'Finding Peace in Storms',
                    'Tomorrow 7PM',
                    const LinearGradient(
                      colors: [Color(0xFF74B9FF), Color(0xFF0984E3)],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveChatItem(
    String title,
    String subtitle,
    String time,
    LinearGradient gradient,
  ) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            // Handle live chat tap
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _WisdomCircleCardState extends State<WisdomCircleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WisdomCircleProvider>(context, listen: false);
    final hasNewMessages = true; // Simulate new messages for demo
    final sampleMessage = 'Ms: "Thank you all for the prayers! ✨"';

    LinearGradient cardGradient = _getCardGradient();
    LinearGradient iconGradient = _getIconGradient();
    String buttonText = widget.isJoined ? 'Open' : 'Join';
    LinearGradient buttonGradient =
        widget.isJoined
            ? const LinearGradient(
              colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
            )
            : const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
            );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onTap();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: iconGradient,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: iconGradient.colors.first.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.circle.name[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.circle.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.circle.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF636E72),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: buttonGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: buttonGradient.colors.first
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                if (widget.isJoined) {
                                  widget.onTap();
                                } else {
                                  await provider.joinCircle(
                                    circleId: widget.circle.id,
                                    userId: 'user123',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ Joined ${widget.circle.name}!',
                                      ),
                                      backgroundColor: const Color(0xFF00B894),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                buttonText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.people,
                                  size: 14,
                                  color: Color(0xFF636E72),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.circle.memberCount} members',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF636E72),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasNewMessages) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE84393),
                                    Color(0xFFD63031),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '⭕ 3 new messages',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sampleMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D3436),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getCardGradient() {
    switch (widget.circle.id) {
      case '1': // Single & Purposeful
        return const LinearGradient(
          colors: [Color(0xFFFFE4E6), Color(0xFFFFF0F2)],
        );
      case '2': // Marriage & Ministry
        return const LinearGradient(
          colors: [Color(0xFFE8E4FF), Color(0xFFF0EDFF)],
        );
      case '3': // Motherhood in Christ
        return const LinearGradient(
          colors: [Color(0xFFE4F3FF), Color(0xFFF0F9FF)],
        );
      case '4': // Healing & Forgiveness
        return const LinearGradient(
          colors: [Color(0xFFE4FFE8), Color(0xFFF0FFF2)],
        );
      case '5': // Mental Health & Faith
        return const LinearGradient(
          colors: [Color(0xFFFFF4E4), Color(0xFFFFF9F0)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFFAFAFA)],
        );
    }
  }

  LinearGradient _getIconGradient() {
    switch (widget.circle.id) {
      case '1':
        return const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
        );
      case '2':
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
        );
      case '3':
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
        );
      case '4':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        );
      case '5':
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFF616161)],
        );
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
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    final shareProvider = Provider.of<AnonymousShareProvider>(
      context,
      listen: false,
    );
    shareProvider.fetchAllShares();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'current_user';

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
              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFFE84393)],
            ),
          ),
        ),
        title: ShaderMask(
          shaderCallback:
              (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFF8F9FA)],
              ).createShader(bounds),
          child: const Text(
            'Anonymous Share',
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
            margin: const EdgeInsets.only(right: 16),
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
                size: 24,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/settings');
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE84393), Color(0xFFD63031)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Confessions'),
                Tab(text: 'Testimonies'),
                Tab(text: 'Struggles'),
              ],
              onTap: (index) {
                HapticFeedback.selectionClick();
                final shareProvider = Provider.of<AnonymousShareProvider>(
                  context,
                  listen: false,
                );
                if (index == 0) {
                  shareProvider.fetchAllShares();
                } else {
                  shareProvider.fetchShares(
                    type: AnonymousShareType.values[index - 1],
                  );
                }
              },
            ),
          ),
        ),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildShareList(null, userId),
              _buildShareList(AnonymousShareType.confession, userId),
              _buildShareList(AnonymousShareType.testimony, userId),
              _buildShareList(AnonymousShareType.struggle, userId),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showShareAnonymouslyModal(context);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildShareList(AnonymousShareType? type, String userId) {
    return Consumer<AnonymousShareProvider>(
      builder: (context, shareProvider, child) {
        if (shareProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
            ),
          );
        }

        if (shareProvider.error != null) {
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
                    'Error loading shares',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFD63031),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shareProvider.error!,
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
                      onPressed:
                          () =>
                              type == null
                                  ? shareProvider.fetchAllShares()
                                  : shareProvider.fetchShares(type: type),
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

        if (shareProvider.shares.isEmpty) {
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
                  Text(
                    'No ${type?.toString().split('.').last ?? 'shares'} yet',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF636E72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to share anonymously',
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
            if (type == null) {
              await shareProvider.fetchAllShares();
            } else {
              await shareProvider.fetchShares(type: type);
            }
          },
          color: const Color(0xFF6C5CE7),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: shareProvider.shares.length,
            itemBuilder: (context, index) {
              final share = shareProvider.shares[index];
              return AnonymousShareCard(
                share: share,
                currentUserId: userId,
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/anonymous-share/${share.id}');
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showShareAnonymouslyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ShareAnonymouslyModal(
            shareProvider: Provider.of<AnonymousShareProvider>(
              context,
              listen: false,
            ),
          ),
    );
  }
}

class ShareAnonymouslyModal extends StatefulWidget {
  final AnonymousShareProvider shareProvider;

  const ShareAnonymouslyModal({Key? key, required this.shareProvider})
    : super(key: key);

  @override
  State<ShareAnonymouslyModal> createState() => _ShareAnonymouslyModalState();
}

class _ShareAnonymouslyModalState extends State<ShareAnonymouslyModal>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  AnonymousShareType _selectedType = AnonymousShareType.testimony;
  bool _isLoading = false;
  final LocalStorageService _localStorageService = LocalStorageService();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8F9FA)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 6,
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF636E72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Text(
                    'Share Anon.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : _submitShare,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[200]!, Colors.grey[100]!],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What would you like to share?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[50]!, Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6C5CE7).withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonFormField<AnonymousShareType>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            labelStyle: TextStyle(
                              color: Color(0xFF636E72),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          items:
                              AnonymousShareType.values.map((type) {
                                return DropdownMenuItem<AnonymousShareType>(
                                  value: type,
                                  child: Text(
                                    type
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[50]!, Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6C5CE7).withOpacity(0.3),
                          ),
                        ),
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: 12,
                          minLines: 8,
                          decoration: const InputDecoration(
                            hintText: 'Share your heart...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                            hintStyle: TextStyle(
                              color: Color(0xFF636E72),
                              fontSize: 16,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF2D3436),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your content';
                            }
                            if (value.trim().length < 10) {
                              return 'Content must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitShare() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please log in to share'),
            backgroundColor: const Color(0xFFE17055),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    try {
      final token = await _localStorageService.getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final success = await widget.shareProvider.addShare(
        userId: user.id,
        content: _contentController.text.trim(),
        type: _selectedType,
        title:
            _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : null,
      );

      setState(() => _isLoading = false);
      if (success && context.mounted) {
        Navigator.pop(context);
        final newShare = widget.shareProvider.shares.firstWhereOrNull(
          (share) =>
              share.userId == user.id &&
              share.content == _contentController.text.trim(),
        );

        if (newShare != null) {
          context.push('/anonymous-share/${newShare.id}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Share posted successfully'),
              backgroundColor: const Color(0xFF00B894),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Share posted successfully'),
              backgroundColor: const Color(0xFFFF9800),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else if (context.mounted) {
        throw Exception(widget.shareProvider.error ?? 'Unknown error');
      }
      // for the purpose of the test for remote repository
    } catch (e) {
      setState(() => _isLoading = false);
      if (context.mounted) {
        final errorMessage =
            e.toString().contains('Invalid token') ||
                    e.toString().contains('No authentication token found')
                ? 'Authentication failed: Please log in again'
                : 'Failed to post share: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFD63031),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
