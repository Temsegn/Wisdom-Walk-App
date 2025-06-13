import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/screens/group_detail_screen.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/utils/constants.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<Map<String, dynamic>> _userGroups = [];
  List<Map<String, dynamic>> _availableGroups = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    
    if (socketProvider.socket != null) {
      // Listen for group member changes
      socketProvider.socket!.on('group:member_joined', (data) {
        final groupType = data['groupType'];
        final memberCount = data['memberCount'];
        
        setState(() {
          // Update member count for this group
          for (int i = 0; i < _userGroups.length; i++) {
            if (_userGroups[i]['groupType'] == groupType) {
              _userGroups[i]['memberCount'] = memberCount;
              break;
            }
          }
          
          for (int i = 0; i < _availableGroups.length; i++) {
            if (_availableGroups[i]['groupType'] == groupType) {
              _availableGroups[i]['memberCount'] = memberCount;
              break;
            }
          }
        });
      });
      
      socketProvider.socket!.on('group:member_left', (data) {
        final groupType = data['groupType'];
        final memberCount = data['memberCount'];
        
        setState(() {
          // Update member count for this group
          for (int i = 0; i < _userGroups.length; i++) {
            if (_userGroups[i]['groupType'] == groupType) {
              _userGroups[i]['memberCount'] = memberCount;
              break;
            }
          }
          
          for (int i = 0; i < _availableGroups.length; i++) {
            if (_availableGroups[i]['groupType'] == groupType) {
              _availableGroups[i]['memberCount'] = memberCount;
              break;
            }
          }
        });
      });
    }
  }

  Future<void> _fetchGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Fetch user's joined groups
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/groups/my-groups'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        setState(() {
          _error = responseData['message'] ?? 'Failed to fetch groups';
          _isLoading = false;
        });
        return;
      }

      final List<Map<String, dynamic>> userGroups = List<Map<String, dynamic>>.from(responseData['data']['groups']);
      
      // Define available groups
      final allGroups = [
        {
          'groupType': 'single',
          'name': 'Single & Purposeful',
          'description': 'A community for single women seeking purpose and growth.',
          'icon': Icons.person,
          'color': Colors.purple,
          'memberCount': 0,
        },
        {
          'groupType': 'marriage',
          'name': 'Marriage & Ministry',
          'description': 'Support and encouragement for married women.',
          'icon': Icons.favorite,
          'color': Colors.red,
          'memberCount': 0,
        },
        {
          'groupType': 'healing',
          'name': 'Healing & Forgiveness',
          'description': 'A safe space for healing and finding forgiveness.',
          'icon': Icons.healing,
          'color': Colors.blue,
          'memberCount': 0,
        },
        {
          'groupType': 'motherhood',
          'name': 'Motherhood in Christ',
          'description': 'Support for mothers raising children in faith.',
          'icon': Icons.child_care,
          'color': Colors.green,
          'memberCount': 0,
        },
      ];
      
      // Update member counts from user groups
      for (var userGroup in userGroups) {
        for (var group in allGroups) {
          if (group['groupType'] == userGroup['groupType']) {
            group['memberCount'] = userGroup['memberCount'];
            break;
          }
        }
      }
      
      // Filter out joined groups to get available groups
      final joinedGroupTypes = userGroups.map((g) => g['groupType']).toList();
      final availableGroups = allGroups.where((g) => !joinedGroupTypes.contains(g['groupType'])).toList();

      setState(() {
        _userGroups = userGroups;
        _availableGroups = availableGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Please try again later.';
        _isLoading = false;
      });
    }
  }

  Future<void> _joinGroup(String groupType) async {
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
          'groupType': groupType,
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
          'groupType': groupType,
          'userId': authProvider.user!.id,
        });
        
        // Join the group room
        socketProvider.joinGroupRoom(groupType);
      }

      // Refresh groups
      _fetchGroups();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined ${_getGroupName(groupType)} group')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join group')),
      );
    }
  }

  Future<void> _leaveGroup(String groupType) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/groups/leave'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
        body: json.encode({
          'groupType': groupType,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to leave group')),
        );
        return;
      }

      // Notify socket about leaving group
      if (socketProvider.isConnected) {
        socketProvider.socket!.emit('group:user_left_group', {
          'groupType': groupType,
          'userId': authProvider.user!.id,
        });
        
        // Leave the group room
        socketProvider.leaveGroupRoom(groupType);
      }

      // Refresh groups
      _fetchGroups();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully left ${_getGroupName(groupType)} group')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave group')),
      );
    }
  }

  String _getGroupName(String groupType) {
    switch (groupType) {
      case 'single':
        return 'Single & Purposeful';
      case 'marriage':
        return 'Marriage & Ministry';
      case 'healing':
        return 'Healing & Forgiveness';
      case 'motherhood':
        return 'Motherhood in Christ';
      default:
        return 'Unknown';
    }
  }

  IconData _getGroupIcon(String groupType) {
    switch (groupType) {
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

  Color _getGroupColor(String groupType) {
    switch (groupType) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisdom Circles'),
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
                    onPressed: _fetchGroups,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Wisdom Circles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _userGroups.isEmpty
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'You haven\'t joined any groups yet. Join a group below to connect with other women in similar life seasons.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _userGroups.length,
                              itemBuilder: (context, index) {
                                final group = _userGroups[index];
                                final groupType = group['groupType'];
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getGroupColor(groupType),
                                      child: Icon(
                                        _getGroupIcon(groupType),
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(_getGroupName(groupType)),
                                    subtitle: Text('${group['memberCount']} members'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (group['isAdmin'] == true)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: Chip(
                                              label: Text('Admin'),
                                              backgroundColor: AppTheme.primaryColor,
                                              labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        const Icon(Icons.arrow_forward_ios, size: 16),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => GroupDetailScreen(
                                            groupType: groupType,
                                            groupName: _getGroupName(groupType),
                                            isMember: true,
                                          ),
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Leave ${_getGroupName(groupType)}?'),
                                          content: const Text('Are you sure you want to leave this group?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                _leaveGroup(groupType);
                                              },
                                              child: const Text('Leave'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                      
                      const SizedBox(height: 24),
                      const Text(
                        'Available Wisdom Circles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _availableGroups.isEmpty
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'You\'ve joined all available groups!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _availableGroups.length,
                              itemBuilder: (context, index) {
                                final group = _availableGroups[index];
                                final groupType = group['groupType'];
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getGroupColor(groupType),
                                      child: Icon(
                                        _getGroupIcon(groupType),
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(_getGroupName(groupType)),
                                    subtitle: Text(group['description']),
                                    trailing: ElevatedButton(
                                      onPressed: () => _joinGroup(groupType),
                                      child: const Text('Join'),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => GroupDetailScreen(
                                            groupType: groupType,
                                            groupName: _getGroupName(groupType),
                                            isMember: false,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}
