/// Modèles partagés utilisés à travers l'application
/// Centralise les classes qui auraient pu être dupliquées

class Period {
  final int id;
  final String uuid;
  final String name;
  final int number;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  Period({
    required this.id,
    required this.uuid,
    required this.name,
    required this.number,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      number: json['number'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}

class AcademicYear {
  final int id;
  final String uuid;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;

  AcademicYear({
    required this.id,
    required this.uuid,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
  });

  factory AcademicYear.fromJson(Map<String, dynamic> json) {
    return AcademicYear(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}

class Exam {
  final int id;
  final String uuid;
  final String title;
  final String description;
  final DateTime examDate;
  final DateTime endDate;
  final String status;
  final bool isPublished;
  final ExamType examType;
  final Period period;

  Exam({
    required this.id,
    required this.uuid,
    required this.title,
    required this.description,
    required this.examDate,
    required this.endDate,
    required this.status,
    required this.isPublished,
    required this.examType,
    required this.period,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      examDate: DateTime.parse(json['exam_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      isPublished: json['is_published'] as bool? ?? false,
      examType: ExamType.fromJson(json['exam_type'] as Map<String, dynamic>),
      period: Period.fromJson(json['period'] as Map<String, dynamic>),
    );
  }
}

class ExamType {
  final int id;
  final String uuid;
  final String name;
  final String category;

  ExamType({
    required this.id,
    required this.uuid,
    required this.name,
    required this.category,
  });

  factory ExamType.fromJson(Map<String, dynamic> json) {
    return ExamType(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }
}

