import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wisdomwalk/models/confession.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/confession_provider.dart';
import 'package:wisdomwalk/utils/app_theme.dart';

class ConfessionCard extends StatefulWidget {
  final Confession confession;

  const ConfessionCard({Key? key, required this.confession}) : super(key: key);

  @override
  State<ConfessionCard> createState() => _ConfessionCardState();
}

class _ConfessionCardState extends State<ConfessionCard> {
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isCommenting = false;
  bool _showComments = false;

  Color _getCategoryColor() {
    switch (widget.confession.category) {
      case 'Confession':
        return Colors.purple.withOpacity(0.7);
      case 'Testimony':
        return Colors.green.withOpacity(0.7);
      case 'Struggle':
        return Colors.orange.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id ?? '';
    final hasHearted = widget.confession.heartUsers.contains(userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppTheme.secondaryColor.withOpacity(0.1),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.confession.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    timeago.format(widget.confession.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Confession content
              Text(
                widget.confession.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  // Heart button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: hasHearted
                          ? null
                          : () {
                              final confessionProvider = Provider.of<ConfessionProvider>(context, listen: false);
                              confessionProvider.addHeart(widget.confession.id, userId);
                            },
                      icon: Icon(
                        hasHearted ? Icons.favorite : Icons.favorite_border,
                        color: hasHearted ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                      label: Text(
                        hasHearted ? 'Hearted' : 'Heart',
                        style: TextStyle(
                          color: hasHearted ? Colors.red : Colors.grey[600],
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: hasHearted ? Colors.red.withOpacity(0.1) : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  // Comment button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCommenting = !_isCommenting;
                          if (!_isCommenting) {
                            _commentController.clear();
                            _isAnonymous = false;
                          }
                          if (_isCommenting && !_showComments && widget.confession.comments.isNotEmpty) {
                            _showComments = true;
                          }
                        });
                      },
                      icon: Icon(
                        Icons.comment_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      label: Text(
                        'Comment',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  
                  // Virtual hug button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Virtual hug sent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.volunteer_activism,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      label: Text(
                        'Hug',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Heart count
              if (widget.confession.heartCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${widget.confession.heartCount} ${widget.confession.heartCount == 1 ? 'heart' : 'hearts'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              
              // Comment form
              if (_isCommenting)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _isAnonymous,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAnonymous = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.accentColor,
                                ),
                                const Text(
                                  'Comment anonymously',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_commentController.text.trim().isNotEmpty) {
                                final confessionProvider = Provider.of<ConfessionProvider>(context, listen: false);
                                confessionProvider.addComment(
                                  widget.confession.id,
                                  _commentController.text.trim(),
                                  _isAnonymous,
                                );
                                _commentController.clear();
                                setState(() {
                                  _isCommenting = false;
                                  _isAnonymous = false;
                                  _showComments = true;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Post'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              // Comments section
              if (widget.confession.comments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showComments = !_showComments;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              'Comments (${widget.confession.comments.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showComments ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      if (_showComments)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widget.confession.comments.length,
                          itemBuilder: (context, index) {
                            final comment = widget.confession.comments[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  comment.isAnonymous
                                      ? Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.person_off,
                                            color: AppTheme.primaryColor,
                                            size: 16,
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                          backgroundImage: comment.userProfilePicture != null
                                              ? NetworkImage(comment.userProfilePicture!)
                                              : null,
                                          child: comment.userProfilePicture == null
                                              ? Text(
                                                  comment.userFullName?.isNotEmpty == true
                                                      ? comment.userFullName![0].toUpperCase()
                                                      : '?',
                                                  style: const TextStyle(
                                                    color: AppTheme.primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              : null,
                                        ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.isAnonymous
                                                  ? 'Anonymous Sister'
                                                  : comment.userFullName ?? 'Unknown',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              timeago.format(comment.createdAt),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 10,
                                              ),
                                            ),
                                            if (comment.isReviewed)
                                              Container(
                                                margin: const EdgeInsets.only(left: 4),
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'Reviewed',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          comment.content,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
