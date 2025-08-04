import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/message_model.dart';
import 'package:wisdomwalk/providers/message_provider.dart';
import 'package:wisdomwalk/services/local_storage_service.dart';
import 'package:wisdomwalk/views/chat/chat_screen.dart';
import 'package:wisdomwalk/widgets/message_bubble.dart';

class MessageSearchDelegate extends SearchDelegate {
  final String chatId;
  final MessageProvider messageProvider;

  MessageSearchDelegate({required this.chatId, required this.messageProvider});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.clear_rounded, color: Colors.white),
          onPressed: () {
            query = '';
          },
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () {
          close(context, null);
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                              ).colors.first.withOpacity(0.1) !=
                              null
                          ? LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withOpacity(0.1),
                              const Color(0xFF06B6D4).withOpacity(0.05),
                            ],
                          )
                          : const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                          ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Search Messages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter a search query to find messages',
                style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<List<Message>>(
      future: messageProvider.apiService.searchMessages(chatId, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
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
                    const Text(
                      'Search Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Container(
            decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF06B6D4),
                                      ],
                                    ).colors.first.withOpacity(0.1) !=
                                    null
                                ? LinearGradient(
                                  colors: [
                                    const Color(0xFF10B981).withOpacity(0.1),
                                    const Color(0xFF06B6D4).withOpacity(0.05),
                                  ],
                                )
                                : const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF06B6D4),
                                  ],
                                ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No messages found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Try searching with different keywords',
                      style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
          child: ListView.separated(
            reverse: true,
            padding: const EdgeInsets.all(24),
            itemCount: messages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final message = messages[index];
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
                child: MessageBubble(
                  message: message,
                  isCurrentUser:
                      message.sender.id ==
                      LocalStorageService().getCurrentUserId(),
                  onReply: () => messageProvider.setReplyToMessage(message),
                  onEdit: () => _editMessage(context, message),
                  onDelete: () => _deleteMessage(context, message),
                  onReact:
                      (emoji) => messageProvider.addReaction(message.id, emoji),
                  onPin: () => messageProvider.pinMessage(chatId, message.id),
                  onForward: () => _forwardMessage(context, message),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _editMessage(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder:
          (context) => EditMessageDialog(
            message: message,
            onEdit: (newContent) {
              messageProvider.editMessage(message.id, newContent);
            },
          ),
    );
  }

  void _deleteMessage(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    messageProvider.deleteMessage(message.id);
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _forwardMessage(BuildContext context, Message message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Forward Message'),
            content: const Text('Feature coming soon!'),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
