class TopProductModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int soldCount;
  final double totalSales;

  TopProductModel({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.soldCount,
    required this.totalSales,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    String name = json['name'] ?? '';
    String? imgUrl = json['image_url'] ?? json['imageUrl'] ?? json['image'];

    if (json['product'] is Map<String, dynamic>) {
      final productMap = json['product'] as Map<String, dynamic>;
      name = productMap['name'] ?? name;
      imgUrl = productMap['image_url'] ?? productMap['imageUrl'] ?? imgUrl;
    }

    return TopProductModel(
      id: json['product_id'] ?? json['id'] ?? '',
      name: name,
      imageUrl: imgUrl,
      soldCount: int.tryParse((json['sold_quantity'] ?? json['soldCount'] ?? json['sold_count'] ?? 0).toString()) ?? 0,
      totalSales: double.tryParse((json['total_sales'] ?? json['totalSales'] ?? 0).toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': id,
      'name': name,
      'image_url': imageUrl,
      'sold_quantity': soldCount,
      'total_sales': totalSales,
    };
  }
}
