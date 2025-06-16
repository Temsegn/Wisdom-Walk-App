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
  final TextEditingController _shareController = TextEditingController();
  AnonymousShareType _selectedType = AnonymousShareType.confession;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Changed to 4 tabs
    _tabController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start with "All" tab showing all shares
      Provider.of<AnonymousShareProvider>(
        context,
        listen: false,
      ).fetchAllShares();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _shareController.dispose();
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
          provider.fetchAllShares(); // All shares
          break;
        case 1:
          provider.setFilter(AnonymousShareType.confession);
          break;
        case 2:
          provider.setFilter(AnonymousShareType.testimony);
          break;
        case 3:
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh based on current tab
              switch (_tabController.index) {
                case 0:
                  shareProvider.fetchAllShares();
                  break;
                case 1:
                  shareProvider.setFilter(AnonymousShareType.confession);
                  break;
                case 2:
                  shareProvider.setFilter(AnonymousShareType.testimony);
                  break;
                case 3:
                  shareProvider.setFilter(AnonymousShareType.struggle);
                  break;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.go('/settings');
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
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
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
            null, // All shares
          ),
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
    AnonymousShareType? type,
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
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (type == null) {
                    shareProvider.fetchAllShares();
                  } else {
                    shareProvider.fetchShares(type: type);
                  }
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (type == null) {
                    shareProvider.forceRefreshAll();
                  } else {
                    shareProvider.forceRefresh(type);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Force Refresh'),
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
                type == null
                    ? 'No shares yet'
                    : 'No ${_getTypeDisplayName(type)} yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to share anonymously',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (type == null) {
                    shareProvider.fetchAllShares();
                  } else {
                    shareProvider.fetchShares(type: type);
                  }
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
        )
        : RefreshIndicator(
          onRefresh: () async {
            if (type == null) {
              await shareProvider.fetchAllShares();
            } else {
              await shareProvider.fetchShares(type: type);
            }
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

  String _getTypeDisplayName(AnonymousShareType type) {
    switch (type) {
      case AnonymousShareType.confession:
        return 'confessions';
      case AnonymousShareType.testimony:
        return 'testimonies';
      case AnonymousShareType.struggle:
        return 'struggles';
    }
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

                  // Type Selection
                  const Text(
                    'Select Type:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeChip(
                          'Confession',
                          AnonymousShareType.confession,
                          const Color(0xFFE91E63),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTypeChip(
                          'Testimony',
                          AnonymousShareType.testimony,
                          const Color(0xFF4CAF50),
                        ),
                      ),
                      Expanded(
                        child: _buildTypeChip(
                          'Struggle',
                          AnonymousShareType.struggle,
                          const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _shareController,
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
                        onPressed: () async {
                          if (_shareController.text.trim().isNotEmpty) {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final shareProvider =
                                Provider.of<AnonymousShareProvider>(
                                  context,
                                  listen: false,
                                );

                            final success = await shareProvider.addShare(
                              userId:
                                  authProvider.currentUser?.id ?? 'anonymous',
                              content: _shareController.text.trim(),
                              type: _selectedType,
                            );

                            Navigator.pop(context);
                            _shareController.clear();

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Shared anonymously'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ Failed to share'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
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

  Widget _buildTypeChip(String label, AnonymousShareType type, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
