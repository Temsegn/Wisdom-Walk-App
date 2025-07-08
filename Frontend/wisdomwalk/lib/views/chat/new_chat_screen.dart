import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/chat_model.dart';
import '../../services/user_service.dart';
import '../../providers/chat_provider.dart';
import 'chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  List<UserModel> _recentUsers = [];
  bool _isLoading = false;
  bool _isLoadingRecent = false;
  String? _error;
  bool _hasSearched = false;
  Timer? _debounceTimer;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRecentUsers();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentUsers() async {
    setState(() => _isLoadingRecent = true);
    try {
      final users = await UserService.getRecentUsers();
      setState(() => _recentUsers = users);
    } catch (e) {
      debugPrint('Error loading recent users: $e');
      setState(() => _error = 'Failed to load recent users');
    } finally {
      setState(() => _isLoadingRecent = false);
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _searchUsers);
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _error = null;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final users = await UserService.searchUsers(query);
      setState(() => _searchResults = users);
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() {
        _error = 'Failed to search users';
        _searchResults = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUserSelection(UserModel user) async {
    if (!mounted) return;
    
    final scaffold = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    setState(() => _isLoading = true);
    
    try {
      final chatProvider = context.read<ChatProvider>();
      
      final previewChat = Chat(
        id: 'preview-${DateTime.now().millisecondsSinceEpoch}',
        participants: [user],
        type: ChatType.direct,
        chatName: user.fullName,
        chatImage: user.avatarUrl,
        isOnline: user.isOnline,
        lastActivity: DateTime.now(),
      );

      final existingChat = await chatProvider.getExistingChat(user.id);
      
      if (existingChat != null && mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => ChatScreen(chat: existingChat)),
        );
        return;
      }

      final newChat = await chatProvider.startChatWithUser(user);
      if (newChat != null && mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => ChatScreen(chat: newChat)),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                          Icons.person_add_rounded,
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
                              'New Chat',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Find sisters to connect with',
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
        if (_isLoading)
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 24,
            height: 24,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, email, or location...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 16,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF8B5CF6),
              size: 24,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _searchUsers();
                    },
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E293B),
        ),
        onChanged: (_) => _onSearchChanged(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: _hasSearched ? _buildSearchResults() : _buildRecentUsers(),
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: List.generate(5, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _error == 'Failed to load recent users' 
                    ? 'Failed to load recent users'
                    : 'Failed to search users',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  onPressed: _error == 'Failed to load recent users' 
                      ? _loadRecentUsers 
                      : _searchUsers,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ).colors.first.withOpacity(0.1) != null 
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                          const Color(0xFFEC4899).withOpacity(0.05),
                        ],
                      )
                    : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  size: 64,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No users found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Try searching with a different name, email, or location',
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

    return RefreshIndicator(
      onRefresh: _searchUsers,
      color: const Color(0xFF8B5CF6),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildEnhancedUserTile(_searchResults[index]),
      ),
    );
  }

  Widget _buildRecentUsers() {
    if (_isLoadingRecent) {
      return _buildShimmerLoading();
    }

    if (_recentUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ).colors.first.withOpacity(0.1) != null 
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                          const Color(0xFFEC4899).withOpacity(0.05),
                        ],
                      )
                    : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 64,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Search for users to start chatting',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Use the search bar above to find sisters in your community',
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

    return RefreshIndicator(
      onRefresh: _loadRecentUsers,
      color: const Color(0xFF8B5CF6),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        itemCount: _recentUsers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildEnhancedUserTile(_recentUsers[index]),
      ),
    );
  }

  Widget _buildEnhancedUserTile(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleUserSelection(user),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Hero(
                  tag: 'user_avatar_${user.id}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: user.avatarUrl != null && user.avatarUrl!.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (user.city != null || user.country != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            ).colors.first.withOpacity(0.1) != null 
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF8B5CF6).withOpacity(0.1),
                                    const Color(0xFFEC4899).withOpacity(0.05),
                                  ],
                                )
                              : const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${user.city ?? ''}${user.city != null && user.country != null ? ', ' : ''}${user.country ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8B5CF6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
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
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
