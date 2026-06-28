import 'package:uas_prakpemrogramanmobile/core/constants/api_constants.dart';
import 'package:uas_prakpemrogramanmobile/core/services/api_service.dart';
import 'package:uas_prakpemrogramanmobile/models/review_model.dart';

class ReviewService {
  // Delete own review by ID
  Future<void> deleteReview(String reviewId) async {
    await ApiService.delete(
      ApiConstants.reviewDetail(reviewId),
      requireAuth: true,
    );
  }
  // Fetch reviews for a specific product with pagination
  Future<Map<String, dynamic>> fetchProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiService.get(
      ApiConstants.productReviews(productId),
      requireAuth: false,
      queryParams: queryParams,
    );

    List<dynamic> reviewsData = [];
    if (response['data'] is List) {
      reviewsData = response['data'];
    } else if (response['data'] is Map) {
      final mapData = response['data'] as Map;
      for (var value in mapData.values) {
        if (value is List) {
          reviewsData = value;
          break;
        }
      }
      if (reviewsData.isEmpty) {
        reviewsData = mapData.values.toList();
      }
    } else if (response is List) {
      reviewsData = response;
    }

    final reviews = reviewsData.map((json) => ReviewModel.fromJson(json)).toList();

    final pagination = response['pagination'] ?? {};

    return {
      'reviews': reviews,
      'page': pagination['page'] ?? page,
      'totalPages': pagination['totalPages'] ?? 1,
      'total': pagination['total'] ?? reviews.length,
    };
  }

  // Add review for a specific product
  Future<ReviewModel> addProductReview(
    String productId, {
    required int rating,
    String? comment,
  }) async {
    final Map<String, dynamic> body = {
      'rating': rating,
    };
    
    if (comment != null && comment.trim().isNotEmpty) {
      body['comment'] = comment.trim();
    }

    final response = await ApiService.post(
      ApiConstants.productReviews(productId),
      body: body,
      requireAuth: true,
    );

    // Some APIs return the newly created review inside "data"
    final data = response['data'] ?? response;
    
    // In post review schema, it might not contain reviewer details immediately
    // so we construct a partial model which will be refreshed
    return ReviewModel(
      id: data['id'] ?? '',
      rating: data['rating'] ?? rating,
      comment: data['comment'] ?? comment,
      reviewerName: 'Saya', // local fallback until refreshed
      createdAt: data['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}
