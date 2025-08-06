class ReviewModel {
  final int? id;
  final int productId;
  final String subject;
  final String review;
  final double rating;
  final DateTime createdAt;

  ReviewModel({
    this.id,
    required this.productId,
    required this.subject,
    required this.review,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int?,
      productId: json['product'] as int,
      subject: json['subject'] as String? ?? '',
      review: json['review'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'subject': subject,
      'review': review,
      'rating': rating,
      'created_date': createdAt.toIso8601String(),
    };
  }
}