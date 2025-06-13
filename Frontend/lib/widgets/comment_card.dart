import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/comment.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/socket_provider.dart';
import 'package:wisdomwalk/screens/profile_screen.dart';
import 'package:wisdomwalk/utils/app_theme.dart';
import 'package:wisdomwalk/utils/constants.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final String postId;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.postId,
  }) : super(key: key);

  Future<void> _likeComment(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final socketProvider = Provider.of<SocketProvider>(context, listen: false);
      
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/posts/$postId/comments/${comment.id}/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Failed to like comment')),
        );
        return;
      }
      
      // If socket is not connected, update UI manually
      if (!socketProvider.isConnected) {
        // In a real app, you'd update the comment's likes count here
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to like comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id ?? '';
    final isLiked = comment.likes.contains(userId);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: comment.user.id),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: comment.user.profilePicture != null
                    ? NetworkImage(comment.user.profilePicture!)
                    : null,
                child: comment.user.profilePicture == null
                    ? Text(comment.user.firstName[0])
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(userId: comment.user.id),
                            ),
                          );
                        },
                        child: Text(
                          '${comment.user.firstName} ${comment.user.lastName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• ${timeago.format(comment.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _likeComment(context),
                        child: Row(
                          children: [
                            Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isLiked ? AppTheme.primaryColor : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              comment.likes.length.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          // Reply to comment
                        },
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
