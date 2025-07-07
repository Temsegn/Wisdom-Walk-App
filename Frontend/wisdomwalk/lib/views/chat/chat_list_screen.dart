import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';
import 'chat_screen.dart';
import 'new_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
} 

class _ChatListScreenState extends State<ChatListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialChats());
  }

  Future<void> _loadInitialChats() async {
    if (!mounted) return;
    
    try {
      await context.read<ChatProvider>().loadChats(refresh: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chats: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitialLoad = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<ChatProvider>().loadChats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewChatScreen(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (_isInitialLoad && chatProvider.chats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatProvider.error != null) {
          return _buildErrorState(chatProvider.error!);
        }

        if (chatProvider.chats.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => chatProvider.loadChats(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: chatProvider.chats.length + (chatProvider.hasMoreChats ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chatProvider.chats.length) {
                return _buildLoadingIndicator(chatProvider.isLoading);
              }
              return ChatListItem(
                chat: chatProvider.chats[index],
                onTap: () => _navigateToChatScreen(context, chatProvider.chats[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load chats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8), 
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialChats,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation by tapping the + button',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isLoading) {
    return isLoading
        ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : const SizedBox();
  }

  void _navigateToChatScreen(BuildContext context, Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)),
    );
  }

  void _navigateToNewChatScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewChatScreen()),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: ChatSearchDelegate(chats: context.read<ChatProvider>().chats),
    );
  }
}

// ChatListItem and ChatSearchDelegate implementations remain similar but with null checks
class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListItem({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatName = chat.chatName ?? 'Unknown Chat';
    final lastMessage = chat.lastMessage?.content ?? 'No messages yet';
    final lastActivity = chat.lastActivity ?? DateTime.now();
    final unreadCount = chat.unreadCount;

    return ListTile(
      leading: _buildAvatar(chat, chatName),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chatName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chat.isOnline == true)
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
          color: unreadCount > 0 ? theme.primaryColor : Colors.grey,
        ),
      ),
      trailing: _buildTrailingWidget(unreadCount, lastActivity, theme),
      onTap: onTap,
    );
  } 

  Widget _buildAvatar(Chat chat, String chatName) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[200],
      backgroundImage: chat.chatImage != null 
          ? NetworkImage(chat.chatImage!) 
          : null,
      child: chat.chatImage == null
          ? Text(
              chatName.isNotEmpty ? chatName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            )
          : null,
    );
  }

  Widget _buildTrailingWidget(int unreadCount, DateTime lastActivity, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text( 
          _formatTime(lastActivity),
          style: theme.textTheme.bodySmall?.copyWith(
            color: unreadCount > 0 ? theme.primaryColor : Colors.grey,
          ),
        ),
        if (unreadCount > 0) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';  
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class ChatSearchDelegate extends SearchDelegate {
  final List<Chat> chats;

  ChatSearchDelegate({required this.chats});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = query.isEmpty
        ? chats
        : chats.where((chat) =>
            (chat.chatName ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (chat.lastMessage?.content ?? '')
                .toLowerCase()
                .contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        return ChatListItem(
          chat: chat,
          onTap: () {
            close(context, null);
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
}