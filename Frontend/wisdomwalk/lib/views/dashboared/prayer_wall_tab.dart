import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/views/prayer_wall/prayer_detail_screen.dart';
import 'package:wisdomwalk/widgets/prayer_card.dart';

class PrayerWallTab extends StatefulWidget {
  const PrayerWallTab({Key? key}) : super(key: key);

  @override
  State<PrayerWallTab> createState() => _PrayerWallTabState();
}

class _PrayerWallTabState extends State<PrayerWallTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerProvider>(context, listen: false).fetchPrayers();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            _buildSliverTabBar(),
          ];
        },
        body: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(_slideAnimation),
          child: FadeTransition(
            opacity: _slideAnimation,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllPrayersTab(),
                _buildMyPrayersTab(),
                _buildFriendsTab(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: true,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEC4899),
                Color(0xFFF59E0B),
                Color(0xFFEF4444),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prayer Wall',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Share your heart with the community',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFFEC4899),
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFFEC4899),
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: 'All Prayers'),
              Tab(text: 'My Prayers'),
              Tab(text: 'Friends'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showPrayerDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Share Prayer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAllPrayersTab() {
    return Consumer<PrayerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildShimmerLoading();
        }

        if (provider.prayers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.volunteer_activism_outlined,
            title: 'No prayers yet',
            subtitle: 'Be the first to share a prayer request',
            color: const Color(0xFFEC4899),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchPrayers(),
          color: const Color(0xFFEC4899),
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: provider.prayers.length + _getMockPrayers().length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              if (index < _getMockPrayers().length) {
                final prayer = _getMockPrayers()[index];
                return _buildEnhancedPrayerCard(prayer, context);
              } else {
                final prayer = provider.prayers[index - _getMockPrayers().length];
                return PrayerCard(
                  prayer: prayer,
                  currentUserId: Provider.of<AuthProvider>(context).currentUser?.id ?? '',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerDetailScreen(prayerId: prayer.id),
                      ),
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMyPrayersTab() {
    return _buildEmptyState(
      icon: Icons.person_outline_rounded,
      title: 'Your prayers will appear here',
      subtitle: 'Share your first prayer request to get started',
      color: const Color(0xFF8B5CF6),
    );
  }

  Widget _buildFriendsTab() {
    return _buildEmptyState(
      icon: Icons.group_outlined,
      title: 'Friends\' prayers will appear here',
      subtitle: 'Connect with friends to see their prayer requests',
      color: const Color(0xFF10B981),
    );
  }

  Widget _buildEnhancedPrayerCard(Map<String, dynamic> prayer, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrayerDetailScreen(
                  prayerId: 'mock_${prayer['userName']}',
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrayerHeader(prayer),
                const SizedBox(height: 20),
                _buildPrayerContent(prayer),
                const SizedBox(height: 24),
                _buildPrayerActions(prayer),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerHeader(Map<String, dynamic> prayer) {
    return Row(
      children: [
        Hero(
          tag: 'avatar_${prayer['userName']}',
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: prayer['isAnonymous']
                  ? const LinearGradient(
                      colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
                    ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (prayer['isAnonymous'] 
                    ? const Color(0xFF94A3B8) 
                    : const Color(0xFFEC4899)).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                prayer['isAnonymous'] ? Icons.visibility_off_rounded : Icons.person_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayer['isAnonymous'] ? 'Anonymous Sister' : prayer['userName'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Prayer Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    prayer['time'],
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (prayer['isAnonymous'])
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFF475569)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Anonymous',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrayerContent(Map<String, dynamic> prayer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF7FF), Color(0xFFF0F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEC4899).withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Text(
        prayer['content'],
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF475569),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildPrayerActions(Map<String, dynamic> prayer) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.volunteer_activism_rounded,
          label: '${prayer['prayingCount']}',
          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.favorite_rounded,
          label: '${prayer['heartsCount']}',
          gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFE11D48)]),
          onTap: () {},
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF94A3B8).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.colors.map((c) => c.withOpacity(0.1)).toList(),
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient.colors.first.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: gradient.colors.first),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: gradient.colors.first,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        return Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                icon,
                size: 72,
                color: color,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockPrayers() {
    return [
      {
        'userName': 'Emuye M.',
        'time': '2 hours ago',
        'content': 'Please pray for my job interview tomorrow. I\'m feeling anxious but trusting in God\'s plan for my life. I know He has something beautiful prepared for me.',
        'prayingCount': 12,
        'heartsCount': 8,
        'isAnonymous': false,
      },
      {
        'userName': 'Bersabeh',
        'time': '4 hours ago',
        'content': 'Going through a difficult season in my marriage. Please pray for healing and restoration. I believe God can work miracles in our relationship.',
        'prayingCount': 25,
        'heartsCount': 15,
        'isAnonymous': true,
      },
    ];
  }

  void _showPrayerDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    bool isAnonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Expanded(
                                child: Text(
                                  'Share Your Prayer',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 28),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: TextField(
                              controller: contentController,
                              maxLines: null,
                              expands: true,
                              decoration: InputDecoration(
                                hintText: 'Share your prayer request with the community...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.all(24),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFEF7FF), Color(0xFFF0F9FF)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 1.3,
                                  child: Switch(
                                    value: isAnonymous,
                                    onChanged: (value) {
                                      setState(() {
                                        isAnonymous = value;
                                      });
                                    },
                                    activeColor: const Color(0xFFEC4899),
                                    activeTrackColor: const Color(0xFFEC4899).withOpacity(0.3),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Post anonymously',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF1E293B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Your identity will be protected',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF94A3B8)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      side: BorderSide.none,
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF475569),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEC4899).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Share Prayer',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _widget;

  _SliverAppBarDelegate(this._widget);

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _widget;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}