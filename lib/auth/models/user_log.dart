class User {
  final String id;
  final String email;
  final String username;

  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    username: json['username'],
    
    isActive: json['is_active'],
  );
}
