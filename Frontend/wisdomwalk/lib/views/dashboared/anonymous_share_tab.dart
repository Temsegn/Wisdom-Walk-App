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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnonymousShareProvider>(
        context,
        listen: false,
      ).fetchAllShares();
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF9C27B0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Anonymous Share',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A safe space to share your heart anonymously',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAnonymousShareDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Share Anonymously'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
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
                labelColor: const Color(0xFF9C27B0),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFF9C27B0),
                indicatorWeight: 3,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Testimony'),
                  Tab(text: 'Struggle'),
                  Tab(text: 'Confession'),
                ],
              ),
            ),

            // Content
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSharesList(AnonymousShareType? filterType) {
    return Consumer<AnonymousShareProvider>(
      builder: (context, provider, child) {
        // Get shares based on filter
        List shares;
        if (filterType == null) {
          shares = _getMockShares();
        } else {
          shares =
              _getMockShares()
                  .where((share) => share['type'] == filterType)
                  .toList();
        }

        if (shares.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${filterType?.toString().split('.').last ?? 'anonymous'} shares yet',
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
            await provider.fetchAllShares();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shares.length,
            itemBuilder: (context, index) {
              final share = shares[index];
              return _buildShareCard(share);
            },
          ),
        );
      },
    );
  }

  Widget _buildShareCard(Map<String, dynamic> share) {
    final typeColor = _getTypeColor(share['type']);

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
                backgroundColor: const Color(0xFF9C27B0).withOpacity(0.2),
                child: const Text(
                  'A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Anonymous',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  share['type'].toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: typeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                share['time'],
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            share['content'],
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              _buildActionButton(
                icon: Icons.pan_tool,
                label: '${share['prayingCount']}',
                color: const Color(0xFF9C27B0),
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.favorite_outline,
                label: '${share['heartsCount']}',
                color: Colors.red,
                onTap: () {},
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${share['commentsCount']}',
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

  Color _getTypeColor(AnonymousShareType type) {
    switch (type) {
      case AnonymousShareType.testimony:
        return Colors.green;
      case AnonymousShareType.struggle:
        return Colors.orange;
      case AnonymousShareType.confession:
        return const Color(0xFF9C27B0);
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9C27B0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF9C27B0),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Share Anonymously',
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

                        // Category Dropdown
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<AnonymousShareType>(
                          value: selectedType,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          items:
                              AnonymousShareType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
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

                        const SizedBox(height: 16),

                        // Content Input
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: contentController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: 'Share your heart...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Privacy Notice
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9C27B0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF9C27B0),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your identity is completely protected. All posts are reviewed for safety.',
                                  style: TextStyle(
                                    color: const Color(0xFF9C27B0),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons
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
                                  // Handle anonymous share submission
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Your anonymous share has been posted',
                                      ),
                                      backgroundColor: Color(0xFF9C27B0),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C27B0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Share Anonymously'),
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
