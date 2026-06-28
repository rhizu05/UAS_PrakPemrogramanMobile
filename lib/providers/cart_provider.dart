import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/models/cart_model.dart';
import 'package:uas_prakpemrogramanmobile/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  int get totalItems => _cart?.totalItems ?? 0;
  double get grandTotal => _cart?.grandTotal ?? 0.0;
  bool get isCartEmpty => _cart == null || _cart!.items.isEmpty;

  // Set loading helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear errors helper
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset local state (on logout)
  void resetCart() {
    _cart = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Fetch Cart Details
  Future<void> fetchCart() async {
    _setLoading(true);
    clearError();
    try {
      _cart = await _cartService.fetchCart();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _cart = null;
    } finally {
      _setLoading(false);
    }
  }

  // Add Item to Cart
  Future<bool> addToCart(String productId, {int quantity = 1}) async {
    _setLoading(true);
    clearError();
    try {
      await _cartService.addToCart(productId: productId, quantity: quantity);
      await fetchCart(); // Automatically refresh local cart state
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Update Item Quantity
  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) return false;
    
    _setLoading(true);
    clearError();
    try {
      await _cartService.updateCartItem(cartItemId: cartItemId, quantity: newQuantity);
      await fetchCart(); // Automatically refresh local cart state
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Remove Item from Cart
  Future<bool> deleteItem(String cartItemId) async {
    _setLoading(true);
    clearError();
    try {
      await _cartService.deleteCartItem(cartItemId);
      await fetchCart(); // Automatically refresh local cart state
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Clear Cart
  Future<bool> clearCart() async {
    _setLoading(true);
    clearError();
    try {
      await _cartService.clearCart();
      await fetchCart(); // Automatically refresh local cart state
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
