import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _isSearching = false;
  List<UserModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadUserChats();
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.searchUsers(query);
      setState(() {
        _searchResults = userProvider.searchResults;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
    setState(() => _isSearching = false);
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (value) {
          if (value.isNotEmpty) {
            _performSearch(value);
          } else {
            setState(() => _searchResults = []);
          }
        },
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchResults = [];
                _showSearch = false;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildUserSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null ? Text(user.name[0]) : null,
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () async {
            final chatProvider =
                Provider.of<ChatProvider>(context, listen: false);
            final chat = await chatProvider.startChatWithUser(user);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
            );
            setState(() {
              _showSearch = false;
              _searchController.clear();
              _searchResults.clear();
            });
          },
        );
      },
    );
  }

  Widget _buildChatList(ChatProvider chatProvider) {
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.error != null) {
      return Center(child: Text('Error: ${chatProvider.error}'));
    }

    if (chatProvider.chats.isEmpty) {
      return const Center(child: Text('No chats available'));
    }

    return ListView.builder(
      itemCount: chatProvider.chats.length,
      itemBuilder: (context, index) {
        final chat = chatProvider.chats[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: chat.displayImage != null
                ? NetworkImage(chat.displayImage!)
                : null,
            child:
                chat.displayImage == null ? Text(chat.displayName[0]) : null,
          ),
          title: Text(chat.displayName),
          subtitle: chat.lastMessage != null
              ? Text(
                  chat.lastMessage!.content ?? 'Attachment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : const Text('No messages yet'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(chat.lastActivityFormatted),
              if (chat.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(chat: chat),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? const Text('Search Users') : const Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_showSearch) {
                  _searchController.clear();
                  _searchResults.clear();
                }
                _showSearch = !_showSearch;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch) _buildSearchInput(),
          Expanded(
            child: _showSearch
                ? _buildUserSearchResults()
                : _buildChatList(chatProvider),
          ),
        ],
      ),
      floatingActionButton: !_showSearch
          ? FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.chat),
            )
          : null,
    );
  }
}
