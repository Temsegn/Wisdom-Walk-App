import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wisdomwalk/models/prayer_request.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';
import 'package:wisdomwalk/utils/app_theme.dart';

class PrayerCard extends StatefulWidget {
  final PrayerRequest prayer;

  const PrayerCard({Key? key, required this.prayer}) : super(key: key);

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = false;
  bool _isCommenting = false;
  bool _showComments = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id ?? '';
    final hasPrayed = widget.prayer.prayingUsers.contains(userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info or Anonymous
            Row(
              children: [
                widget.prayer.isAnonymous
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person_off,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        backgroundImage: widget.prayer.userProfilePicture != null
                            ? NetworkImage(widget.prayer.userProfilePicture!)
                            : null,
                        child: widget.prayer.userProfilePicture == null
                            ? Text(
                                widget.prayer.userFullName?.isNotEmpty == true
                                    ? widget.prayer.userFullName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.prayer.isAnonymous
                            ? 'Anonymous Sister'
                            : widget.prayer.userFullName ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeago.format(widget.prayer.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Prayer content
            Text(
              widget.prayer.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                // Pray button
                Expanded(
                  child: TextButton.icon(
                    onPressed: hasPrayed
                        ? null
                        : () {
                            final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
                            prayerProvider.prayForRequest(widget.prayer.id, userId);
                          },
                    icon: Icon(
                      Icons.volunteer_activism,
                      color: hasPrayed ? AppTheme.accentColor : Colors.grey[600],
                      size: 20,
                    ),
                    label: Text(
                      hasPrayed ? 'Praying' : 'Pray',
                      style: TextStyle(
                        color: hasPrayed ? AppTheme.accentColor : Colors.grey[600],
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: hasPrayed ? AppTheme.accentColor.withOpacity(0.1) : Colors.transparent,
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
                        if (_isCommenting && !_showComments && widget.prayer.comments.isNotEmpty) {
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
                      Icons.favorite_border,
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
            
            // Prayer count
            if (widget.prayer.prayerCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${widget.prayer.prayerCount} ${widget.prayer.prayerCount == 1 ? 'sister is' : 'sisters are'} praying',
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
                              final prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
                              prayerProvider.addComment(
                                widget.prayer.id,
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
            if (widget.prayer.comments.isNotEmpty)
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
                            'Comments (${widget.prayer.comments.length})',
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
                        itemCount: widget.prayer.comments.length,
                        itemBuilder: (context, index) {
                          final comment = widget.prayer.comments[index];
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
    );
  }
}
