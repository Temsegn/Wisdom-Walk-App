import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/widgets/prayer_card.dart';

class PrayerWallTab extends StatefulWidget {
  const PrayerWallTab({Key? key}) : super(key: key);

  @override
  State<PrayerWallTab> createState() => _PrayerWallTabState();
}

class _PrayerWallTabState extends State<PrayerWallTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrayerProvider>(context, listen: false).fetchPrayers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE91E63).withOpacity(0.2),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFFE91E63),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Prayer Wall',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showPrayerDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Post Prayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFE91E63),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFFE91E63),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'All Prayers'),
                  Tab(text: 'My Prayers'),
                  Tab(text: 'Friends'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllPrayersTab(),
                  _buildMyPrayersTab(),
                  _buildFriendsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPrayersTab() {
    return Consumer<PrayerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.prayers.isEmpty) {
          return const Center(
            child: Text('No prayers yet. Be the first to share!'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchPrayers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.prayers.length + _getMockPrayers().length,
            itemBuilder: (context, index) {
              if (index < _getMockPrayers().length) {
                final prayer = _getMockPrayers()[index];
                return _buildPrayerCard(prayer);
              } else {
                final prayer =
                    provider.prayers[index - _getMockPrayers().length];
                return PrayerCard(
                  prayer: prayer,
                  currentUserId:
                      Provider.of<AuthProvider>(context).currentUser?.id ?? '',
                  onTap: () {},
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMyPrayersTab() {
    return const Center(child: Text('Your prayer requests will appear here'));
  }

  Widget _buildFriendsTab() {
    return const Center(
      child: Text('Prayers from your friends will appear here'),
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> prayer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    prayer['isAnonymous']
                        ? const Color(0xFF9C27B0).withOpacity(0.2)
                        : Colors.grey[300],
                child: Text(
                  prayer['isAnonymous'] ? 'A' : prayer['userName'][0],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        prayer['isAnonymous']
                            ? const Color(0xFF9C27B0)
                            : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer['isAnonymous'] ? 'Anonymous' : prayer['userName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      prayer['time'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (prayer['isAnonymous'])
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Anonymous',
                    style: TextStyle(
                      color: Color(0xFF9C27B0),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            prayer['content'],
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _buildActionButton(
                icon: Icons.pan_tool,
                label: '${prayer['prayingCount']}',
                color: const Color(0xFFE91E63),
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.favorite_outline,
                label: '${prayer['heartsCount']}',
                color: Colors.grey[600]!,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${prayer['commentsCount']}',
                color: Colors.grey[600]!,
                onTap: () {},
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockPrayers() {
    return [
      {
        'userName': 'Emuye M.',
        'time': '2 hours ago',
        'content':
            'Please pray for my job interview tomorrow. I\'m feeling anxious but trusting in God\'s plan for my life.',
        'prayingCount': 12,
        'heartsCount': 8,
        'commentsCount': 3,
        'isAnonymous': false,
      },
      {
        'userName': 'Bersabeh',
        'time': '4 hours ago',
        'content':
            'Going through a difficult season in my marriage. Please pray for healing and restoration.',
        'prayingCount': 25,
        'heartsCount': 15,
        'commentsCount': 7,
        'isAnonymous': true,
      },
    ];
  }

  void _showPrayerDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();
    bool isAnonymous = false;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(
                builder:
                    (context, setState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Share a Prayer Request',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: contentController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'pray',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Switch(
                              value: isAnonymous,
                              onChanged: (value) {
                                setState(() {
                                  isAnonymous = value;
                                });
                              },
                              activeColor: const Color(0xFFE91E63),
                            ),
                            const SizedBox(width: 8),
                            const Text('Post anonymously'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle prayer submission
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Share Prayer'),
                              ),
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
}
