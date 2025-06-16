import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/widgets/daily_verse_card.dart';
import 'package:wisdomwalk/widgets/sister_spotlight_card.dart';
import 'package:wisdomwalk/widgets/quick_access_buttons.dart';
import 'package:wisdomwalk/widgets/upcoming_events_list.dart';
import 'package:wisdomwalk/widgets/todays_encouragement.dart';
import 'package:go_router/go_router.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'WisdomWalk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh home data
            await Future.delayed(const Duration(seconds: 1));
          },
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(user?.fullName ?? 'Sister'),
                  const SizedBox(height: 24),
                  const DailyVerseCard(),
                  const SizedBox(height: 24),
                  const TodaysEncouragement(),
                  const SizedBox(height: 24),
                  const SisterSpotlightCard(),
                  const SizedBox(height: 24),
                  const QuickAccessButtons(),
                  const SizedBox(height: 24),
                  const UpcomingEventsList(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(name, style: Theme.of(context).textTheme.displayMedium),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }
}
