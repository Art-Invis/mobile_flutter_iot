class UserModel {
  final String fullName;
  final String email;
  final String password;
  final String department;

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.department,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? 'no-email@system.io',
      password: json['password']?.toString() ?? '',
      department: json['department']?.toString() ?? 'KSA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'department': department,
    };
  }
}
