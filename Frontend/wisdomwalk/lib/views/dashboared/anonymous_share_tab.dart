import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/anonymous_share_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/anonymous_share_model.dart';
import 'package:wisdomwalk/widgets/anonymous_share_card.dart';
import 'package:go_router/go_router.dart';

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
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnonymousShareProvider>(
        context,
        listen: false,
      ).fetchShares(type: AnonymousShareType.confession);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final provider = Provider.of<AnonymousShareProvider>(
        context,
        listen: false,
      );
      switch (_tabController.index) {
        case 0:
          provider.setFilter(AnonymousShareType.confession);
          break;
        case 1:
          provider.setFilter(AnonymousShareType.testimony);
          break;
        case 2:
          provider.setFilter(AnonymousShareType.struggle);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareProvider = Provider.of<AnonymousShareProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final shares = shareProvider.shares;
    final isLoading = shareProvider.isLoading;
    final error = shareProvider.error;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Anonymous Share',
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
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onBackground.withOpacity(0.7),
          indicatorColor: Theme.of(context).primaryColor,
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
          _buildShareList(
            shares,
            isLoading,
            error,
            shareProvider,
            authProvider,
            AnonymousShareType.confession,
          ),
          _buildShareList(
            shares,
            isLoading,
            error,
            shareProvider,
            authProvider,
            AnonymousShareType.testimony,
          ),
          _buildShareList(
            shares,
            isLoading,
            error,
            shareProvider,
            authProvider,
            AnonymousShareType.struggle,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAnonymousShareDialog(context);
        },
        backgroundColor: const Color(0xFFD4A017),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShareList(
    List<AnonymousShareModel> shares,
    bool isLoading,
    String? error,
    AnonymousShareProvider shareProvider,
    AuthProvider authProvider,
    AnonymousShareType type,
  ) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading shares',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  shareProvider.fetchShares(type: type);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        )
        : shares.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline,
                size: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No shares yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share anonymously',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
        : RefreshIndicator(
          onRefresh: () async {
            await shareProvider.fetchShares(type: type);
          },
          color: Theme.of(context).primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shares.length,
            itemBuilder: (context, index) {
              final share = shares[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnonymousShareCard(
                  share: share,
                  currentUserId: authProvider.currentUser?.id ?? '',
                  onTap: () {
                    context.go('/anonymous-share/${share.id}');
                  },
                ),
              );
            },
          ),
        );
  }

  void _showAddAnonymousShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Share Anonymously',
                          style: TextStyle(
                            fontSize: 20,
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
                  TextField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Share what\'s on your heart anonymously...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Handle anonymous share submission
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Shared anonymously'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A017),
                        ),
                        child: const Text('Share'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
