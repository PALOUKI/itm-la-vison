import 'package:vision/domain/models/common_models.dart';

class AttendanceResponse {
  final AcademicYear currentYear;
  final PeriodTimeRange period;
  final AttendanceStats stats;
  final List<Attendance> attendances;

  AttendanceResponse({
    required this.currentYear,
    required this.period,
    required this.stats,
    required this.attendances,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    final attendancesList = json['attendances'] as List<dynamic>? ?? [];
    return AttendanceResponse(
      currentYear: AcademicYear.fromJson(json['current_year'] as Map<String, dynamic>),
      period: PeriodTimeRange.fromJson(json['period'] as Map<String, dynamic>),
      stats: AttendanceStats.fromJson(json['stats'] as Map<String, dynamic>),
      attendances: attendancesList
          .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Factory method to handle API response that returns a direct list of attendances
  factory AttendanceResponse.fromJsonList(List<dynamic> jsonList) {
    final attendances = jsonList.map((e) => Attendance.fromJson(e as Map<String, dynamic>)).toList();

    // Create default values for fields not provided by the API
    final now = DateTime.now();
    final currentYear = AcademicYear(
      id: 0,
      uuid: '',
      name: 'Current Year',
      startDate: DateTime(now.year, 1, 1),
      endDate: DateTime(now.year, 12, 31),
      isCurrent: true,
    );

    final period = PeriodTimeRange(
      start: now.toString(),
      end: now.toString(),
    );

    final presentCount = attendances.where((a) => a.status == 'present').length;
    final absentCount = attendances.where((a) => a.status == 'absent').length;
    final lateCount = attendances.where((a) => a.status == 'late').length;
    final excusedCount = attendances.where((a) => a.status == 'excused').length;

    final stats = AttendanceStats(
      total: attendances.length,
      present: presentCount,
      absent: absentCount,
      late: lateCount,
      excused: excusedCount,
    );

    return AttendanceResponse(
      currentYear: currentYear,
      period: period,
      stats: stats,
      attendances: attendances,
    );
  }
}

class PeriodTimeRange {
  final String start;
  final String end;

  PeriodTimeRange({
    required this.start,
    required this.end,
  });

  factory PeriodTimeRange.fromJson(Map<String, dynamic> json) {
    return PeriodTimeRange(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }
}

class AttendanceStats {
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;

  AttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      total: json['total'] as int? ?? 0,
      present: json['present'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
      late: json['late'] as int? ?? 0,
      excused: json['excused'] as int? ?? 0,
    );
  }

  double getAttendancePercentage() {
    if (total == 0) return 100;
    return (present + excused) / total * 100;
  }
}

class Attendance {
  final int id;
  final String uuid;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status; // present, absent, late, excused
  final String? arrivalTime;
  final String? reason;
  final bool justified;
  final Subject? subject;
  final Teacher? teacher;
  final Schedule? schedule;

  Attendance({
    required this.id,
    required this.uuid,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.arrivalTime,
    this.reason,
    required this.justified,
    this.subject,
    this.teacher,
    this.schedule,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      status: json['status'] as String,
      arrivalTime: json['arrival_time'] as String?,
      reason: json['reason'] as String?,
      justified: json['justified'] as bool? ?? false,
      subject: json['subject'] != null ? Subject.fromJson(json['subject'] as Map<String, dynamic>) : null,
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher'] as Map<String, dynamic>) : null,
      schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule'] as Map<String, dynamic>) : null,
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

class Teacher {
  final int id;
  final String uuid;
  final String fullName;

  Teacher({
    required this.id,
    required this.uuid,
    required this.fullName,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      fullName: json['full_name'] as String,
    );
  }
}

class Schedule {
  final int id;
  final String uuid;
  final String dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;
  final String? room;
  final Teacher? teacher;

  Schedule({
    required this.id,
    required this.uuid,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.teacher,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      dayOfWeek: json['day_of_week'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      room: json['room'] as String?,
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher'] as Map<String, dynamic>) : null,
    );
  }
}
