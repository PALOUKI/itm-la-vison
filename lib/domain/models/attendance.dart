class AttendanceResponse {
  final StudentSummary student;
  final AttendanceStats overallStats;
  final List<MonthAttendance> byMonth;

  AttendanceResponse({
    required this.student,
    required this.overallStats,
    required this.byMonth,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final monthList = data['by_month'] as List<dynamic>? ?? [];
    
    final months = monthList.map((e) => MonthAttendance.fromJson(e as Map<String, dynamic>)).toList();
    
    // Recalculer les statistiques globales pour exclure les absences justifiées (avec raison)
    int totalAbsences = 0;
    int totalLate = 0;
    int totalPresent = 0;
    int totalExcused = 0;
    int totalRecords = 0;

    for (var month in months) {
      for (var record in month.records) {
        totalRecords++;
        if (record.isAbsent) {
          if (!record.justified) {
            totalAbsences++;
          } else {
            totalExcused++;
          }
        } else if (record.isLate) {
          totalLate++;
        } else if (record.isPresent) {
          totalPresent++;
        } else if (record.isExcused) {
          totalExcused++;
        }
      }
    }

    final overallStats = AttendanceStats(
      total: totalRecords,
      present: totalPresent,
      absent: totalAbsences,
      late: totalLate,
      excused: totalExcused,
    );
    
    return AttendanceResponse(
      student: StudentSummary.fromJson(data['student'] as Map<String, dynamic>),
      overallStats: overallStats,
      byMonth: months,
    );
  }
}

class StudentSummary {
  final int id;
  final String matricule;
  final String fullName;

  StudentSummary({
    required this.id,
    required this.matricule,
    required this.fullName,
  });

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    return StudentSummary(
      id: json['id'] as int,
      matricule: json['matricule'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
    );
  }
}

class MonthAttendance {
  final String month;
  final String monthLabel;
  final AttendanceStats stats;
  final List<Attendance> records;

  MonthAttendance({
    required this.month,
    required this.monthLabel,
    required this.stats,
    required this.records,
  });

  factory MonthAttendance.fromJson(Map<String, dynamic> json) {
    final recordsList = json['records'] as List<dynamic>? ?? [];
    final records = recordsList.map((e) => Attendance.fromJson(e as Map<String, dynamic>)).toList();
    
    // Recalculer les stats du mois pour exclure les absences justifiées
    int monthAbsences = 0;
    int monthLate = 0;
    int monthPresent = 0;
    int monthExcused = 0;
    int monthTotal = records.length;

    for (var record in records) {
      if (record.isAbsent) {
        if (!record.justified) {
          monthAbsences++;
        } else {
          monthExcused++;
        }
      } else if (record.isLate) {
        monthLate++;
      } else if (record.isPresent) {
        monthPresent++;
      } else if (record.isExcused) {
        monthExcused++;
      }
    }

    final stats = AttendanceStats(
      total: monthTotal,
      present: monthPresent,
      absent: monthAbsences,
      late: monthLate,
      excused: monthExcused,
    );

    return MonthAttendance(
      month: json['month'] as String,
      monthLabel: json['month_label'] as String,
      stats: stats,
      records: records,
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
      total: json['total_records'] ?? json['total_count'] ?? 0,
      present: json['present_count'] ?? 0,
      absent: json['absent_count'] ?? 0,
      late: json['late_count'] ?? 0,
      excused: json['excused_count'] ?? 0,
    );
  }

  double getAttendancePercentage() {
    if (total == 0) return 100;
    return (present + excused) / total * 100;
  }
}

class Attendance {
  final int id;
  final DateTime date;
  final String dayName;
  final String startTime;
  final String endTime;
  final String status;
  final bool isPresent;
  final bool isAbsent;
  final bool isLate;
  final bool isExcused;
  final String? reason;
  final Subject? subject;
  final Teacher? teacher;

  Attendance({
    required this.id,
    required this.date,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.isPresent,
    required this.isAbsent,
    required this.isLate,
    required this.isExcused,
    this.reason,
    this.subject,
    this.teacher,
  });

  bool get justified => isExcused || (reason != null && reason!.trim().isNotEmpty);

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      dayName: json['day_name'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      status: json['status'] as String,
      isPresent: json['is_present'] as bool? ?? false,
      isAbsent: json['is_absent'] as bool? ?? false,
      isLate: json['is_late'] as bool? ?? false,
      isExcused: json['is_excused'] as bool? ?? false,
      reason: json['reason'] as String?,
      subject: json['subject'] != null ? Subject.fromJson(json['subject'] as Map<String, dynamic>) : null,
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher'] as Map<String, dynamic>) : null,
    );
  }
}

class Subject {
  final int id;
  final String name;

  Subject({
    required this.id,
    required this.name,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class Teacher {
  final int id;
  final String name;

  Teacher({
    required this.id,
    required this.name,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
