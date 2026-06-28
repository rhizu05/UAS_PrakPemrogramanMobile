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
    String name = json['name'] ?? json['product_name'] ?? json['title'] ?? '';
    String? imgUrl = json['image_url'] ?? json['imageUrl'] ?? json['image'];

    if (json['product'] is Map<String, dynamic>) {
      final productMap = json['product'] as Map<String, dynamic>;
      name = productMap['name'] ?? productMap['product_name'] ?? productMap['title'] ?? name;
      imgUrl = productMap['image_url'] ?? productMap['imageUrl'] ?? imgUrl;
    }
    
    String finalId = json['product_id'] ?? json['id'] ?? '';
    
    if (name.isEmpty && finalId.isNotEmpty) {
      name = 'Produk (ID: $finalId)'; // Fallback UI
    } else if (name.isEmpty) {
      name = 'Produk Tidak Diketahui';
    }

    return TopProductModel(
      id: finalId,
      name: name,
      imageUrl: imgUrl,
      soldCount: int.tryParse((json['sold_quantity'] ?? json['soldCount'] ?? json['sold_count'] ?? json['total_sold'] ?? json['quantity'] ?? 0).toString()) ?? 0,
      totalSales: double.tryParse((json['total_sales'] ?? json['totalSales'] ?? json['revenue'] ?? 0).toString()) ?? 0.0,
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
