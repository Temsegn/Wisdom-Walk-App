import 'dart:io';

class ChatModel {
  final String id;
  final String userId;
  final String name;
  final String status;
  String lastMessage;
  String time;
  final bool isOnline;
  int unreadCount;
  List<MessageModel> messages;

  ChatModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.status,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.unreadCount,
    required this.messages,
  });

  ChatModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? status,
    String? lastMessage,
    String? time,
    bool? isOnline,
    int? unreadCount,
    List<MessageModel>? messages,
  }) {
    return ChatModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      status: status ?? this.status,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String time;
  final bool isMe;
  final String? filePath; // New field for file path or URL
  final String? fileType; // New field for file type (e.g., image, video, pdf)

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.time,
    required this.isMe,
    this.filePath,
    this.fileType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      content: json['content'],
      time: json['time'],
      isMe: json['isMe'],
      filePath: json['filePath'],
      fileType: json['fileType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'content': content,
      'time': time,
      'isMe': isMe,
      'filePath': filePath,
      'fileType': fileType,
    };
  }
}