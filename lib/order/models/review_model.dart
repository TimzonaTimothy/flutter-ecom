class ReviewModel {
  final int? id;
  final int userId;
  final int productId;
  final String subject;
  final String review;
  final double rating;
  final String? ip;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.subject,
    required this.review,
    required this.rating,
    this.ip,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int?,
      userId: json['user'] as int,
      productId: json['product'] as int,
      subject: json['subject'] as String,
      review: json['review'] as String,
      rating: (json['rating'] as num).toDouble(),
      ip: json['ip'] as String?,
      status: json['status'] as bool,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'review': review,
      'rating': rating,
    };
  }
}