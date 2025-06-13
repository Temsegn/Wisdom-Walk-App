import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/post.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/utils/constants.dart';
import 'package:wisdomwalk/widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _userProfile;
  List<Post> _userPosts = [];
  bool _isLoading = false;
  bool _isLoadingPosts = false;
  String? _error;
  File? _imageFile;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id;
      final targetUserId = widget.userId ?? currentUserId;
      
      _isCurrentUser = targetUserId == currentUserId;

      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/users/$targetUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch user profile';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userProfile = responseData['data'];
        _isLoading = false;
      });
      
      // Fetch user posts
      _fetchUserPosts();
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserPosts() async {
    if (_userProfile == null) return;

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final targetUserId = widget.userId ?? authProvider.user?.id;

      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/posts/user/$targetUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch user posts';
          _isLoadingPosts = false;
        });
        return;
      }

      final List<Post> posts = (responseData['data'] as List)
          .map((post) => Post.fromJson(post))
          .toList();

      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not fetch user posts';
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      
      // Upload the image
      _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_imageFile == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiUrl}/users/profile-picture'),
      );
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer ${authProvider.token}';
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture',
          _imageFile!.path,
        ),
      );
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to upload profile picture')),
        );
        return;
      }
      
      // Update user profile
      _fetchUserProfile();
      
      // Update auth provider
      authProvider.refreshUserData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isCurrentUser)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings screen
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
                    onPressed: _fetchUserProfile,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userProfile == null
                  ? const Center(child: Text('User not found'))
                  : Column(
                      children: [
                        // Profile header
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: _userProfile!['profilePicture'] != null
                                        ? NetworkImage(_userProfile!['profilePicture'])
                                        : null,
                                    child: _userProfile!['profilePicture'] == null
                                        ? Text(
                                            '${_userProfile!['firstName'][0]}${_userProfile!['lastName'][0]}',
                                            style: const TextStyle(fontSize: 36),
                                          )
                                        : null,
                                  ),
                                  if (_isCurrentUser)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_userProfile!['firstName']} ${_userProfile!['lastName']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${_userProfile!['username']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (_userProfile!['bio'] != null && _userProfile!['bio'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _userProfile!['bio'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStatColumn('Posts', _userProfile!['postCount'] ?? 0),
                                  Container(
                                    height: 24,
                                    width: 1,
                                    color: Colors.grey[300],
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  _buildStatColumn('Followers', _userProfile!['followerCount'] ?? 0),
                                  Container(
                                    height: 24,
                                    width: 1,
                                    color: Colors.grey[300],
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  _buildStatColumn('Following', _userProfile!['followingCount'] ?? 0),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (!_isCurrentUser)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Follow/Unfollow user
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _userProfile!['isFollowing'] ?? false
                                            ? Colors.grey[200]
                                            : AppTheme.primaryColor,
                                        foregroundColor: _userProfile!['isFollowing'] ?? false
                                            ? Colors.black
                                            : Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                      ),
                                      child: Text(
                                        _userProfile!['isFollowing'] ?? false ? 'Following' : 'Follow',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Message user
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                      ),
                                      child: const Text('Message'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        
                        // Tabs
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Posts'),
                            Tab(text: 'Saved'),
                          ],
                        ),
                        
                        // Tab content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Posts tab
                              _isLoadingPosts
                                  ? const Center(child: CircularProgressIndicator())
                                  : _userPosts.isEmpty
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text('No posts yet'),
                                              if (_isCurrentUser)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 16),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      // Navigate to create post screen
                                                    },
                                                    child: const Text('Create First Post'),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        )
                                      : RefreshIndicator(
                                          onRefresh: _fetchUserPosts,
                                          child: ListView.builder(
                                            itemCount: _userPosts.length,
                                            itemBuilder: (context, index) {
                                              return PostCard(post: _userPosts[index]);
                                            },
                                          ),
                                        ),
                              
                              // Saved tab
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isCurrentUser)
                                      const Text('No saved posts yet')
                                    else
                                      const Text('This content is private'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
