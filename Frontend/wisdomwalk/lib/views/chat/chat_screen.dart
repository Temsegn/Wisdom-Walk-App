import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/local_storage_service.dart';
import '../../services/socket_service.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../providers/message_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _isInitialLoad = true;
  String? _currentUserId;
  SocketService? _socketService;
  
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCurrentUserId();
    _scrollController.addListener(_onScroll);
    _loadInitialMessages();
    _markChatAsRead();
    _connectToSocket();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _fabScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _fabAnimationController.forward();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await _localStorageService.getCurrentUserId();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      context.read<MessageProvider>().loadMessages(widget.chat.id);
    }
  }

  Future<void> _loadInitialMessages() async {
    await context.read<MessageProvider>().loadMessages(
      widget.chat.id,
      refresh: true, 
    );
    setState(() => _isInitialLoad = false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _markChatAsRead() {
    context.read<ChatProvider>().markChatAsRead(widget.chat.id);
  }

  Future<void> _connectToSocket() async {
    final token = await _localStorageService.getAuthToken();
    if (token != null && mounted) {
      _socketService = SocketService(context);
      _socketService!.connect(token);
      
      // Wait a bit for connection to establish, then join chat
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && _socketService?.isConnected == true) {
          _socketService!.joinChat(widget.chat.id);
        }
      });
    }
  }

  @override
  void dispose() {
    _socketService?.leaveChat(widget.chat.id);
    _socketService?.disconnect();
    _scrollController.dispose();
    _messageController.dispose();
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverFillRemaining(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildPinnedMessageIndicator(),
                    Expanded(child: _buildMessageList()),
                    _buildReplyIndicator(),
                    _buildMessageInput(),
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
      expandedHeight: 160.0,
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
                Color(0xFF10B981),
                Color(0xFF06B6D4),
                Color(0xFF8B5CF6),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'chat_avatar_${widget.chat.id}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: widget.chat.chatImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(17),
                                  child: Image.network(
                                    widget.chat.chatImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    widget.chat.chatName?.isNotEmpty ?? false
                                        ? widget.chat.chatName![0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.chat.chatName ?? 'Unknown Chat',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_socketService?.isConnected == true) ...[
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    _socketService?.isConnected == true 
                                        ? 'Online' 
                                        : 'Connecting...',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.videocam_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.call_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: _handleMenuAction,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'search', child: Text('Search')),
              const PopupMenuItem(value: 'mute', child: Text('Mute')),
              const PopupMenuItem(value: 'block', child: Text('Block')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final messages = messageProvider.getChatMessages(widget.chat.id);
        final isLoading = messageProvider.isLoading(widget.chat.id);
        final error = messageProvider.getError(widget.chat.id);

        if (_isInitialLoad && messages.isEmpty) {
          return _buildShimmerLoading();
        }

        if (error != null) {
          return _buildErrorState(error, messageProvider);
        }

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            reverse: true,
            itemCount: messages.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF10B981),
                    ),
                  ),
                );
              }

              final message = messages[messages.length - 1 - index];
              final isCurrentUser = message.sender.id == _currentUserId;

              return MessageBubble(
                message: message,
                isCurrentUser: isCurrentUser,
                onReply: () => _setReplyMessage(message),
                onEdit: () => _editMessage(message),
                onDelete: () => _deleteMessage(message),
                onReact: (emoji) => _addReaction(message, emoji),
                onPin: () => _pinMessage(message),
                onForward: () => _forwardMessage(message),
              );
            },
          ),
        );
      },
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
              height: 60,
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

  Widget _buildErrorState(String error, MessageProvider messageProvider) {
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
              const Text(
                'Error loading messages',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error,
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
                    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    messageProvider.clearError(widget.chat.id);
                    _loadInitialMessages();
                  },
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

  Widget _buildEmptyState() {
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981).withOpacity(0.1),
                      const Color(0xFF06B6D4).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Send the first message to start the conversation!',
                style: TextStyle(
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

  Widget _buildReplyIndicator() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        if (messageProvider.replyToMessage == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.1),
                const Color(0xFF06B6D4).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.reply_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replying to ${messageProvider.replyToMessage!.sender.fullName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      messageProvider.replyToMessage!.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  onPressed: () => messageProvider.setReplyToMessage(null),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinnedMessageIndicator() {
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        final pinnedMessageId = messageProvider.getPinnedMessageId(widget.chat.id);
        if (pinnedMessageId == null) return const SizedBox.shrink();

        final pinnedMessage = messageProvider.getMessage(widget.chat.id, pinnedMessageId);
        if (pinnedMessage == null || pinnedMessage.content.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF59E0B).withOpacity(0.1),
                const Color(0xFFEF4444).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.push_pin_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pinned Message',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pinnedMessage.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: _fabScaleAnimation,
        child: MessageInput(
          controller: _messageController,
          onSendMessage: _sendMessage,
          onAttachFile: _attachFile,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'search':
        break;
      case 'mute':
        break;
      case 'block':
        break;
    }
  }

  void _setReplyMessage(Message message) {
    context.read<MessageProvider>().setReplyToMessage(message);
  }

  void _editMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => EditMessageDialog(
        message: message,
        onEdit: (newContent) {
          context.read<MessageProvider>().editMessage(
            message.id,
            newContent,
          );
          _socketService?.emitMessageEdited(widget.chat.id, message.id, newContent);
        },
      ),
    );
  }

  void _deleteMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
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
                context.read<MessageProvider>().deleteMessage(message.id);
                _socketService?.emitMessageDeleted(widget.chat.id, message.id);
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

  void _addReaction(Message message, String emoji) {
    context.read<MessageProvider>().addReaction(message.id, emoji);
    _socketService?.addReaction(widget.chat.id, message.id, emoji);
  }

  void _pinMessage(Message message) {
    context.read<MessageProvider>().pinMessage(widget.chat.id, message.id);
    _socketService?.pinMessage(widget.chat.id, message.id);
  }

  void _forwardMessage(Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    final messageProvider = context.read<MessageProvider>();
    await messageProvider.sendMessage(
      chatId: widget.chat.id,
      content: content.trim(),
    );
    
    _messageController.clear();
    
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _attachFile() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              _buildAttachmentOption(
                icon: Icons.photo_rounded,
                title: 'Photo',
                subtitle: 'Share a photo from gallery',
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    final file = File(pickedFile.path);
                    await context.read<MessageProvider>().sendMessage(
                      chatId: widget.chat.id,
                      content: 'Photo',
                      messageType: 'image',
                      attachments: [file],
                    );
                  }
                },
              ),
              _buildAttachmentOption(
                icon: Icons.camera_alt_rounded,
                title: 'Camera',
                subtitle: 'Take a photo with camera',
                gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)]),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    final file = File(pickedFile.path);
                    await context.read<MessageProvider>().sendMessage(
                      chatId: widget.chat.id,
                      content: 'Photo',
                      messageType: 'image',
                      attachments: [file],
                    );
                  }
                },
              ),
              _buildAttachmentOption(
                icon: Icons.insert_drive_file_rounded,
                title: 'Document',
                subtitle: 'Share a document',
                gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                onTap: () async {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
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

class EditMessageDialog extends StatefulWidget {
  final Message message;
  final Function(String) onEdit;

  const EditMessageDialog({
    Key? key,
    required this.message,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Text('Edit Message'),
        ],
      ),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter your message...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onEdit(_controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
