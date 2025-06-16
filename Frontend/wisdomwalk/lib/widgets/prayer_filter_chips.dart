import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/prayer_provider.dart';

class PrayerFilterChips extends StatelessWidget {
  const PrayerFilterChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final currentFilter = prayerProvider.filter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            'All Prayers',
            'all',
            currentFilter == 'all',
            Icons.volunteer_activism_outlined,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'My Prayers',
            'mine',
            currentFilter == 'mine',
            Icons.person_outline,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Friends',
            'friends',
            currentFilter == 'friends',
            Icons.people_outline,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            'Recent',
            'recent',
            currentFilter == 'recent',
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
    IconData icon,
  ) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          Provider.of<PrayerProvider>(context, listen: false).setFilter(value);
        }
      },
      backgroundColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).primaryColor,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
      ),
    );
  }
}
