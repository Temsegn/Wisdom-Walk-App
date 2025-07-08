import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';

class AnonymousShareTab extends StatefulWidget {
  const AnonymousShareTab({Key? key}) : super(key: key);

  @override
  State<AnonymousShareTab> createState() => _AnonymousShareTabState();
}

class _AnonymousShareTabState extends State<AnonymousShareTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnonymousShareProvider>(context, listen: false).fetchAllShares();
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
          _buildSliverTabBar(),
          SliverFillRemaining(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSharesList(null),
                  _buildSharesList(AnonymousShareType.testimony),
                  _buildSharesList(AnonymousShareType.struggle),
                  _buildSharesList(AnonymousShareType.confession),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
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
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anonymous Share',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'A safe space to share your heart',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
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
      delegate: _SliverTabBarDelegate(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF8B5CF6),
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFF8B5CF6),
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Testimony'),
              Tab(text: 'Struggle'),
              Tab(text: 'Confession'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showAnonymousShareDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Share Anonymously',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSharesList(AnonymousShareType? filterType) {
    return Consumer<AnonymousShareProvider>(
      builder: (context, provider, child) {
        List shares;
        if (filterType == null) {
          shares = _getMockShares();
        } else {
          shares = _getMockShares()
              .where((share) => share['type'] == filterType)
              .toList();
        }

        if (shares.isEmpty) {
          return _buildEmptyState(filterType);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.fetchAllShares();
          },
          color: const Color(0xFF8B5CF6),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: shares.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final share = shares[index];
              return _buildEnhancedShareCard(share);
            },
          ),
        );
      },
    );
  }

  Widget _buildEnhancedShareCard(Map<String, dynamic> share) {
    final typeColor = _getTypeColor(share['type']);
    final typeGradient = _getTypeGradient(share['type']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShareHeader(share, typeColor, typeGradient),
                const SizedBox(height: 16),
                _buildShareContent(share),
                const SizedBox(height: 20),
                _buildShareActions(share),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShareHeader(
    Map<String, dynamic> share,
    Color typeColor,
    List<Color> typeGradient,
  ) {
    return Row(
      children: [
        Hero(
          tag: 'anonymous_${share.hashCode}',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: typeGradient),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anonymous Sister',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Shared with love and trust',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: typeGradient),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            share['type'].toString().split('.').last.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          share['time'],
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildShareContent(Map<String, dynamic> share) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTypeColor(share['type']).withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Text(
        share['content'],
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF475569),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildShareActions(Map<String, dynamic> share) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.volunteer_activism_rounded,
          label: '${share['prayingCount']}',
          color: const Color(0xFF8B5CF6),
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.favorite_rounded,
          label: '${share['heartsCount']}',
          color: const Color(0xFFEC4899),
          onTap: () {},
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.chat_bubble_rounded,
          label: '${share['commentsCount']}',
          color: const Color(0xFF06B6D4),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AnonymousShareType? filterType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF94A3B8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${filterType?.toString().split('.').last ?? 'anonymous'} shares yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Be the first to share your heart anonymously',
              style: TextStyle(
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

  Color _getTypeColor(AnonymousShareType type) {
    switch (type) {
      case AnonymousShareType.testimony:
        return const Color(0xFF10B981);
      case AnonymousShareType.struggle:
        return const Color(0xFFF59E0B);
      case AnonymousShareType.confession:
        return const Color(0xFF8B5CF6);
    }
  }

  List<Color> _getTypeGradient(AnonymousShareType type) {
    switch (type) {
      case AnonymousShareType.testimony:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case AnonymousShareType.struggle:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case AnonymousShareType.confession:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
    }
  }

  List<Map<String, dynamic>> _getMockShares() {
    return [
      {
        'type': AnonymousShareType.struggle,
        'content':
            'I\'ve been struggling with forgiveness. Someone hurt me deeply and I know God calls us to forgive, but my heart feels so heavy. How do you forgive when the pain is still so fresh?',
        'time': '3 hours ago',
        'prayingCount': 12,
        'heartsCount': 15,
        'commentsCount': 8,
      },
      {
        'type': AnonymousShareType.testimony,
        'content':
            'Testimony: After years of infertility, God blessed us with our miracle baby. I want to encourage anyone waiting - His timing is perfect, even when we can\'t see it.',
        'time': '1 day ago',
        'prayingCount': 45,
        'heartsCount': 67,
        'commentsCount': 23,
        'prayingCount': 45,
        'heartsCount': 67,
        'commentsCount': 23,
      },
      {
        'type': AnonymousShareType.confession,
        'content':
            'I need to confess that I\'ve been struggling with jealousy towards other women in my church. Their lives seem so perfect while mine feels like a mess. Please pray for my heart.',
        'time': '2 days ago',
        'prayingCount': 8,
        'heartsCount': 12,
        'commentsCount': 5,
      },
    ];
  }

  void _showAnonymousShareDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    AnonymousShareType selectedType = AnonymousShareType.testimony;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Share Anonymously',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<AnonymousShareType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        items: AnonymousShareType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(type),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  type.toString().split('.').last.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedType = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: contentController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Share your heart...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your identity is completely protected. All posts are reviewed for safety.',
                              style: TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: const BorderSide(color: Color(0xFF94A3B8)),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your anonymous share has been posted',
                                    ),
                                    backgroundColor: Color(0xFF8B5CF6),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Share Anonymously',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _widget;

  _SliverTabBarDelegate(this._widget);

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _widget;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}