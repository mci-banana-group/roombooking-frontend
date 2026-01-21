class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json['email'] as String,
        password: json['password'] as String,
      );
}

class LoginResponse {
  final String token;
  final UserResponse user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        token: json['token'] as String,
        user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
      );
}

class UserResponse {
  final String firstName;
  final String lastName;
  final String email;
  final UserRoleResponse role;
  final bool isAdmin;

  UserResponse({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isAdmin,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        role: json['role'] is String
            ? UserRoleResponse(name: json['role'] as String, ordinal: 0)
            : UserRoleResponse.fromJson(json['role'] as Map<String, dynamic>),
        isAdmin: json['isAdmin'] as bool,
      );
}

class UserRoleResponse {
  final String name;
  final int ordinal;

  UserRoleResponse({
    required this.name,
    required this.ordinal,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'ordinal': ordinal,
      };

  factory UserRoleResponse.fromJson(Map<String, dynamic> json) => UserRoleResponse(
        name: json['name'] as String,
        ordinal: json['ordinal'] as int,
      );
}

class RegistrationRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final UserRoleResponse role;
  final UserRoleResponse permissionLevel;

  RegistrationRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.permissionLevel,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role.toJson(),
        'permissionLevel': permissionLevel.toJson(),
      };

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) => RegistrationRequest(
        email: json['email'] as String,
        password: json['password'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        role: UserRoleResponse.fromJson(json['role'] as Map<String, dynamic>),
        permissionLevel: UserRoleResponse.fromJson(
            json['permissionLevel'] as Map<String, dynamic>),
      );
}

class CheckInRequest {
  final int bookingId;
  final String code;

  CheckInRequest({
    required this.bookingId,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'code': code,
      };

  factory CheckInRequest.fromJson(Map<String, dynamic> json) => CheckInRequest(
        bookingId: json['bookingId'] as int,
        code: json['code'] as String,
      );
}
