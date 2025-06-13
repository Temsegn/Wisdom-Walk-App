import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/comment.dart';
import 'package:wisdomwalk/models/post.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/utils/constants.dart';
import 'package:wisdomwalk/widgets/comment_card.dart';
import 'package:wisdomwalk/widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final List<Comment> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  Post? _updatedPost;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    if (socketProvider.socket != null) {
      // Listen for new comments
      socketProvider.socket!.on('post:comment_added', (data) {
        if (data['postId'] == widget.post.id) {
          final comment = Comment.fromJson(data['comment']);
          setState(() {
            _comments.add(comment);
          });
        }
      });
      
      // Listen for comment likes
      socketProvider.socket!.on('post:comment_liked', (data) {
        if (data['postId'] == widget.post.id) {
          final commentId = data['commentId'];
          final likes = data['likes'];
          
          setState(() {
            final commentIndex = _comments.indexWhere((c) => c.id == commentId);
            if (commentIndex != -1) {
              final updatedComment = _comments[commentIndex].copyWith(
                likes: likes,
              );
              _comments[commentIndex] = updatedComment;
            }
          });
        }
      });
      
      // Listen for post updates
      socketProvider.socket!.on('post:updated', (data) {
        if (data['postId'] == widget.post.id) {
          final updatedPost = Post.fromJson(data['post']);
          setState(() {
            _updatedPost = updatedPost;
          });
        }
      });
    }
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/posts/${widget.post.id}/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch comments';
          _isLoading = false;
        });
        return;
      }

      final List<Comment> comments = (responseData['data'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList();

      setState(() {
        _comments.clear();
        _comments.addAll(comments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/posts/${widget.post.id}/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: json.encode({
          'content': comment,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to add comment')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      _commentController.clear();
      
      // If socket is not connected, add the comment locally
      if (!socketProvider.isConnected) {
        final newComment = Comment.fromJson(responseData['data']);
        setState(() {
          _comments.add(newComment);
        });
      }
      
      setState(() {
        _isSubmitting = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add comment')),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Column(
        children: [
          // Post card
          PostCard(
            post: _updatedPost ?? widget.post,
            isDetailView: true,
          ),
          
          // Comments section
          Expanded(
            child: _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchComments,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(child: Text('No comments yet'))
                        : ListView.builder(
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              return CommentCard(
                                comment: _comments[index],
                                postId: widget.post.id,
                              );
                            },
                          ),
          ),
          
          // Comment input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
