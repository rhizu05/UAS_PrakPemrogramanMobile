class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int stock;
  final String categoryId;
  final String? imageUrl;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? categoryName; // Parsed from categories object
  final double averageRating; // Optional from detail
  final int totalReviews;     // Optional from detail

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse category name from categories object
    String? categoryName;
    if (json['categories'] is Map<String, dynamic>) {
      categoryName = json['categories']['name'];
    } else if (json['category'] is Map<String, dynamic>) {
      categoryName = json['category']['name'];
    }

    // Parse ratings/reviews safely
    double avgRating = 0.0;
    if (json['average_rating'] != null) {
      avgRating = double.tryParse(json['average_rating'].toString()) ?? 0.0;
    } else if (json['averageRating'] != null) {
      avgRating = double.tryParse(json['averageRating'].toString()) ?? 0.0;
    }

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: json['stock'] ?? 0,
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      updatedAt: json['updated_at'] ?? json['updatedAt'] ?? '',
      categoryName: categoryName,
      averageRating: avgRating,
      totalReviews: json['total_reviews'] ?? json['totalReviews'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}
