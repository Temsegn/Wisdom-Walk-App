import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickAccessButtons extends StatelessWidget {
  const QuickAccessButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Access', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessButton(
                context,
                icon: Icons.volunteer_activism,
                title: 'Prayer Wall',
                color: Theme.of(context).colorScheme.secondary,
                onTap: () {
                  // Navigate to Prayer Wall tab
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessButton(
                context,
                icon: Icons.people,
                title: 'Wisdom Circles',
                color: Theme.of(context).colorScheme.tertiary,
                onTap: () {
                  // Navigate to Wisdom Circles tab
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessButton(
                context,
                icon: Icons.mail,
                title: 'Anonymous Share',
                color: const Color(0xFFFDF6F0),
                onTap: () {
                  // Navigate to Anonymous Share tab
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E2DB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
