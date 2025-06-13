import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/post.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/utils/constants.dart';
import 'package:wisdomwalk/widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _fetchPosts(page: _page + 1);
      }
    }
  }

  Future<void> _fetchPosts({int page = 1}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/posts/feed?page=$page&limit=10'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch posts';
          _isLoading = false;
        });
        return;
      }

      final List<Post> newPosts = (responseData['data'] as List)
          .map((post) => Post.fromJson(post))
          .toList();

      setState(() {
        if (page == 1) {
          _posts.clear();
        }
        _posts.addAll(newPosts);
        _page = page;
        _hasMore = newPosts.length == 10;
        _isLoading = false;
      });

      // Setup socket listeners for real-time updates
      _setupSocketListeners();
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _setupSocketListeners() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    // Listen for like updates
    for (var post in _posts) {
      socketProvider.listenForLikeUpdates(post.id, (likesCount, isLiked) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            // Create a new post object with updated likes
            final updatedPost = Post(
              id: post.id,
              author: post.author,
              type: post.type,
              content: post.content,
              title: post.title,
              images: post.images,
              location: post.location,
              isAnonymous: post.isAnonymous,
              visibility: post.visibility,
              targetGroup: post.targetGroup,
              likes: post.likes, // This should be updated properly in a real app
              prayers: post.prayers,
              virtualHugs: post.virtualHugs,
              commentsCount: post.commentsCount,
              tags: post.tags,
              isPinned: post.isPinned,
              createdAt: post.createdAt,
            );
            _posts[index] = updatedPost;
          }
        });
      });

      // Listen for new comments
      socketProvider.listenForNewComments(post.id, (comment) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            // Create a new post object with updated comment count
            final updatedPost = Post(
              id: post.id,
              author: post.author,
              type: post.type,
              content: post.content,
              title: post.title,
              images: post.images,
              location: post.location,
              isAnonymous: post.isAnonymous,
              visibility: post.visibility,
              targetGroup: post.targetGroup,
              likes: post.likes,
              prayers: post.prayers,
              virtualHugs: post.virtualHugs,
              commentsCount: post.commentsCount + 1,
              tags: post.tags,
              isPinned: post.isPinned,
              createdAt: post.createdAt,
            );
            _posts[index] = updatedPost;
          }
        });
      });
    }
  }

  Future<void> _refreshPosts() async {
    _fetchPosts(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WisdomWalk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create post screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: _error != null
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
                    onPressed: _refreshPosts,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshPosts,
              child: _posts.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                      ? const Center(child: Text('No posts found'))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _posts.length + (_isLoading && _hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _posts.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return PostCard(post: _posts[index]);
                          },
                        ),
            ),
    );
  }
}
