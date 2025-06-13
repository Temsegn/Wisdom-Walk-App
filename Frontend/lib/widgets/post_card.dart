import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wisdomwalk/models/post.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/screens/post_detail_screen.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/utils/constants.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiking = false;
  bool _isPraying = false;
  bool _isHugging = false;
  late Post _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      
      // Use Socket.io for real-time like update
      if (socketProvider.isConnected) {
        socketProvider.toggleLike(_post.id);
        
        // Optimistically update UI
        final userId = authProvider.user!.id;
        final isLiked = _post.isLikedByUser(userId);
        
        setState(() {
          if (isLiked) {
            // Remove like
            _post = Post(
              id: _post.id,
              author: _post.author,
              type: _post.type,
              content: _post.content,
              title: _post.title,
              images: _post.images,
              location: _post.location,
              isAnonymous: _post.isAnonymous,
              visibility: _post.visibility,
              targetGroup: _post.targetGroup,
              likes: _post.likes.where((like) => like.userId != userId).toList(),
              prayers: _post.prayers,
              virtualHugs: _post.virtualHugs,
              commentsCount: _post.commentsCount,
              tags: _post.tags,
              isPinned: _post.isPinned,
              createdAt: _post.createdAt,
            );
          } else {
            // Add like
            _post = Post(
              id: _post.id,
              author: _post.author,
              type: _post.type,
              content: _post.content,
              title: _post.title,
              images: _post.images,
              location: _post.location,
              isAnonymous: _post.isAnonymous,
              visibility: _post.visibility,
              targetGroup: _post.targetGroup,
              likes: [
                ..._post.likes,
                PostLike(
                  userId: userId,
                  createdAt: DateTime.now(),
                ),
              ],
              prayers: _post.prayers,
              virtualHugs: _post.virtualHugs,
              commentsCount: _post.commentsCount,
              tags: _post.tags,
              isPinned: _post.isPinned,
              createdAt: _post.createdAt,
            );
          }
        });
      } else {
        // Fallback to REST API
        final response = await http.post(
          Uri.parse('${Constants.apiUrl}/posts/${_post.id}/like'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authProvider.token}',
          },
        );

        final responseData = json.decode(response.body);
        
        if (response.statusCode >= 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Failed to like post')),
          );
          return;
        }

        // Update post with new like status
        final userId = authProvider.user!.id;
        final isLiked = responseData['data']['isLiked'];
        
        setState(() {
          if (!isLiked) {
            // Remove like
            _post = Post(
              id: _post.id,
              author: _post.author,
              type: _post.type,
              content: _post.content,
              title: _post.title,
              images: _post.images,
              location: _post.location,
              isAnonymous: _post.isAnonymous,
              visibility: _post.visibility,
              targetGroup: _post.targetGroup,
              likes: _post.likes.where((like) => like.userId != userId).toList(),
              prayers: _post.prayers,
              virtualHugs: _post.virtualHugs,
              commentsCount: _post.commentsCount,
              tags: _post.tags,
              isPinned: _post.isPinned,
              createdAt: _post.createdAt,
            );
          } else {
            // Add like
            _post = Post(
              id: _post.id,
              author: _post.author,
              type: _post.type,
              content: _post.content,
              title: _post.title,
              images: _post.images,
              location: _post.location,
              isAnonymous: _post.isAnonymous,
              visibility: _post.visibility,
              targetGroup: _post.targetGroup,
              likes: [
                ..._post.likes,
                PostLike(
                  userId: userId,
                  createdAt: DateTime.now(),
                ),
              ],
              prayers: _post.prayers,
              virtualHugs: _post.virtualHugs,
              commentsCount: _post.commentsCount,
              tags: _post.tags,
              isPinned: _post.isPinned,
              createdAt: _post.createdAt,
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to like post')),
      );
    } finally {
      setState(() {
        _isLiking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user!.id;
    final isLiked = _post.isLikedByUser(userId);
    final isPrayed = _post.isPrayedByUser(userId);
    final isHugged = _post.isHuggedByUser(userId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(post: _post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with author info
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: _post.author.profilePicture != null
                        ? NetworkImage(_post.author.profilePicture!)
                        : null,
                    child: _post.author.profilePicture == null
                        ? Text(_post.author.firstName[0])
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _post.isAnonymous ? 'Anonymous Sister' : _post.author.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeago.format(_post.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_post.isPinned)
                    const Icon(
                      Icons.push_pin,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      // Handle menu item selection
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'save',
                        child: Text('Save Post'),
                      ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('Report Post'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Post title
              if (_post.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _post.title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              
              // Post content
              Text(_post.content),
