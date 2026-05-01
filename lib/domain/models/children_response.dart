import 'package:vision/domain/models/child.dart';

class ChildrenResponse {
  final AcademicYear currentYear;
  final List<Child> children;

  ChildrenResponse({
    required this.currentYear,
    required this.children,
  });

  factory ChildrenResponse.fromJson(Map<String, dynamic> json) {
    final childrenList = json['children'] as List<dynamic>? ?? [];

    return ChildrenResponse(
      currentYear:
          AcademicYear.fromJson(json['current_year'] as Map<String, dynamic>),
      children: childrenList
          .map((e) => Child.fromJson(e as Map<String, dynamic>))
          .toList(),
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

