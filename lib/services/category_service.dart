import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/category_model.dart';

class CategoryService {
  // Fetch all product categories
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await ApiService.get(
      ApiConstants.categories,
      requireAuth: false,
    );

    final List<dynamic> categoriesData = response['data'] ?? [];
    return categoriesData.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
