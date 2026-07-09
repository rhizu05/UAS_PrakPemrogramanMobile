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
    double productPrice = 0.0;
    if (json['product'] is Map<String, dynamic>) {
      name = json['product']['name'] ?? name;
      imgUrl = json['product']['image_url'] ?? json['product']['imageUrl'];
      productPrice = double.tryParse(json['product']['price'].toString()) ?? 0.0;
    }

    double parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    if (parsedPrice == 0.0 && productPrice > 0.0) {
      parsedPrice = productPrice;
    }

    int qty = json['quantity'] ?? 0;
    double parsedSubtotal = double.tryParse(json['subtotal'].toString()) ?? 0.0;
    if (parsedSubtotal == 0.0) {
      parsedSubtotal = parsedPrice * qty;
    }

    return OrderItemModel(
      id: json['id'] ?? '',
      productName: name,
      imageUrl: imgUrl,
      quantity: qty,
      price: parsedPrice,
      subtotal: parsedSubtotal,
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
          .map((item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else if (json['order_items'] is List) {
      itemsList = (json['order_items'] as List)
          .map((item) => OrderItemModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    // Try parsing customer info (joined profiles or user objects in admin queries)
    String? name = json['customer_name'] ?? json['customerName'];
    String? email = json['customer_email'] ?? json['customerEmail'];
    if (json['user'] is Map) {
      final userMap = Map<String, dynamic>.from(json['user'] as Map);
      name = userMap['full_name'] ?? userMap['fullName'] ?? name;
      email = userMap['email'] ?? email;
    } else if (json['profiles'] is Map) {
      final profilesMap = Map<String, dynamic>.from(json['profiles'] as Map);
      name = profilesMap['full_name'] ?? profilesMap['fullName'] ?? name;
      email = profilesMap['email'] ?? email;
    } else if (json['profiles'] is List && (json['profiles'] as List).isNotEmpty) {
      final firstProfile = (json['profiles'] as List).first;
      if (firstProfile is Map) {
        final profilesMap = Map<String, dynamic>.from(firstProfile);
        name = profilesMap['full_name'] ?? profilesMap['fullName'] ?? name;
        email = profilesMap['email'] ?? email;
      }
    }

    double parsedTotal = double.tryParse((json['total'] ?? json['total_amount'] ?? json['totalAmount'] ?? json['grand_total'] ?? json['grandTotal'] ?? 0).toString()) ?? 0.0;
    if (parsedTotal == 0.0 && itemsList.isNotEmpty) {
      parsedTotal = itemsList.fold<double>(0.0, (sum, item) => sum + item.subtotal);
    }

    return OrderModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      total: parsedTotal,
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
