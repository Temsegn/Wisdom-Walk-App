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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WisdomCircleProvider>();
      if (provider.circles.isEmpty) {
        provider.fetchCircles();
      }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Wisdom Circles',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Join topic-based communities for deeper connection',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // My Circles Section
                  const Text(
                    'My Circles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Column(
                        children:
                            myCircles.map((circle) {
                              return WisdomCircleCard(
                                circle: circle,
                                isJoined: true,
                                onTap:
                                    () => context.push('/circle/${circle.id}'),
                              );
                            }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Discover New Circles Section
                  const Text(
                    'Discover New Circles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
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
                        return const Center(child: CircularProgressIndicator());
                      }

                      return Column(
                        children:
                            discoverCircles.map((circle) {
                              return WisdomCircleCard(
                                circle: circle,
                                isJoined: false,
                                onTap:
                                    () => provider.joinCircle(
                                      circleId: circle.id,
                                      userId: 'user123',
                                    ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Upcoming Live Chats Section
                  const Text(
                    'Upcoming Live Chats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildLiveChatItem(
                    'Marriage & Ministry',
                    'Building Strong Foundations',
                    'Tonight 8PM',
                    Colors.purple,
                  ),
                  _buildLiveChatItem(
                    'Healing & Hope',
                    'Finding Peace in Storms',
                    'Tomorrow 7PM',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.group, color: Colors.orange),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
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
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.videocam, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
