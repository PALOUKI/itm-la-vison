import 'package:vision/domain/models/common_models.dart';

class BulletinsResponse {
  final AcademicYear currentYear;
  final Period activePeriod;
  final bool bulletinAccessEnabled;
  final List<BulletinChild> children;
  final List<MiniBulletin> miniBulletins;

  BulletinsResponse({
    required this.currentYear,
    required this.activePeriod,
    required this.bulletinAccessEnabled,
    required this.children,
    required this.miniBulletins,
  });

  factory BulletinsResponse.fromJson(Map<String, dynamic> json) {
    return BulletinsResponse(
      currentYear: AcademicYear.fromJson(json['current_year'] as Map<String, dynamic>),
      activePeriod: Period.fromJson(json['active_period'] as Map<String, dynamic>),
      bulletinAccessEnabled: json['bulletin_access_enabled'] as bool? ?? false,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => BulletinChild.fromJson(e as Map<String, dynamic>))
          .toList(),
      miniBulletins: (json['mini_bulletins'] as List<dynamic>? ?? [])
          .map((e) => MiniBulletin.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BulletinChild {
  final int id;
  final String uuid;
  final String matricule;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? displayPhoto;

  BulletinChild({
    required this.id,
    required this.uuid,
    required this.matricule,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.displayPhoto,
  });

  factory BulletinChild.fromJson(Map<String, dynamic> json) {
    return BulletinChild(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      matricule: json['matricule'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String,
      displayPhoto: json['display_photo'] as String?,
    );
  }
}

class MiniBulletin {
  final int studentId;
  final List<Exam> exams;

  MiniBulletin({
    required this.studentId,
    required this.exams,
  });

  factory MiniBulletin.fromJson(Map<String, dynamic> json) {
    return MiniBulletin(
      studentId: json['student_id'] as int,
      exams: (json['exams'] as List<dynamic>? ?? [])
          .map((e) => Exam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

