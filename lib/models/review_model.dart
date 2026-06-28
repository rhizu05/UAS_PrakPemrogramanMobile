class ReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final String reviewerName;
  final String? reviewerAvatar;
  final String? reviewerId;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.reviewerName,
    this.reviewerAvatar,
    this.reviewerId,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String name = '';
    String? avatar;
    String? reviewerId;
    if (json['reviewer'] is Map<String, dynamic>) {
      name = json['reviewer']['full_name'] ?? json['reviewer']['fullName'] ?? '';
      avatar = json['reviewer']['avatar_url'] ?? json['reviewer']['avatarUrl'];
      reviewerId = json['reviewer']['id'] ?? json['reviewer']['_id'];
    }

    return ReviewModel(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      reviewerName: name,
      reviewerAvatar: avatar,
      reviewerId: reviewerId,
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'reviewer': {
        'id': reviewerId,
        'full_name': reviewerName,
        'avatar_url': reviewerAvatar,
      },
      'created_at': createdAt,
    };
  }
}
