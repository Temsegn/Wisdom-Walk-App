import 'package:wisdomwalk/models/notification_model.dart';

class NotificationService {
  // Mock notifications data
  static List<NotificationModel> mockNotifications = [
    NotificationModel(
      id: '1',
      userId: 'current_user',
      title: 'New Response to Your Move',
      message: 'Maria Garcia offered help for your move to Austin',
      type: 'response',
      relatedId: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: '2',
      userId: 'current_user',
      title: 'Someone is Moving to Your City',
      message: 'Jennifer Lee is moving to Denver and might need help',
      type: 'new_request',
      relatedId: '2',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: '3',
      userId: 'current_user',
      title: 'Welcome to Her Move!',
      message: 'Start connecting with sisters around the world',
      type: 'system',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<NotificationModel>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockNotifications.where((n) => n.userId == userId).toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      mockNotifications[index] = mockNotifications[index].copyWith(
        isRead: true,
      );
    }
  }

  Future<void> markAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < mockNotifications.length; i++) {
      if (mockNotifications[i].userId == userId) {
        mockNotifications[i] = mockNotifications[i].copyWith(isRead: true);
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    mockNotifications.removeWhere((n) => n.id == notificationId);
  }

  Future<void> addNotification(NotificationModel notification) async {
    await Future.delayed(const Duration(milliseconds: 200));
    mockNotifications.insert(0, notification);
  }

  // Create notification when someone responds to a request
  static Future<void> createResponseNotification({
    required String requestOwnerId,
    required String responderName,
    required String requestId,
    required String city,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: requestOwnerId,
      title: 'New Response to Your Move',
      message: '$responderName offered help for your move to $city',
      type: 'response',
      relatedId: requestId,
      createdAt: DateTime.now(),
    );

    mockNotifications.insert(0, notification);
  }

  // Create notification for new requests in user's area
  static Future<void> createNewRequestNotification({
    required String userId,
    required String requesterName,
    required String requestId,
    required String city,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: 'Someone is Moving to Your Area',
      message: '$requesterName is moving to $city and might need help',
      type: 'new_request',
      relatedId: requestId,
      createdAt: DateTime.now(),
    );

    mockNotifications.insert(0, notification);
  }
}
