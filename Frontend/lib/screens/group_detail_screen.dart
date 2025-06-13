import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/post.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/screens/group_chat_screen.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/utils/constants.dart';
import 'package:wisdomwalk/widgets/post_card.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupType;
  final String groupName;
  final bool isMember;

  const GroupDetailScreen({
    Key? key,
    required this.groupType,
    required this.groupName,
    required this.isMember,
  }) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Post> _posts = [];
  final List<Map<String, dynamic>> _members = [];
  final List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;
  String? _error;
  int _onlineMembers = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    if (widget.isMember) {
      _fetchGroupData();
      _joinGroupRoom();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _leaveGroupRoom();
    super.dispose();
  }

  void _joinGroupRoom() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    if (socketProvider.isConnected) {
      socketProvider.joinGroupRoom(widget.groupType);
      
      // Listen for online members
      socketProvider.socket!.emit('group:get_online_members', {
        'groupType': widget.groupType,
      });
      
      socketProvider.socket!.on('group:online_members', (data) {
        if (data['groupType'] == widget.groupType) {
          setState(() {
            _onlineMembers = data['count'];
          });
        }
      });
      
      // Listen for post pin toggling
      socketProvider.socket!.on('group:post_pin_toggled', (data) {
        if (data['groupType'] == widget.groupType) {
          final postId = data['postId'];
          final isPinned = data['isPinned'];
          
          setState(() {
            final postIndex = _posts.indexWhere((p) => p.id == postId);
            if (postIndex != -1) {
              // Update post pin status
              // In a real app, you'd create a new post with updated pin status
            }
          });
        }
      });
      
      // Listen for new posts
      socketProvider.socket!.on('group:post_created', (data) {
        if (data['groupType'] == widget.groupType) {
          // Refresh posts
          _fetchGroupPosts();
        }
      });
    }
  }

  void _leaveGroupRoom() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    if (socketProvider.isConnected) {
      socketProvider.leaveGroupRoom(widget.groupType);
      
      // Remove listeners
      socketProvider.socket!.off('group:online_members');
      socketProvider.socket!.off('group:post_pin_toggled');
      socketProvider.socket!.off('group:post_created');
    }
  }

  Future<void> _fetchGroupData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _fetchGroupPosts(),
        _fetchGroupMembers(),
        _fetchGroupChats(),
      ]);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchGroupPosts() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/posts/feed?group=${widget.groupType}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch posts';
        });
        return;
      }

      final List<Post> posts = (responseData['data'] as List)
          .map((post) => Post.fromJson(post))
          .toList();

      setState(() {
        _posts.clear();
        _posts.addAll(posts);
      });
    } catch (e) {
      setState(() {
        _error = 'Could not fetch group posts';
      });
    }
  }

  Future<void> _fetchGroupMembers() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/groups/${widget.groupType}/members'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch members';
        });
        return;
      }

      final List<Map<String, dynamic>> members = List<Map<String, dynamic>>.from(responseData['data']);

      setState(() {
        _members.clear();
        _members.addAll(members);
      });
    } catch (e) {
      setState(() {
        _error = 'Could not fetch group members';
      });
    }
  }

  Future<void> _fetchGroupChats() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/groups/${widget.groupType}/chats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch chats';
        });
        return;
      }

      final List<Map<String, dynamic>> chats = List<Map<String, dynamic>>.from(responseData['data']);

      setState(() {
        _chats.clear();
        _chats.addAll(chats);
      });
    } catch (e) {
      setState(() {
        _error = 'Could not fetch group chats';
      });
    }
  }

  Future<void> _joinGroup() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/groups/join'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: json.encode({
          'groupType': widget.groupType,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to join group')),
        );
        return;
      }

      // Notify socket about joining group
      if (socketProvider.isConnected) {
        socketProvider.socket!.emit('group:user_joined_group', {
          'groupType': widget.groupType,
          'userId': authProvider.user!.id,
        });
        
        // Join the group room
        socketProvider.joinGroupRoom(widget.groupType);
      }

      // Refresh group data
      _fetchGroupData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined ${widget.groupName} group')),
      );
      
      // Refresh the page to show member content
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GroupDetailScreen(
            groupType: widget.groupType,
            groupName: widget.groupName,
            isMember: true,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join group')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        bottom: widget.isMember
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Members'),
                  Tab(text: 'Chats'),
                ],
              )
            : null,
      ),
      body: widget.isMember
          ? _error != null
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
                        onPressed: _fetchGroupData,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Posts tab
                        _posts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('No posts yet'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to create post screen
                                      },
                                      child: const Text('Create First Post'),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchGroupPosts,
                                child: ListView.builder(
                                  itemCount: _posts.length,
                                  itemBuilder: (context, index) {
                                    return PostCard(post: _posts[index]);
                                  },
                                ),
                              ),
                        
                        // Members tab
                        _members.isEmpty
                            ? const Center(child: Text('No members found'))
                            : RefreshIndicator(
                                onRefresh: _fetchGroupMembers,
                                child: ListView.builder(
                                  itemCount: _members.length + 1, // +1 for header
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_members.length} members',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$_onlineMembers online',
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    
                                    final member = _members[index - 1];
                                    final isAdmin = member['groupInfo']['isAdmin'] ?? false;
                                    
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: member['profilePicture'] != null
                                            ? NetworkImage(member['profilePicture'])
                                            : null,
                                        child: member['profilePicture'] == null
                                            ? Text('${member['firstName'][0]}${member['lastName'][0]}')
                                            : null,
                                      ),
                                      title: Row(
                                        children: [
                                          Text('${member['firstName']} ${member['lastName']}'),
                                          if (isAdmin)
                                            const Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: Icon(
                                                Icons.star,
                                                color: AppTheme.primaryColor,
                                                size: 16,
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        'Joined ${DateTime.now().difference(DateTime.parse(member['groupInfo']['joinedAt'])).inDays} days ago',
                                      ),
                                      trailing: const Icon(Icons.message),
                                      onTap: () {
                                        // Navigate to direct message with this member
                                      },
                                    );
                                  },
                                ),
                              ),
                        
                        // Chats tab
                        _chats.isEmpty
                            ? const Center(child: Text('No chats found'))
                            : RefreshIndicator(
                                onRefresh: _fetchGroupChats,
                                child: ListView.builder(
                                  itemCount: _chats.length,
                                  itemBuilder: (context, index) {
                                    final chat = _chats[index];
                                    
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor,
                                        child: Text(
                                          chat['groupName'][0],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(chat['groupName']),
                                      subtitle: Text('${chat['participantsCount']} participants'),
                                      trailing: chat['unreadCount'] > 0
                                          ? Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                chat['unreadCount'].toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                          : const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => GroupChatScreen(
                                              chatId: chat['id'],
                                              chatName: chat['groupName'],
                                              groupType: widget.groupType,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                      ],
                    )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getGroupColor(),
                                radius: 24,
                                child: Icon(
                                  _getGroupIcon(),
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.groupName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getGroupDescription(),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'About this Wisdom Circle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_getGroupLongDescription()),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _joinGroup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              child: const Text(
                                'Join This Circle',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'What to expect in this circle:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    icon: Icons.forum,
                    title: 'Group Discussions',
                    description: 'Share your experiences and learn from others in similar life seasons.',
                  ),
                  _buildFeatureCard(
                    icon: Icons.book,
                    title: 'Scripture Sharing',
                    description: 'Find encouragement through Bible verses shared by community members.',
                  ),
                  _buildFeatureCard(
                    icon: Icons.event,
                    title: 'Prayer Requests',
                    description: 'Submit prayer requests and pray for others in the community.',
                  ),
                  _buildFeatureCard(
                    icon: Icons.people,
                    title: 'Mentorship',
                    description: 'Connect with mentors who can provide guidance and wisdom.',
                  ),
                ],
              ),
            ),
      floatingActionButton: widget.isMember && _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to create post screen
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGroupIcon() {
    switch (widget.groupType) {
      case 'single':
        return Icons.person;
      case 'marriage':
        return Icons.favorite;
      case 'healing':
        return Icons.healing;
      case 'motherhood':
        return Icons.child_care;
      default:
        return Icons.group;
    }
  }

  Color _getGroupColor() {
    switch (widget.groupType) {
      case 'single':
        return Colors.purple;
      case 'marriage':
        return Colors.red;
      case 'healing':
        return Colors.blue;
      case 'motherhood':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getGroupDescription() {
    switch (widget.groupType) {
      case 'single':
        return 'A community for single women seeking purpose and growth.';
      case 'marriage':
        return 'Support and encouragement for married women.';
      case 'healing':
        return 'A safe space for healing and finding forgiveness.';
      case 'motherhood':
        return 'Support for mothers raising children in faith.';
      default:
        return '';
    }
  }

  String _getGroupLongDescription() {
    switch (widget.groupType) {
      case 'single':
        return 'The Single & Purposeful circle is a supportive community for single Christian women who are navigating life\'s journey with purpose and intention. Here, you\'ll find encouragement, practical advice, and spiritual guidance to help you thrive in your current season while preparing for God\'s plan for your future.';
      case 'marriage':
        return 'The Marriage & Ministry circle is dedicated to supporting women in building Christ-centered marriages. Whether you\'re newly married or have been together for decades, this community offers biblical wisdom, practical tools, and prayer support to help you nurture a relationship that honors God and serves as a ministry to others.';
      case 'healing':
        return 'The Healing & Forgiveness circle provides a safe, compassionate space for women seeking emotional and spiritual healing. Through Scripture, prayer, and authentic community, we journey together toward freedom from past wounds, learning to extend and receive forgiveness, and embracing God\'s restorative power in our lives.';
      case 'motherhood':
        return 'The Motherhood in Christ circle is a nurturing community for mothers at all stages of parenting. We share biblical wisdom, practical encouragement, and prayer support as we raise our children to know and love the Lord. From newborns to adult children, we\'re here to support you in your God-given calling of motherhood.';
      default:
        return '';
    }
  }
}
