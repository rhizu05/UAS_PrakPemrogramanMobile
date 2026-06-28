import 'package:uas_prakpemrogramanmobile/models/product_model.dart';

class CartItemModel {
  final String id;
  final String cartId;
  final String productId;
  final int quantity;
  final double price;
  final double subtotal;
  final ProductModel? product;

  CartItemModel({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    
    // If price is 0 or missing, try to get it from nested product
    if ((parsedPrice == 0.0) && json['product'] is Map<String, dynamic>) {
       parsedPrice = double.tryParse(json['product']['price'].toString()) ?? 0.0;
    }
    
    int qty = json['quantity'] ?? 0;
    double parsedSubtotal = double.tryParse(json['subtotal'].toString()) ?? 0.0;
    
    // If subtotal is 0 or missing, calculate it manually
    if (parsedSubtotal == 0.0) {
      parsedSubtotal = parsedPrice * qty;
    }

    return CartItemModel(
      id: json['id'] ?? '',
      cartId: json['cart_id'] ?? json['cartId'] ?? '',
      productId: json['product_id'] ?? json['productId'] ?? '',
      quantity: qty,
      price: parsedPrice,
      subtotal: parsedSubtotal,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'product': product?.toJson(),
    };
  }
}

class CartModel {
  final String cartId;
  final List<CartItemModel> items;
  final int totalItems;
  final double grandTotal;

  CartModel({
    required this.cartId,
    required this.items,
    required this.totalItems,
    required this.grandTotal,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    var itemsList = <CartItemModel>[];
    if (json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    return CartModel(
      cartId: json['cart_id'] ?? json['cartId'] ?? '',
      items: itemsList,
      totalItems: json['total_items'] ?? json['totalItems'] ?? 0,
      grandTotal: double.tryParse((json['grand_total'] ?? json['grandTotal'] ?? 0).toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_items': totalItems,
      'grand_total': grandTotal,
    };
  }
}
