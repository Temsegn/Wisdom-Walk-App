import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';
import 'package:wisdomwalk/providers/wisdom_circle_provider.dart';

class WisdomCircleCard extends StatefulWidget {
  final WisdomCircleModel circle;
  final bool isJoined;
  final VoidCallback onTap;

  const WisdomCircleCard({
    Key? key,
    required this.circle,
    required this.isJoined,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WisdomCircleCard> createState() => _WisdomCircleCardState();
}

class _WisdomCircleCardState extends State<WisdomCircleCard> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WisdomCircleProvider>(context, listen: false);
    final hasNewMessages = true; // Simulate new messages for demo
    final sampleMessage =
        'Sarah: "Thank you all for the prayers! ✨"'; // Sample message

    Color cardColor = _getCardColor();
    String buttonText = widget.isJoined ? 'Open' : 'Join';
    Color buttonColor = widget.isJoined ? Colors.green : Colors.grey[300]!;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getIconColor(),
                  child: Text(
                    widget.circle.name[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.circle.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        widget.circle.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (widget.isJoined) {
                      widget.onTap();
                    } else {
                      await provider.joinCircle(
                        circleId: widget.circle.id,
                        userId: 'user123',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Joined ${widget.circle.name}!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor:
                        widget.isJoined ? Colors.white : Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ⓘ ${widget.circle.memberCount} members ${hasNewMessages ? '⭕ 3 new messages' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              sampleMessage,
              style: TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor() {
    switch (widget.circle.id) {
      case '1': // Single & Purposeful
        return const Color(0xFFFFE4E6); // Light pink
      case '2': // Marriage & Ministry
        return const Color(0xFFE8E4FF); // Light purple
      case '3': // Motherhood in Christ
        return const Color(0xFFE4F3FF); // Light blue
      case '4': // Healing & Forgiveness
        return const Color(0xFFE4FFE8); // Light green
      case '5': // Mental Health & Faith
        return const Color(0xFFFFF4E4); // Light orange
      default:
        return const Color(0xFFF5F5F5); // Light gray
    }
  }

  Color _getIconColor() {
    switch (widget.circle.id) {
      case '1':
        return const Color(0xFFE91E63); // Pink
      case '2':
        return const Color(0xFF9C27B0); // Purple
      case '3':
        return const Color(0xFF2196F3); // Blue
      case '4':
        return const Color(0xFF4CAF50); // Green
      case '5':
        return const Color(0xFFFF9800); // Orange
      default:
        return Colors.grey;
    }
  }
}
