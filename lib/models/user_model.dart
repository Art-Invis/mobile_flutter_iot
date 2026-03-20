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
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      department: json['department'] as String,
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
