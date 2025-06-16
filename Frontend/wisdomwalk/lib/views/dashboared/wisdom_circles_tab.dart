import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wisdomwalk/providers/wisdom_circle_provider.dart';
import 'package:wisdomwalk/widgets/wisdom_circle_card.dart';

class WisdomCirclesTab extends StatefulWidget {
  const WisdomCirclesTab({Key? key}) : super(key: key);

  @override
  State<WisdomCirclesTab> createState() => _WisdomCirclesTabState();
}

class _WisdomCirclesTabState extends State<WisdomCirclesTab> {
  final Set<String> _joinedCircles = {'1', '3'}; // Demo joined circles

  @override
  void initState() {
    super.initState();
    print('WisdomCirclesTab: initState called');

    // Try multiple approaches to ensure data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('WisdomCirclesTab: PostFrameCallback - calling fetchCircles');
      final provider = context.read<WisdomCircleProvider>();
      print(
        'WisdomCirclesTab: Provider found, circles count: ${provider.circles.length}',
      );

      // If no circles, force refresh
      if (provider.circles.isEmpty) {
        print('WisdomCirclesTab: No circles found, calling fetchCircles');
        provider.fetchCircles();
      } else {
        print(
          'WisdomCirclesTab: Circles already loaded: ${provider.circles.length}',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('WisdomCirclesTab: build() called');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Wisdom Circles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () {
              print('WisdomCirclesTab: Manual refresh button pressed');
              context.read<WisdomCircleProvider>().forceRefresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Consumer<WisdomCircleProvider>(
        builder: (context, provider, child) {
          print('WisdomCirclesTab: Consumer builder called');
          print('WisdomCirclesTab: isLoading = ${provider.isLoading}');
          print(
            'WisdomCirclesTab: circles.length = ${provider.circles.length}',
          );
          print('WisdomCirclesTab: error = ${provider.error}');

          // Show loading only if actually loading and no circles
          if (provider.isLoading && provider.circles.isEmpty) {
            print('WisdomCirclesTab: Showing loading indicator');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE91E63)),
                  SizedBox(height: 16),
                  Text('Loading wisdom circles...'),
                ],
              ),
            );
          }

          // Show error only if there's an error and no circles
          if (provider.error != null && provider.circles.isEmpty) {
            print('WisdomCirclesTab: Showing error state: ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading circles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('WisdomCirclesTab: Error retry button pressed');
                      provider.fetchCircles();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final circles = provider.circles;
          print(
            'WisdomCirclesTab: Final check - circles.isEmpty: ${circles.isEmpty}',
          );

          // Show empty state only if truly no circles
          if (circles.isEmpty) {
            print('WisdomCirclesTab: Showing empty state with debug options');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No circles available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This might be a loading issue',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          print('WisdomCirclesTab: Force refresh pressed');
                          provider.forceRefresh();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                        ),
                        child: const Text('Force Refresh'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          print('WisdomCirclesTab: Fetch circles pressed');
                          provider.fetchCircles();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Fetch Circles'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Show the grid of circles
          print(
            'WisdomCirclesTab: Rendering grid with ${circles.length} circles',
          );
          return RefreshIndicator(
            onRefresh: () => provider.fetchCircles(),
            color: const Color(0xFFE91E63),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: circles.length,
                itemBuilder: (context, index) {
                  final circle = circles[index];
                  final isJoined = _joinedCircles.contains(circle.id);
                  print(
                    'WisdomCirclesTab: Building card ${index + 1}: ${circle.name}',
                  );

                  return WisdomCircleCard(
                    circle: circle,
                    isJoined: isJoined,
                    onTap: () {
                      print('WisdomCirclesTab: Card tapped: ${circle.name}');
                      context.go('/wisdom-circle/${circle.id}');
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCircleDialog,
        backgroundColor: const Color(0xFFE91E63),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCreateCircleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Circle'),
          content: const Text(
            'This feature will allow you to create your own wisdom circle for specific topics and discussions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Circle creation feature coming soon!'),
                    backgroundColor: Color(0xFFE91E63),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 177, 63, 101),
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
