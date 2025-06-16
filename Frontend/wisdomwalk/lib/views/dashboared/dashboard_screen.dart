import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/providers/wisdom_circle_provider.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/models/prayer_model.dart';
import 'package:wisdomwalk/widgets/add_anonymous_share_button.dart';

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
        children: const [
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

// Home Tab Implementation (keeping existing code)
class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

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
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF4A4A4A),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF4A4A4A)),
            onPressed: () {
              context.go('/settings');
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
                _buildDailyVerse(),
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
    );
  }

  Widget _buildDailyVerse() {
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
            '"She is clothed with strength and dignity, and she laughs without fear of the future."',
            style: TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Proverbs 31:25',
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
                onPressed: () {},
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
                onPressed: () {},
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

  Widget _buildFeaturedTestimony() {
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
                  child: Icon(Icons.person, color: Color(0xFFD4A017), size: 24),
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
                    style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Color(0xFFD4A017),
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'After years of struggling with anxiety, I found peace through prayer and community support. This journey taught me that vulnerability is not weakness—it\'s the path to true healing.',
            style: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
          ),
          const SizedBox(height: 15),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Read Full Testimony',
                style: TextStyle(
                  color: Color(0xFFD4A017),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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
                  dashboardState?._onTabTapped(1);
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
                  dashboardState?._onTabTapped(2);
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
                  dashboardState?._onTabTapped(5);
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

  Widget _buildUpcomingEvents() {
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
        _buildEventCard(
          title: 'Virtual Prayer Night',
          date: 'June 15, 2023',
          time: '7:00 PM',
          platform: 'Zoom',
        ),
        const SizedBox(height: 16),
        _buildEventCard(
          title: 'Bible Study: Proverbs',
          date: 'June 18, 2023',
          time: '6:30 PM',
          platform: 'Telegram',
        ),
      ],
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String time,
    required String platform,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8E2DB)),
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date • $time • $platform',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4A017),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}

// Updated Prayer Wall Tab Implementation
class PrayerWallTab extends StatefulWidget {
  const PrayerWallTab({Key? key}) : super(key: key);

  @override
  State<PrayerWallTab> createState() => _PrayerWallTabState();
}

class _PrayerWallTabState extends State<PrayerWallTab> {
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

          if (prayerProvider.prayers.isEmpty) {
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

          return RefreshIndicator(
            onRefresh: () async {
              await prayerProvider.fetchPrayers();
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
          Row(
            children: [
              _buildActionButton(
                icon: Icons.volunteer_activism,
                label: 'Praying (${prayer.prayingUsers.length})',
                color: const Color(0xFF9C27B0),
                onPressed: () {
                  // Handle praying action
                },
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: 'Encourage',
                color: Colors.grey[600]!,
                onPressed: () {
                  // Handle encourage action
                },
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat,
                label: 'Chat',
                color: const Color(0xFF2196F3),
                onPressed: () {
                  // Handle chat action
                },
              ),
            ],
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
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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

  void _showAddPrayerDialog(BuildContext context) {
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

// Keep existing implementations for other tabs...
class WisdomCirclesTab extends StatelessWidget {
  const WisdomCirclesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Wisdom Circles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Consumer<WisdomCircleProvider>(
        builder: (context, circleProvider, child) {
          if (circleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (circleProvider.circles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No circles yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create or join a wisdom circle',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await circleProvider.fetchCircles();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: circleProvider.circles.length,
              itemBuilder: (context, index) {
                final circle = circleProvider.circles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE6E1F5),
                      child: Text(
                        circle.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFD4A017),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      circle.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${circle.memberCount} members'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.go('/wisdom-circle/${circle.id}');
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show create circle dialog
        },
        backgroundColor: const Color(0xFFD4A017),
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/settings');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD4A017),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4A017),
          tabs: const [
            Tab(text: 'Confessions'),
            Tab(text: 'Testimonies'),
            Tab(text: 'Struggles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShareList('confession'),
          _buildShareList('testimony'),
          _buildShareList('struggle'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add anonymous share dialog
        },
        backgroundColor: const Color(0xFFD4A017),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShareList(String type) {
    return Consumer<AnonymousShareProvider>(
      builder: (context, shareProvider, child) {
        final shares =
            shareProvider.shares
                .where((share) => share.type.toString().split('.').last == type)
                .toList();

        if (shares.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${type}s yet',
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
            await shareProvider.fetchShares();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shares.length,
            itemBuilder: (context, index) {
              final share = shares[index];
              return Card(
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
                      Text(share.content, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Handle heart reaction
                            },
                            icon: const Icon(Icons.favorite_border, size: 18),
                            label: Text('${share.heartCount}'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton.icon(
                            onPressed: () {
                              // Handle prayer reaction
                            },
                            icon: const Icon(
                              Icons.volunteer_activism_outlined,
                              size: 18,
                            ),
                            label: Text('${share.prayerCount}'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFD4A017),
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton.icon(
                            onPressed: () {
                              // Handle virtual hug
                            },
                            icon: const Icon(Icons.favorite, size: 18),
                            label: Text('${share.hugCount}'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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

class HerMoveTab extends StatelessWidget {
  const HerMoveTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Her Move',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Consumer<HerMoveProvider>(
        builder: (context, herMoveProvider, child) {
          if (herMoveProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (herMoveProvider.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No travel requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your travel plans or help others',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await herMoveProvider.fetchRequests();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: herMoveProvider.requests.length,
              itemBuilder: (context, index) {
                final request = herMoveProvider.requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFFD4A017),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${request.fromLocation} → ${request.toLocation}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${request.startDate.day}/${request.startDate.month}/${request.startDate.year}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              request.authorName,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          request.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.go('/location-request/${request.id}');
                                },
                                child: const Text('View Details'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle help offer
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD4A017),
                                ),
                                child: const Text('Offer Help'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/add-location-request');
        },
        backgroundColor: const Color(0xFFD4A017),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// New Personal Chat Tab Implementation - Mobile Friendly
class PersonalChatTab extends StatefulWidget {
  const PersonalChatTab({Key? key}) : super(key: key);

  @override
  State<PersonalChatTab> createState() => _PersonalChatTabState();
}

class _PersonalChatTabState extends State<PersonalChatTab> {
  String? selectedChatId;

  @override
  Widget build(BuildContext context) {
    if (selectedChatId != null) {
      return _buildChatScreen();
    }

    return _buildSistersListScreen();
  }

  Widget _buildSistersListScreen() {
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSisterCard(
            id: 'sarah',
            name: 'Meron Getiye',
            status: 'Online',
            lastMessage: 'Hello sister! How are you doing today?',
            time: '10:30 AM',
            isOnline: true,
            unreadCount: 2,
          ),
          const SizedBox(height: 12),
          _buildSisterCard(
            id: 'grace',
            name: 'Betlhem Gedion',
            status: '2 hours ago',
            lastMessage: 'Thank you for your prayers 🙏',
            time: '8:15 AM',
            isOnline: false,
            unreadCount: 0,
          ),
          const SizedBox(height: 12),
          _buildSisterCard(
            id: 'hannah',
            name: 'Hanna Tsfaye',
            status: 'Online',
            lastMessage: 'See you at Bible study tonight!',
            time: 'Yesterday',
            isOnline: true,
            unreadCount: 1,
          ),
          const SizedBox(height: 12),
          _buildSisterCard(
            id: 'ruth',
            name: 'Bersabeh Tadesse',
            status: '1 day ago',
            lastMessage: 'Praying for your family ❤️',
            time: '2 days ago',
            isOnline: false,
            unreadCount: 0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show new chat dialog
        },
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildSisterCard({
    required String id,
    required String name,
    required String status,
    required String lastMessage,
    required String time,
    required bool isOnline,
    required int unreadCount,
  }) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 25,
              child: Text(
                name[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 18,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    lastMessage,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE91E63),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: isOnline ? Colors.green : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.phone, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.videocam, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          setState(() {
            selectedChatId = id;
          });
        },
      ),
    );
  }

  Widget _buildChatScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            setState(() {
              selectedChatId = null;
            });
          },
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  radius: 20,
                  child: const Text(
                    'S',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seble M.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessage(
                  message: 'Hello sister! How are you doing today?',
                  time: '10:30 AM',
                  isMe: false,
                ),
                const SizedBox(height: 16),
                _buildMessage(
                  message:
                      'I\'m doing well, thank you! Praying for you today 🙏',
                  time: '10:32 AM',
                  isMe: true,
                ),
                const SizedBox(height: 16),
                _buildMessage(
                  message:
                      'That means so much to me. How is your family doing?',
                  time: '10:33 AM',
                  isMe: false,
                ),
                const SizedBox(height: 16),
                _buildMessage(
                  message:
                      'They\'re doing well, thank you for asking! My mom\'s surgery went great.',
                  time: '10:35 AM',
                  isMe: true,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFE91E63),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        // Handle send message
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required String message,
    required String time,
    required bool isMe,
  }) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 16,
            child: const Text(
              'S',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFE91E63) : Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFFE91E63).withOpacity(0.2),
            radius: 16,
            child: const Text(
              'M',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
