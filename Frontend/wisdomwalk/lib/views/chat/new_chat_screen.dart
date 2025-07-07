import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
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
    } finally {
      setState(() => _isLoadingRecent = false);
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchUsers();
    });
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
      setState(() {
        _error = 'Failed to search users';
        _searchResults = [];
      });
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startChat(UserModel user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatProvider = context.read<ChatProvider>();
      final chat = await chatProvider.startChatWithUser(user);
      
      if (!mounted) return;
      Navigator.pop(context);
      
      if (chat != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chat: chat),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start chat')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
      ),
      body: Column(
        children: [
          // Search Bar
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
              ),
              onChanged: (_) => _onSearchChanged(),
              onSubmitted: (_) => _searchUsers(),
            ),
          ),
          
          // Results
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
              onPressed: _searchUsers,
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
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user);
      },
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

    return ListView.builder(
      itemCount: _recentUsers.length,
      itemBuilder: (context, index) {
        final user = _recentUsers[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null 
            ? NetworkImage(user.avatarUrl!) 
            : null,
        child: user.avatarUrl == null 
            ? Text(user.initials ?? '?') 
            : null,
      ),
      title: Text(user.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email),
          if (user.city != null || user.country != null)
            Text('${user.city ?? ''} ${user.country ?? ''}'),
        ],
      ),
      trailing: const Icon(Icons.chat_bubble_outline),
      onTap: () => _startChat(user),
    );
  }
}