
class UserModel {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? gender;
  final String? city;
  final String? state;
  final String? country;
  final String? profilePicture;
  final DateTime dateJoined;
  final DateTime lastActivity;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.gender,
    this.city,
    this.state,
    this.country,
    this.profilePicture,
    required this.dateJoined,
    required this.lastActivity,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      profilePicture: json['profile_picture'] as String?,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      lastActivity: DateTime.parse(json['last_activity'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'gender':gender,
      'city': city,
      'state': state,
      'country': country,
      'profile_picture': profilePicture,
    }..removeWhere((key, value) => value == null);
  }
}
