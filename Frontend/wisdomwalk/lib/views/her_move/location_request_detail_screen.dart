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
  final TextEditingController _responseController = TextEditingController();

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
  void dispose() {
    _responseController.dispose();
    super.dispose();
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
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequestHeader(context, request),
                          const SizedBox(height: 16),
                          _buildRequestDetails(context, request),
                          const SizedBox(height: 24),
                          _buildResponsesSection(context, request),
                        ],
                      ),
                    ),
                  ),
                  if (request.userId != authProvider.currentUser?.id)
                    _buildResponseInput(context, herMoveProvider, authProvider),
                ],
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
                request.userName,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Posted ${_getTimeAgo(request.createdAt)}',
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
    final moveDate = DateFormat('MMMM d, yyyy').format(request.moveDate);

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
                '${request.city}, ${request.country}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
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
            request.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsesSection(
    BuildContext context,
    LocationRequestModel request,
  ) {
    if (request.responses.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Icon(
              Icons.comment_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No responses yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Responses', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: request.responses.length,
          itemBuilder: (context, index) {
            final response = request.responses[index];
            return _buildResponseItem(context, response);
          },
        ),
      ],
    );
  }

  Widget _buildResponseItem(BuildContext context, LocationResponse response) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E2DB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildResponseAvatar(context, response),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response.userName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(response.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              response.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (response.contactInfo.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response.contactInfo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseAvatar(BuildContext context, LocationResponse response) {
    if (response.userAvatar == null) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(response.userAvatar!),
      );
    }
  }

  Widget _buildResponseInput(
    BuildContext context,
    HerMoveProvider herMoveProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
          ),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _responseController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your local knowledge or offer to help...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _submitResponse(herMoveProvider, authProvider);
              },
              child: const Text('Send Response'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitResponse(
    HerMoveProvider herMoveProvider,
    AuthProvider authProvider,
  ) {
    final response = _responseController.text.trim();
    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your response'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = authProvider.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to respond'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    herMoveProvider
        .addLocationResponse(
          requestId: widget.requestId,
          userId: user.id,
          userName: user.fullName,
          userAvatar: user.avatarUrl,
          content: response,
        )
        .then((success) {
          if (success) {
            _responseController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Response sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  herMoveProvider.error ?? 'Failed to send response',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
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
