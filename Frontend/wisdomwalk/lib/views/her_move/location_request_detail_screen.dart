// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:wisdomwalk/providers/her_move_provider.dart';
// import 'package:wisdomwalk/providers/auth_provider.dart';
// import 'package:wisdomwalk/models/location_request_model.dart';
// import 'package:intl/intl.dart';

// class LocationRequestDetailScreen extends StatefulWidget {
//   final String requestId;

//   const LocationRequestDetailScreen({Key? key, required this.requestId})
//     : super(key: key);

//   @override
//   State<LocationRequestDetailScreen> createState() =>
//       _LocationRequestDetailScreenState();
// }

// class _LocationRequestDetailScreenState
//     extends State<LocationRequestDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<HerMoveProvider>(
//         context,
//         listen: false,
//       ).fetchRequestDetails(widget.requestId);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final herMoveProvider = Provider.of<HerMoveProvider>(context);
//     final authProvider = Provider.of<AuthProvider>(context);
//     final request = herMoveProvider.selectedRequest;
//     final isLoading = herMoveProvider.isLoading;
//     final error = herMoveProvider.error;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Travel Request')),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : error != null
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Error loading request details',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         herMoveProvider.fetchRequestDetails(widget.requestId);
//                       },
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               )
//               : request == null
//               ? const Center(child: Text('Request not found'))
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildRequestHeader(context, request),
//                     const SizedBox(height: 16),
//                     _buildRequestDetails(context, request),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildRequestHeader(
//     BuildContext context,
//     LocationRequestModel request,
//   ) {
//     final dateFormat = DateFormat('MMMM d, yyyy');

//     return Row(
//       children: [
//         _buildAvatar(context, request),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 request.firstName ?? 'Unknown',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 'Posted ${_getTimeAgo(request.createdAt ?? DateTime.now())}',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAvatar(BuildContext context, LocationRequestModel request) {
//     if (request.userAvatar == null) {
//       return Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Center(
//           child: Icon(
//             Icons.person,
//             color: Theme.of(context).primaryColor,
//             size: 24,
//           ),
//         ),
//       );
//     } else {
//       return CircleAvatar(
//         radius: 20,
//         backgroundImage: NetworkImage(request.userAvatar!),
//       );
//     }
//   }

//   Widget _buildRequestDetails(
//     BuildContext context,
//     LocationRequestModel request,
//   ) {
//     final moveDate =
//         request.moveDate != null
//             ? DateFormat('MMMM d, yyyy').format(request.moveDate!)
//             : 'Unknown Date';

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on,
//                 color: Theme.of(context).primaryColor,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 '${request.toCity ?? 'Unknown'}, ${request.toCountry ?? 'Unknown'}',
//                 style: Theme.of(context).textTheme.headlineMedium,
//               ),
//             ],
//           ),
//           if (request.fromCity != null && request.fromCountry != null) ...[
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_city,
//                   color: Theme.of(context).primaryColor,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'From: ${request.fromCity}, ${request.fromCountry}',
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ],
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(
//                 Icons.calendar_today,
//                 color: Theme.of(context).primaryColor,
//                 size: 16,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Moving on $moveDate',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             request.description ?? 'No description provided',
//             style: Theme.of(context).textTheme.bodyLarge,
//           ),
//         ],
//       ),
//     );
//   }

//   String _getTimeAgo(DateTime dateTime) {
//     final difference = DateTime.now().difference(dateTime);

//     if (difference.inDays > 7) {
//       return DateFormat('MMM d, yyyy').format(dateTime);
//     } else if (difference.inDays > 0) {
//       return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdomwalk/providers/her_move_provider.dart';
import 'package:wisdomwalk/providers/auth_provider.dart';
import 'package:wisdomwalk/models/location_request_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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

  void _showOfferHelpDialog(
    BuildContext context,
    LocationRequestModel request,
    String userId,
  ) {
    final helpMessageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Offer Help',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Provide details on how you can assist.',
                  style: TextStyle(color: Color(0xFF636E72)),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[50]!, Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF74B9FF).withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: helpMessageController,
                    decoration: const InputDecoration(
                      labelText: 'Assistance Details',
                      hintText: 'E.g., I can provide directions or travel tips',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF636E72)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1DA1F2), Color(0xFF0984E3)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final message = helpMessageController.text.trim();
                  if (message.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Please provide details for your offer',
                        ),
                        backgroundColor: const Color(0xFFD63031),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    return;
                  }
                  final herMoveProvider = Provider.of<HerMoveProvider>(
                    context,
                    listen: false,
                  );
                  final success = await herMoveProvider.offerHelp(
                    requestId: request.id ?? '',
                    userId: userId,
                    message: message,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Help offered successfully! 🤝'
                              : 'Failed to offer help',
                        ),
                        backgroundColor:
                            success
                                ? const Color(0xFF1DA1F2)
                                : const Color(0xFFD63031),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Send Offer',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final herMoveProvider = Provider.of<HerMoveProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final request = herMoveProvider.selectedRequest;
    final isLoading = herMoveProvider.isLoading;
    final error = herMoveProvider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Travel Request',
          style: TextStyle(
            color: Color(0xFF14171A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1DA1F2)),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading request details: $error',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF14171A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1DA1F2), Color(0xFF0984E3)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          herMoveProvider.fetchRequestDetails(widget.requestId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : request == null
              ? const Center(
                child: Text(
                  'Request not found',
                  style: TextStyle(color: Color(0xFF657786)),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRequestHeader(context, request, authProvider),
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
    AuthProvider authProvider,
  ) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Stack(
      children: [
        Row(
          children: [
            _buildAvatar(context, request),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.authorName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF14171A),
                    ),
                  ),
                  Text(
                    'Posted ${_getTimeAgo(request.createdAt ?? DateTime.now())}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF657786),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.handshake_outlined,
                color: Color(0xFF1DA1F2),
                size: 20,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                if (!authProvider.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please log in to offer help'),
                      backgroundColor: const Color(0xFFD63031),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: 'Login',
                        textColor: Colors.white,
                        onPressed: () {
                          context.push('/login');
                        },
                      ),
                    ),
                  );
                  return;
                }
                _showOfferHelpDialog(
                  context,
                  request,
                  authProvider.currentUser!.id,
                );
              },
            ),
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
          gradient: LinearGradient(
            colors: [Color(0xFF1DA1F2), Color(0xFF0984E3)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white, size: 24),
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
                request.toLocation,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF14171A),
                ),
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
                  'From: ${request.fromLocation}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF657786),
                  ),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14171A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request.description ?? 'No description provided',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF657786),
              height: 1.4,
            ),
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
