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

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  List<UserModel> _recentUsers = [];
  bool _isLoading = false;
  bool _isLoadingRecent = false;
  String? _error;
  bool _hasSearched = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRecentUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
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
  
  // Use a state variable to control loading instead of showDialog during build
  setState(() => _isLoading = true);
  
  try {
    final chatProvider = context.read<ChatProvider>();
    
    // Create immediate preview with known user data
    final previewChat = Chat(
      id: 'preview-${DateTime.now().millisecondsSinceEpoch}',
      participants: [user],
      type: ChatType.direct,
      chatName: user.fullName,
      chatImage: user.avatarUrl,
      isOnline: user.isOnline,
      lastActivity: DateTime.now(),
    );

    // Check for existing chat in background
    final existingChat = await chatProvider.getExistingChat(user.id);
    
    if (existingChat != null && mounted) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => ChatScreen(chat: existingChat)),
      );
      return;
    }

    // Create new chat if needed
    final newChat = await chatProvider.startChatWithUser(user);
    if (newChat != null && mounted) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => ChatScreen(chat: newChat)),
      );
    }
  } catch (e) {
    if (mounted) {
      scaffold.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
      appBar: AppBar(
        title: const Text('New Chat'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchUsers();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _error == 'Failed to load recent users' 
                  ? _loadRecentUsers 
                  : _searchUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _hasSearched ? _buildSearchResults() : _buildRecentUsers();
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No users found'),
            SizedBox(height: 8),
            Text(
              'Try searching with a different name, email, or location',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) => _buildUserTile(_searchResults[index]),
    );
  }

  Widget _buildRecentUsers() {
    if (_isLoadingRecent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Search for users to start chatting'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecentUsers,
      child: ListView.builder(
        itemCount: _recentUsers.length,
        itemBuilder: (context, index) => _buildUserTile(_recentUsers[index]),
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return ListTile(
     leading: CircleAvatar(
      backgroundImage: user.avatarUrl != null && user.avatarUrl!.startsWith('http')
          ? NetworkImage(user.avatarUrl!)
          : null,
      child: user.avatarUrl == null || !user.avatarUrl!.startsWith('http')
          ? Text(user.initials)
          : null,
    ),
      title: Text(user.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          if (user.city != null || user.country != null)
            Text(
              '${user.city ?? ''}${user.city != null && user.country != null ? ', ' : ''}${user.country ?? ''}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      trailing: const Icon(Icons.chat_bubble_outline),
      onTap: () => _handleUserSelection(user),
    );
  }
}