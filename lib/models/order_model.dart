class OrderItemModel {
  final String id;
  final String productName;
  final String? imageUrl;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productName,
    this.imageUrl,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Extract product name and image from nested product object if available
    String name = json['product_name'] ?? json['productName'] ?? '';
    String? imgUrl;
    if (json['product'] is Map<String, dynamic>) {
      name = json['product']['name'] ?? name;
      imgUrl = json['product']['image_url'] ?? json['product']['imageUrl'];
    }

    return OrderItemModel(
      id: json['id'] ?? '',
      productName: name,
      imageUrl: imgUrl,
      quantity: json['quantity'] ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'image_url': imageUrl,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

class OrderModel {
  final String id;
  final String status;
  final double total;
  final String shippingAddress;
  final String? note;
  final String createdAt;
  final List<OrderItemModel> items;
  
  // Optional admin fields
  final String? customerName;
  final String? customerEmail;

  OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.shippingAddress,
    this.note,
    required this.createdAt,
    required this.items,
    this.customerName,
    this.customerEmail,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <OrderItemModel>[];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (json['order_items'] is List) {
      itemsList = (json['order_items'] as List)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Try parsing customer info (joined profiles or user objects in admin queries)
    String? name = json['customer_name'] ?? json['customerName'];
    String? email = json['customer_email'] ?? json['customerEmail'];
    if (json['user'] is Map<String, dynamic>) {
      name = json['user']['full_name'] ?? json['user']['fullName'] ?? name;
      email = json['user']['email'] ?? email;
    } else if (json['profiles'] is Map<String, dynamic>) {
      name = json['profiles']['full_name'] ?? json['profiles']['fullName'] ?? name;
      email = json['profiles']['email'] ?? email;
    }

    return OrderModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      shippingAddress: json['shipping_address'] ?? json['shippingAddress'] ?? '',
      note: json['notes'] ?? json['note'],
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      items: itemsList,
      customerName: name,
      customerEmail: email,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'total': total,
      'shipping_address': shippingAddress,
      'notes': note,
      'created_at': createdAt,
      'items': items.map((item) => item.toJson()).toList(),
      'customer_name': customerName,
      'customer_email': customerEmail,
    };
  }
}
