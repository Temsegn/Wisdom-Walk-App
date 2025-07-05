import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/location_request_model.dart';
import 'package:intl/intl.dart';

class LocationRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const LocationRequestDetailScreen({Key? key, required this.requestId})
    : super(key: key);

  @override
  State<LocationRequestDetailScreen> createState() =>
      _LocationRequestDetailScreenState();
}

class _LocationRequestDetailScreenState
    extends State<LocationRequestDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HerMoveProvider>(
        context,
        listen: false,
      ).fetchRequestDetails(widget.requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final herMoveProvider = Provider.of<HerMoveProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final request = herMoveProvider.selectedRequest;
    final isLoading = herMoveProvider.isLoading;
    final error = herMoveProvider.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Travel Request')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading request details',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        herMoveProvider.fetchRequestDetails(widget.requestId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : request == null
              ? const Center(child: Text('Request not found'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequestHeader(context, request),
                    const SizedBox(height: 16),
                    _buildRequestDetails(context, request),
                  ],
                ),
              ),
    );
  }

  Widget _buildRequestHeader(
    BuildContext context,
    LocationRequestModel request,
  ) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Row(
      children: [
        _buildAvatar(context, request),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.firstName ?? 'Unknown',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Posted ${_getTimeAgo(request.createdAt ?? DateTime.now())}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, LocationRequestModel request) {
    if (request.userAvatar == null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(request.userAvatar!),
      );
    }
  }

  Widget _buildRequestDetails(
    BuildContext context,
    LocationRequestModel request,
  ) {
    final moveDate =
        request.moveDate != null
            ? DateFormat('MMMM d, yyyy').format(request.moveDate!)
            : 'Unknown Date';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${request.toCity ?? 'Unknown'}, ${request.toCountry ?? 'Unknown'}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          if (request.fromCity != null && request.fromCountry != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'From: ${request.fromCity}, ${request.fromCountry}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Moving on $moveDate',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request.description ?? 'No description provided',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
