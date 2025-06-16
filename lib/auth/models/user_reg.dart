class UserRegModel {
  final String name;
  final String email;
  final String password;

  UserRegModel({
    required this.name,
    required this.email,
    required this.password,
  });

  // Convert UserRegModel to JSON (e.g., to send to an API or save in Firebase)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password, 
    };
  }

  // Create UserRegModel from JSON
  factory UserRegModel.fromJson(Map<String, dynamic> json) {
    return UserRegModel(
      name: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
