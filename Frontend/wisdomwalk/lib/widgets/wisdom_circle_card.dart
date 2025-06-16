import 'package:flutter/material.dart';
import 'package:wisdomwalk/models/wisdom_circle_model.dart';

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
  late bool _isJoined;

  @override
  void initState() {
    super.initState();
    _isJoined = widget.isJoined;
  }

  Color _getCardColor() {
    switch (widget.circle.id) {
      case '1':
        return const Color(0xFFFFE4E6); // Light pink
      case '2':
        return const Color(0xFFE8E4FF); // Light purple
      case '3':
        return const Color(0xFFE4F3FF); // Light blue
      case '4':
        return const Color(0xFFE4FFE8); // Light green
      case '5':
        return const Color(0xFFFFF4E4); // Light orange
      default:
        return const Color(0xFFF5F5F5); // Light gray
    }
  }

  Color _getButtonColor() {
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
        return const Color(0xFF757575); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Image
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(widget.circle.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Circle Name
              Text(
                widget.circle.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Member Count
              Text(
                '${widget.circle.memberCount} members',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                widget.circle.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Join/Joined Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isJoined = !_isJoined;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isJoined
                              ? '✅ Joined ${widget.circle.name}!'
                              : '👋 Left ${widget.circle.name}',
                        ),
                        backgroundColor: _getButtonColor(),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isJoined ? Colors.grey[300] : _getButtonColor(),
                    foregroundColor:
                        _isJoined ? Colors.grey[700] : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    _isJoined ? 'Joined' : 'Join Circle',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
