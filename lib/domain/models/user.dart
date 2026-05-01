class UserParentDetails {
  final int id;
  final String uuid;
  final String fatherName;
  final String? fatherPhone;
  final String? fatherProfession;
  final String? motherName;
  final String? motherPhone;
  final String? motherProfession;
  final String address;
  final String city;
  final String? emergencyContact;
  final String? emergencyPhone;

  UserParentDetails({
    required this.id,
    required this.uuid,
    required this.fatherName,
    this.fatherPhone,
    this.fatherProfession,
    this.motherName,
    this.motherPhone,
    this.motherProfession,
    required this.address,
    required this.city,
    this.emergencyContact,
    this.emergencyPhone,
  });

  factory UserParentDetails.fromJson(Map<String, dynamic> json) {
    return UserParentDetails(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      fatherName: json['father_name'] as String? ?? '',
      fatherPhone: json['father_phone'] as String?,
      fatherProfession: json['father_profession'] as String?,
      motherName: json['mother_name'] as String?,
      motherPhone: json['mother_phone'] as String?,
      motherProfession: json['mother_profession'] as String?,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      emergencyContact: json['emergency_contact'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'father_name': fatherName,
      'father_phone': fatherPhone,
      'father_profession': fatherProfession,
      'mother_name': motherName,
      'mother_phone': motherPhone,
      'mother_profession': motherProfession,
      'address': address,
      'city': city,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
    };
  }
}

class User {
  final int id;
  final String? uuid;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? avatar;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final UserParentDetails? parent;

  User({
    required this.id,
    this.uuid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    required this.isActive,
    this.lastLoginAt,
    this.createdAt,
    this.parent,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      uuid: json['uuid'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['profile_photo'] as String? ?? json['avatar'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      parent: json['parent'] != null
          ? UserParentDetails.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'profile_photo': avatar,
      'is_active': isActive,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      if (parent != null) 'parent': parent!.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? uuid,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? avatar,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    UserParentDetails? parent,
  }) {
    return User(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      parent: parent ?? this.parent,
    );
  }
}
