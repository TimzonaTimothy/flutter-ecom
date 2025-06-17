class UserRegModel {
  final String firstname;
  final String lastname;
  final String email;
  final String password;

  UserRegModel({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.password,
  });

  // Convert UserRegModel to JSON (e.g., to send to an API or save in Firebase)
  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname':lastname,
      'email': email,
      'password': password, 
    };
  }

  // Create UserRegModel from JSON
  factory UserRegModel.fromJson(Map<String, dynamic> json) {
    return UserRegModel(
      firstname: json['first_name'] ?? '',
      lastname: json['last_name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
