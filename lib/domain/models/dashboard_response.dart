import 'package:vision/domain/models/children_response.dart';

class DashboardResponse {
  final AcademicYear? currentYear;
  final int childrenCount;
  final int pendingEnrollments;
  final int approvedEnrollments;

  DashboardResponse({
    this.currentYear,
    required this.childrenCount,
    required this.pendingEnrollments,
    required this.approvedEnrollments,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>?;
    return DashboardResponse(
      currentYear: json['current_year'] != null
          ? AcademicYear.fromJson(json['current_year'] as Map<String, dynamic>)
          : null,
      childrenCount: stats?['children_count'] as int? ?? 0,
      pendingEnrollments: stats?['pending_enrollments'] as int? ?? 0,
      approvedEnrollments: stats?['active_enrollments'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (currentYear != null) 'current_year': {
        'id': currentYear!.id,
        'uuid': currentYear!.uuid,
        'name': currentYear!.name,
        'start_date': currentYear!.startDate.toIso8601String(),
        'end_date': currentYear!.endDate.toIso8601String(),
        'is_current': currentYear!.isCurrent,
      },
      'children_count': childrenCount,
      'pending_enrollments': pendingEnrollments,
      'approved_enrollments': approvedEnrollments,
    };
  }
}
