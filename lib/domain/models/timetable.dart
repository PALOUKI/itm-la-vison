import 'package:vision/domain/models/common_models.dart';

class TimetableResponse {
  final int classId;
  final AcademicYear academicYear;
  final List<TimetableItem> items;

  TimetableResponse({
    required this.classId,
    required this.academicYear,
    required this.items,
  });

  factory TimetableResponse.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure
    final itemsList = (json['timetable'] ?? json['items']) as List<dynamic>? ?? [];

    // Si on a au moins un élément, on peut récupérer la semaine de référence
    DateTime? referenceDate;
    if (itemsList.isNotEmpty) {
      final firstItem = itemsList.first as Map<String, dynamic>;
      final firstStartTime = DateTime.parse(firstItem['start_time'] as String);
      referenceDate = firstStartTime.toLocal();
    }

    return TimetableResponse(
      classId: (json['class_id'] as int?) ?? 0,
      academicYear: json['academic_year'] != null
        ? AcademicYear.fromJson(json['academic_year'] as Map<String, dynamic>)
        : AcademicYear(
            id: 0,
            uuid: '',
            name: 'Current Year',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            isCurrent: true,
          ),
      items: itemsList
          .map((e) => TimetableItem.fromJson(e as Map<String, dynamic>, referenceDate))
          .toList(),
    );
  }
}


class TimetableItem {
  final int id;
  final String uuid;
  final String dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;
  final String? room;
  final Subject? subject;
  final Teacher? teacher;

  TimetableItem({
    required this.id,
    required this.uuid,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
    this.subject,
    this.teacher,
  });

  factory TimetableItem.fromJson(Map<String, dynamic> json, DateTime? referenceDate) {
    final startTimeStr = json['start_time'] as String;
    final endTimeStr = json['end_time'] as String;
    final dayOfWeekStr = json['day_of_week'] as String;

    // Parse les timestamps UTC
    var startTimeUtc = DateTime.parse(startTimeStr);
    var endTimeUtc = DateTime.parse(endTimeStr);

    // Convertir en heure locale
    var startTime = startTimeUtc.toLocal();
    var endTime = endTimeUtc.toLocal();

    // Si on a une date de référence, recalculer les dates selon day_of_week
    if (referenceDate != null) {
      // Trouver le lundi de la semaine de référence
      final monday = _getMondayFromDate(referenceDate);

      // Mapper day_of_week (string) à l'offset de jours
      final dayOffset = _getDayOffset(dayOfWeekStr);

      // Calculer la date correcte
      final correctDate = monday.add(Duration(days: dayOffset));

      // Appliquer cette date tout en conservant les heures
      startTime = DateTime(
        correctDate.year,
        correctDate.month,
        correctDate.day,
        startTime.hour,
        startTime.minute,
        startTime.second,
        startTime.millisecond,
      );

      endTime = DateTime(
        correctDate.year,
        correctDate.month,
        correctDate.day,
        endTime.hour,
        endTime.minute,
        endTime.second,
        endTime.millisecond,
      );
    }

    return TimetableItem(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      dayOfWeek: dayOfWeekStr,
      startTime: startTime,
      endTime: endTime,
      room: json['room'] as String?,
      subject: json['subject'] != null ? Subject.fromJson(json['subject'] as Map<String, dynamic>) : null,
      teacher: json['teacher'] != null ? Teacher.fromJson(json['teacher'] as Map<String, dynamic>) : null,
    );
  }

  // Helper pour obtenir le lundi d'une semaine donnée
  static DateTime _getMondayFromDate(DateTime date) {
    final daysToSubtract = date.weekday == 7 ? 6 : date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  // Helper pour mapper day_of_week string à l'offset de jours
  static int _getDayOffset(String dayOfWeek) {
    const days = {
      'monday': 0,
      'tuesday': 1,
      'wednesday': 2,
      'thursday': 3,
      'friday': 4,
      'saturday': 5,
      'sunday': 6,
    };
    return days[dayOfWeek.toLowerCase()] ?? 0;
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

