class CategoryModel {
  final int id;
  final String title;
  final String slug;
  final String image;
  final String? description;
  final DateTime? createdDate;
  final DateTime? modifiedDate;

  CategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.image,
    this.description,
    this.createdDate,
    this.modifiedDate,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      image: json['image'],
      description: json['description'],
      createdDate: json['created_date'] != null ? DateTime.tryParse(json['created_date']) : null,
      modifiedDate: json['modified_date'] != null ? DateTime.tryParse(json['modified_date']) : null,
    );
  }
}
