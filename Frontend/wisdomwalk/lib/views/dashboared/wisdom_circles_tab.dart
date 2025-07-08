import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';
import 'package:wisdomwalk/providers/wisdom_circle_provider.dart';
import 'package:wisdomwalk/widgets/wisdom_circle_card.dart';

class WisdomCirclesTab extends StatefulWidget {
  const WisdomCirclesTab({Key? key}) : super(key: key);

  @override
  State<WisdomCirclesTab> createState() => _WisdomCirclesTabState();
}

class _WisdomCirclesTabState extends State<WisdomCirclesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WisdomCircleProvider>();
      if (provider.circles.isEmpty) {
        provider.fetchCircles();
      }
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFFEC4899),
                Color(0xFFF59E0B),
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
                          Icons.people_rounded,
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
                              'Wisdom Circles',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Connect with like-minded sisters',
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
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Create Circle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMyCirclesSection(),
          const SizedBox(height: 32),
          _buildDiscoverSection(),
          const SizedBox(height: 32),
          _buildUpcomingChatsSection(),
        ],
      ),
    );
  }

  Widget _buildMyCirclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFF97316)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'My Circles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Consumer<WisdomCircleProvider>(
          builder: (context, provider, child) {
            final myCircles = provider.circles
                .where((circle) => provider.joinedCircles.contains(circle.id))
                .toList();

            if (myCircles.isEmpty && provider.isLoading) {
              return _buildShimmerLoading();
            }

            if (myCircles.isEmpty) {
              return _buildEmptyState(
                icon: Icons.group_add_rounded,
                title: 'No circles joined yet',
                subtitle: 'Join your first circle below!',
                color: const Color(0xFFEC4899),
              );
            }

            return Column(
              children: myCircles.map((circle) {
                return _buildEnhancedCircleCard(
                  circle: circle,
                  isJoined: true,
                  onTap: () => context.push('/circle/${circle.id}'),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDiscoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Discover New Circles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Consumer<WisdomCircleProvider>(
          builder: (context, provider, child) {
            final discoverCircles = provider.circles
                .where((circle) => !provider.joinedCircles.contains(circle.id))
                .toList();

            if (discoverCircles.isEmpty && provider.isLoading) {
              return _buildShimmerLoading();
            }

            return Column(
              children: discoverCircles.map((circle) {
                return _buildEnhancedCircleCard(
                  circle: circle,
                  isJoined: false,
                  onTap: () => provider.joinCircle(
                    circleId: circle.id,
                    userId: 'user123',
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingChatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Upcoming Live Chats',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLiveChatItem(
          'Marriage & Ministry',
          'Building Strong Foundations',
          'Tonight 8PM',
          const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]),
        ),
        const SizedBox(height: 16),
        _buildLiveChatItem(
          'Healing & Hope',
          'Finding Peace in Storms',
          'Tomorrow 7PM',
          const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF10B981)]),
        ),
      ],
    );
  }

  Widget _buildEnhancedCircleCard({
    required WisdomCircleModel circle,
    required bool isJoined,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'circle_${circle.id}',
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: _getCircleGradient(circle.id),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getCircleGradient(circle.id).colors.first.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            circle.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
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
                            circle.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            circle.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildActionButton(isJoined),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.people_rounded,
                      label: '${circle.memberCount} members',
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.chat_bubble_rounded,
                      label: '3 new messages',
                      gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isJoined) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: isJoined 
          ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
          : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isJoined ? const Color(0xFF10B981) : const Color(0xFF8B5CF6)).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isJoined ? 'Open' : 'Join',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient.colors.first.withOpacity(0.1) != null 
          ? LinearGradient(
              colors: gradient.colors.map((c) => c.withOpacity(0.1)).toList(),
            )
          : gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors.first.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: gradient.colors.first),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: gradient.colors.first,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: gradient.colors.first,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 140,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 64,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
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
    );
  }

  LinearGradient _getCircleGradient(String circleId) {
    switch (circleId) {
      case '1':
        return const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF97316)]);
      case '2':
        return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]);
      case '3':
        return const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF10B981)]);
      case '4':
        return const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF84CC16)]);
      case '5':
        return const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]);
      default:
        return const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]);
    }
  }
}