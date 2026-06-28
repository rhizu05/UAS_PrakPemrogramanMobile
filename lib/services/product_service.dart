import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/product_model.dart';

class ProductService {
  // Fetch active products with search, category filter, sort, and pagination
  Future<Map<String, dynamic>> fetchProducts({
    String? search,
    String? categoryId,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['category_id'] = categoryId;
    }
    
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final response = await ApiService.get(
      ApiConstants.products,
      requireAuth: false,
      queryParams: queryParams,
    );

    // Map list of dynamic to ProductModel
    final List<dynamic> productsData = response['data'] ?? [];
    final products = productsData.map((json) => ProductModel.fromJson(json)).toList();

    // Map pagination info
    final pagination = response['pagination'] ?? {};
    
    return {
      'products': products,
      'page': pagination['page'] ?? page,
      'totalPages': pagination['totalPages'] ?? 1,
      'total': pagination['total'] ?? products.length,
    };
  }

  // Fetch single product detail by ID (includes average_rating, total_reviews)
  Future<ProductModel> fetchProductDetail(String id) async {
    final response = await ApiService.get(
      ApiConstants.productDetail(id),
      requireAuth: false,
    );
    return ProductModel.fromJson(response['data']);
  }
}
