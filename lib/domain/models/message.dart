import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/user.dart';

class MessagingResponse {
  final List<Message> sent;
  final List<Message> received;
  final List<TeacherSubject> teachers;

  MessagingResponse({
    required this.sent,
    required this.received,
    required this.teachers,
  });

  factory MessagingResponse.fromJson(Map<String, dynamic> json) {
    final sentList = json['sent'] as List<dynamic>? ?? [];
    final receivedList = json['received'] as List<dynamic>? ?? [];
    final teachersList = json['teachers'] as List<dynamic>? ?? [];

    return MessagingResponse(
      sent: sentList.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList(),
      received: receivedList.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList(),
      teachers: teachersList.map((e) => TeacherSubject.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Factory method to handle API response that returns different structures
  factory MessagingResponse.fromJsonDynamic(dynamic data) {
    // If data is a Map with sent/received/teachers structure
    if (data is Map<String, dynamic>) {
      return MessagingResponse.fromJson(data);
    }

    // If data is a List, create an empty response
    if (data is List<dynamic>) {
      return MessagingResponse(
        sent: [],
        received: [],
        teachers: [],
      );
    }

    // Default empty response
    return MessagingResponse(
      sent: [],
      received: [],
      teachers: [],
    );
  }
}

class Message {
  final int id;
  final String uuid;
  final String subject;
  final String body;
  final String validationStatus;
  final DateTime createdAt;
  final User? sender;
  final User? receiver;

  Message({
    required this.id,
    required this.uuid,
    required this.subject,
    required this.body,
    required this.validationStatus,
    required this.createdAt,
    this.sender,
    this.receiver,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      subject: json['subject'] as String? ?? 'Sans sujet',
      body: json['body'] as String? ?? '',
      validationStatus: json['validation_status'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['sender'] != null ? User.fromJson(json['sender'] as Map<String, dynamic>) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver'] as Map<String, dynamic>) : null,
    );
  }
}

class TeacherSubject {
  final Teacher teacher;
  final Subject subject;
  final Child student;
  final Class classData;

  TeacherSubject({
    required this.teacher,
    required this.subject,
    required this.student,
    required this.classData,
  });

  factory TeacherSubject.fromJson(Map<String, dynamic> json) {
    return TeacherSubject(
      teacher: Teacher.fromJson(json['teacher'] as Map<String, dynamic>),
      subject: Subject.fromJson(json['subject'] as Map<String, dynamic>),
      student: Child.fromJson(json['student'] as Map<String, dynamic>),
      classData: Class.fromJson(json['class'] as Map<String, dynamic>),
    );
  }
}

class Teacher {
  final int id;
  final String uuid;
  final String fullName;
  final User? user;

  Teacher({
    required this.id,
    required this.uuid,
    required this.fullName,
    this.user,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      fullName: json['full_name'] as String,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

class Subject {
  final int id;
  final String uuid;
  final String name;
  final String code;
  final int coefficient;

  Subject({
    required this.id,
    required this.uuid,
    required this.name,
    required this.code,
    required this.coefficient,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      code: json['code'] as String? ?? '',
      coefficient: json['coefficient'] as int? ?? 1,
    );
  }
}
