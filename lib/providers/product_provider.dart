import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/models/product_model.dart';
import 'package:uas_prakpemrogramanmobile/models/review_model.dart';
import 'package:uas_prakpemrogramanmobile/services/product_service.dart';
import 'package:uas_prakpemrogramanmobile/services/review_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final ReviewService _reviewService = ReviewService();

  // State
  List<ProductModel> _products = [];
  ProductModel? _detailProduct;
  List<ReviewModel> _reviews = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingDetail = false;
  bool _isLoadingReviews = false;
  bool _isAddingReview = false;
  bool _isDeletingReview = false;

  String? _errorMessage;
  String? _errorDetail;
  String? _errorReviews;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  // Active Query Parameters
  String? _searchQuery;
  String? _selectedCategoryId;
  String? _selectedSort = 'newest';

  // Getters
  List<ProductModel> get products => _products;
  ProductModel? get detailProduct => _detailProduct;
  List<ReviewModel> get reviews => _reviews;
  
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingReviews => _isLoadingReviews;
  bool get isAddingReview => _isAddingReview;
  bool get isDeletingReview => _isDeletingReview;

  String? get errorMessage => _errorMessage;
  String? get errorDetail => _errorDetail;
  String? get errorReviews => _errorReviews;

  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  String? get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedSort => _selectedSort;

  // Setters/Updaters for query parameters without fetching yet
  void setQueries({String? search, String? categoryId, String? sort}) {
    _searchQuery = search;
    _selectedCategoryId = categoryId;
    _selectedSort = sort ?? _selectedSort;
  }

  // Set loading states
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }

  // Fetch Products
  Future<void> fetchProducts({bool refresh = true}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = null;
      _setLoading(true);
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _setLoadingMore(true);
    }

    try {
      final result = await _productService.fetchProducts(
        search: _searchQuery,
        categoryId: _selectedCategoryId,
        sort: _selectedSort,
        page: _currentPage,
        limit: 10,
      );

      final List<ProductModel> fetchedProducts = result['products'];
      _currentPage = result['page'] + 1;
      _totalPages = result['totalPages'];
      _hasMore = result['page'] < _totalPages;

      if (refresh) {
        _products = fetchedProducts;
      } else {
        _products.addAll(fetchedProducts);
      }
      
      _errorMessage = null;
    } catch (e) {
      if (refresh) {
        _products = [];
        _errorMessage = e.toString();
      }
    } finally {
      if (refresh) {
        _setLoading(false);
      } else {
        _setLoadingMore(false);
      }
    }
  }

  // Update query variables and fetch immediately
  Future<void> updateFilters({String? search, String? categoryId, String? sort}) async {
    _searchQuery = search;
    _selectedCategoryId = categoryId;
    if (sort != null) _selectedSort = sort;
    await fetchProducts(refresh: true);
  }

  // Fetch Product Detail by ID
  Future<void> fetchProductDetail(String id) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    _detailProduct = null;
    notifyListeners();

    try {
      _detailProduct = await _productService.fetchProductDetail(id);
      _errorDetail = null;
    } catch (e) {
      _errorDetail = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // Fetch Reviews by Product ID
  Future<void> fetchProductReviews(String productId, {bool refresh = true}) async {
    _isLoadingReviews = true;
    _errorReviews = null;
    if (refresh) _reviews = [];
    notifyListeners();

    try {
      final result = await _reviewService.fetchProductReviews(productId, page: 1, limit: 20);
      _reviews = result['reviews'];
      _errorReviews = null;
    } catch (e) {
      _reviews = [];
      _errorReviews = e.toString();
    } finally {
      _isLoadingReviews = false;
      notifyListeners();
    }
  }

  // Add Product Review
  Future<bool> addReview(String productId, {required int rating, String? comment}) async {
    _isAddingReview = true;
    notifyListeners();

    try {
      final newReview = await _reviewService.addProductReview(
        productId,
        rating: rating,
        comment: comment,
      );

      _reviews.insert(0, newReview);
      notifyListeners();
      
      await fetchProductReviews(productId, refresh: true);
      await fetchProductDetail(productId);
      
      _isAddingReview = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isAddingReview = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete Own Review
  Future<bool> deleteReview(String productId, String reviewId) async {
    _isDeletingReview = true;
    notifyListeners();

    try {
      await _reviewService.deleteReview(reviewId);
      
      await fetchProductReviews(productId, refresh: true);
      await fetchProductDetail(productId);
      
      _isDeletingReview = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isDeletingReview = false;
      notifyListeners();
      rethrow;
    }
  }
}
