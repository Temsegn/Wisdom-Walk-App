import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:wisdomwalk/providers/auth_provider.dart';

import 'package:wisdomwalk/providers/event_provider.dart';
import 'package:wisdomwalk/providers/reflection_provider.dart';

import 'package:wisdomwalk/providers/anonymous_share_provider.dart';

import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:wisdomwalk/views/dashboared/anonymous_share_tab.dart';

import 'package:wisdomwalk/views/dashboared/her_move_tab.dart';
import 'package:wisdomwalk/views/dashboared/home_tab.dart';

import 'package:wisdomwalk/views/dashboared/prayer_wall_tab.dart';
import 'package:wisdomwalk/views/dashboared/wisdom_circles_tab.dart';

import 'package:wisdomwalk/widgets/booking_form.dart';
import 'package:wisdomwalk/models/event_model.dart';

import 'package:wisdomwalk/views/chat/chat_list_screen.dart';
import 'dart:async';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:wisdomwalk/providers/notification_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  AnimationController? _animationController;
  AnimationController? _breathingController;
  Animation<double>? _scaleAnimation;

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

    // Check for initial tab from route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = ModalRoute.of(context)?.settings.arguments as Map?;
      final tabIndex = extra?['tab'] as int? ?? 0;
      if (tabIndex != _currentIndex) {
        onTabTapped(tabIndex);
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
      onTabTapped(tabIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController?.dispose();
    _breathingController?.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
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
        onTap: onTabTapped,
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
}

// AnonymousShareTab Implementation

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
