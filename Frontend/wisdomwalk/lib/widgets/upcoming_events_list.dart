import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wisdomwalk/providers/event_provider.dart';
import 'package:wisdomwalk/models/event_model.dart';

class UpcomingEventsList extends StatelessWidget {
  const UpcomingEventsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (eventProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${eventProvider.error!}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    eventProvider.fetchEvents();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final events = eventProvider.events;

        if (events.isEmpty) {
          return const Center(child: Text('No upcoming events.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(context, event);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final date = event.dateTime;
    final title = event.title;
    final platform = event.platform;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8E2DB)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.event, color: Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(date)} • ${timeFormat.format(date)} • $platform',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _showEventDetails(context, event);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, EventModel event) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(dateFormat.format(event.dateTime)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(timeFormat.format(event.dateTime)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.videocam, size: 16),
                  const SizedBox(width: 8),
                  Text(event.platform),
                ],
              ),
              const SizedBox(height: 16),
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Event added to calendar')),
                        );
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Add to Calendar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You\'ve joined the event!')),
                        );
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Join Event'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
