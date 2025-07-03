class Category {
  final String title;
  final String slug;
  final String description;
  final String image;
  final DateTime createdDate;
  final DateTime modifiedDate;

  Category({
    required this.title,
    required this.slug,
    required this.description,
    required this.image,
    required this.createdDate,
    required this.modifiedDate,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'],
      slug: json['slug'],
      description: json['description'] ?? '',
      image: json['image'],
      createdDate: DateTime.parse(json['created_date']),
      modifiedDate: DateTime.parse(json['modified_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'slug': slug,
      'description': description,
      'image': image,
      'created_date': createdDate.toIso8601String(),
      'modified_date': modifiedDate.toIso8601String(),
    };
  }
}
