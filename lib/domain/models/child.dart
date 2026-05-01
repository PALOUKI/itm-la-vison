import 'package:vision/domain/models/user.dart';

class Child {
  final int id;
  final String uuid;
  final String matricule;
  final String firstName;
  final String lastName;
  final String fullName;
  final String gender;
  final DateTime birthDate;
  final String birthPlace;
  final String nationality;
  final String? photo;
  final String? displayPhoto;
  final String status;
  final Enrollment? currentEnrollment;
  final List<Grade> grades;
  final User? user;

  Child({
    required this.id,
    required this.uuid,
    required this.matricule,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.birthDate,
    required this.birthPlace,
    required this.nationality,
    this.photo,
    this.displayPhoto,
    required this.status,
    this.currentEnrollment,
    required this.grades,
    this.user,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    final enrollments = json['enrollments'] as List<dynamic>? ?? [];
    Enrollment? currentEnrollment;
    if (enrollments.isNotEmpty) {
      currentEnrollment = Enrollment.fromJson(enrollments[0] as Map<String, dynamic>);
    }

    final gradesList = json['grades'] as List<dynamic>? ?? [];

    return Child(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      matricule: json['matricule'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date'].toString()) ?? DateTime.now() : DateTime.now(),
      birthPlace: json['birth_place'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      photo: json['photo'] as String?,
      displayPhoto: json['display_photo'] as String?,
      status: json['status'] as String? ?? '',
      currentEnrollment: currentEnrollment,
      grades: gradesList
          .map((e) => Grade.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'matricule': matricule,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'gender': gender,
      'birth_date': birthDate.toIso8601String(),
      'birth_place': birthPlace,
      'nationality': nationality,
      'photo': photo,
      'display_photo': displayPhoto,
      'status': status,
      'user': user?.toJson(),
    };
  }
}



class Enrollment {
  final int id;
  final String uuid;
  final String status;
  final DateTime enrollmentDate;
  final String? notes;
  final Class classData;

  Enrollment({
    required this.id,
    required this.uuid,
    required this.status,
    required this.enrollmentDate,
    this.notes,
    required this.classData,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      status: json['status'] as String? ?? '',
      enrollmentDate: json['enrollment_date'] != null ? DateTime.tryParse(json['enrollment_date'].toString()) ?? DateTime.now() : DateTime.now(),
      notes: json['notes'] as String?,
      classData: Class.fromJson(json['class'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class Class {
  final int id;
  final String uuid;
  final String name;
  final Level? level;
  final Series? series;
  final String establishmentType;

  Class({
    required this.id,
    required this.uuid,
    required this.name,
    this.level,
    this.series,
    required this.establishmentType,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      level: json['level'] != null ? Level.fromJson(json['level'] as Map<String, dynamic>) : null,
      series: json['series'] != null ? Series.fromJson(json['series'] as Map<String, dynamic>) : null,
      establishmentType: json['establishment_type'] as String? ?? '',
    );
  }
}

class Level {
  final int id;
  final String uuid;
  final String name;

  Level({
    required this.id,
    required this.uuid,
    required this.name,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class Series {
  final int id;
  final String uuid;
  final String name;

  Series({
    required this.id,
    required this.uuid,
    required this.name,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class Grade {
  final int id;
  final String uuid;
  final dynamic score;
  final bool isAbsent;
  final DateTime createdAt;

  Grade({
    required this.id,
    required this.uuid,
    required this.score,
    required this.isAbsent,
    required this.createdAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      score: json['score'],
      isAbsent: json['is_absent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
