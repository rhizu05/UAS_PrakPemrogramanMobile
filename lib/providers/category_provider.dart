import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/models/category_model.dart';
import 'package:uas_prakpemrogramanmobile/services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  // State
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategoryId; // Currently active filter

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoryId => _selectedCategoryId;

  // Set loading helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch Categories from server
  Future<void> fetchCategories() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _categories = await _categoryService.fetchCategories();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _categories = [];
    } finally {
      _setLoading(false);
    }
  }

  // Set current selected category filter (e.g. when Chip clicked)
  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }
}
