import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/cart_model.dart';

class CartService {
  // Fetch user's cart
  Future<CartModel> fetchCart() async {
    final response = await ApiService.get(
      ApiConstants.cart,
      requireAuth: true,
    );
    return CartModel.fromJson(response['data']);
  }

  // Add product to cart
  Future<void> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    await ApiService.post(
      ApiConstants.cart,
      body: {
        'product_id': productId,
        'quantity': quantity,
      },
      requireAuth: true,
    );
  }

  // Update item quantity in cart
  Future<void> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    await ApiService.put(
      ApiConstants.cartItem(cartItemId),
      body: {
        'quantity': quantity,
      },
      requireAuth: true,
    );
  }

  // Delete specific item from cart
  Future<void> deleteCartItem(String cartItemId) async {
    await ApiService.delete(
      ApiConstants.cartItem(cartItemId),
      requireAuth: true,
    );
  }

  // Clear all items in cart
  Future<void> clearCart() async {
    await ApiService.delete(
      ApiConstants.cart,
      requireAuth: true,
    );
  }
}
