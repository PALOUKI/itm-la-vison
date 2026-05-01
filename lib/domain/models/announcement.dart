class Announcement {
  final int id;
  final String uuid;
  final String title;
  final String content;
  final String type;
  final String targetAudience;
  final int? classId;
  final int? academicYearId;
  final bool isActive;
  final bool isImportant;
  final DateTime publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.uuid,
    required this.title,
    required this.content,
    required this.type,
    required this.targetAudience,
    this.classId,
    this.academicYearId,
    required this.isActive,
    required this.isImportant,
    required this.publishedAt,
    this.expiresAt,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      targetAudience: json['target_audience'] as String,
      classId: json['class_id'] as int?,
      academicYearId: json['academic_year_id'] as int?,
      isActive: json['is_active'] as bool,
      isImportant: json['is_important'] as bool,
      publishedAt: DateTime.parse(json['published_at'] as String),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'title': title,
      'content': content,
      'type': type,
      'target_audience': targetAudience,
      'class_id': classId,
      'academic_year_id': academicYearId,
      'is_active': isActive,
      'is_important': isImportant,
      'published_at': publishedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AnnouncementsResponse {
  final bool success;
  final String message;
  final List<Announcement> data;
  final Pagination? pagination;

  AnnouncementsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory AnnouncementsResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementsResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List).map((i) => Announcement.fromJson(i)).toList(),
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }
}

class Pagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int? from;
  final int? to;

  Pagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.from,
    this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      from: json['from'] as int?,
      to: json['to'] as int?,
    );
  }
}
