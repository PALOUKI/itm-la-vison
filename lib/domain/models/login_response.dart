import 'user.dart';

class LoginResponse {
  final bool success;
  final String message;
  final User user;
  final String token;
  final String tokenType;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      user: User.fromJson(json['data']['user'] as Map<String, dynamic>),
      token: json['data']['token'] as String,
      tokenType: json['data']['token_type'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'user': user.toJson(),
        'token': token,
        'token_type': tokenType,
      },
    };
  }
}

