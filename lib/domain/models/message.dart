import 'package:vision/domain/models/user.dart';

class Message {
  final int id;
  final String uuid;
  final String subject;
  final String body;
  final User? sender;
  final User? receiver;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.uuid,
    required this.subject,
    required this.body,
    this.sender,
    this.receiver,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      body: json['body'] as String? ?? '',
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : DateTime.now(),
      isRead: json['read_at'] != null,
    );
  }
}

class Teacher {
  final int id;
  final String uuid;
  final String fullName;
  final String? photo;

  Teacher({
    required this.id,
    required this.uuid,
    required this.fullName,
    this.photo,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? 'Professeur',
      photo: json['photo'] as String?,
    );
  }
}

class MessagingResponse {
  final List<Message> sent;
  final List<Message> received;
  final List<Teacher> teachers;

  MessagingResponse({
    required this.sent,
    required this.received,
    required this.teachers,
  });

  factory MessagingResponse.fromJson(Map<String, dynamic> json) {
    final sentList = (json['sent'] as List<dynamic>? ?? [])
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
    final receivedList = (json['received'] as List<dynamic>? ?? [])
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
    final teachersList = (json['teachers'] as List<dynamic>? ?? [])
        .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
        .toList();

    return MessagingResponse(
      sent: sentList,
      received: receivedList,
      teachers: teachersList,
    );
  }
}

class AppNotification {
  final int id;
  final String? uuid;
  final String type;
  final String title;
  final String message;
  final dynamic data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    this.uuid,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      uuid: json['uuid'] as String?,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'],
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}

class NotificationsResponse {
  final int unreadCount;
  final List<AppNotification> notifications;
  final int currentPage;
  final int lastPage;
  final int total;

  NotificationsResponse({
    required this.unreadCount,
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final notifsData = data['notifications'] as Map<String, dynamic>;
    final list = notifsData['data'] as List<dynamic>;

    return NotificationsResponse(
      unreadCount: data['unread_count'] as int? ?? 0,
      notifications: list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: notifsData['current_page'] as int? ?? 1,
      lastPage: notifsData['last_page'] as int? ?? 1,
      total: notifsData['total'] as int? ?? 0,
    );
  }
}
