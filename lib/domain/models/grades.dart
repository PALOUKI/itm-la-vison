import 'package:vision/domain/models/common_models.dart';

class GradesResponse {
  final AcademicYear currentYear;
  final List<Grade> grades;

  GradesResponse({
    required this.currentYear,
    required this.grades,
  });

  factory GradesResponse.fromJson(Map<String, dynamic> json) {
    final gradesList = json['grades'] as List<dynamic>? ?? [];
    return GradesResponse(
      currentYear: AcademicYear.fromJson(json['current_year'] as Map<String, dynamic>),
      grades: gradesList.map((e) => Grade.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Factory method to handle API response that returns a direct list of grades
  factory GradesResponse.fromJsonList(List<dynamic> jsonList) {
    final grades = jsonList.map((e) => Grade.fromJson(e as Map<String, dynamic>)).toList();

    // Extract the current academic year from the first grade's exam period if available
    AcademicYear? currentYear;
    if (grades.isNotEmpty && grades.first.exam.period.isCurrent) {
      // Use the period's info to create an AcademicYear
      // Since we don't have the exact academic year info from the API, we create a dummy one
      currentYear = AcademicYear(
        id: 0,
        uuid: '',
        name: 'Current Year',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        isCurrent: true,
      );
    } else {
      // Create a default academic year
      currentYear = AcademicYear(
        id: 0,
        uuid: '',
        name: 'Current Year',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        isCurrent: true,
      );
    }

    return GradesResponse(
      currentYear: currentYear,
      grades: grades,
    );
  }
}

class Grade {
  final int id;
  final String uuid;
  final double score;
  final bool isAbsent;
  final DateTime createdAt;
  final Subject subject;
  final Exam exam;

  Grade({
    required this.id,
    required this.uuid,
    required this.score,
    required this.isAbsent,
    required this.createdAt,
    required this.subject,
    required this.exam,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      score: double.tryParse(json['score'].toString()) ?? 0,
      isAbsent: json['is_absent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      subject: Subject.fromJson(json['subject'] as Map<String, dynamic>),
      exam: Exam.fromJson(json['exam'] as Map<String, dynamic>),
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
      code: json['code'] as String,
      coefficient: json['coefficient'] as int? ?? 1,
    );
  }
}

