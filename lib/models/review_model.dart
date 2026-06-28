class ReviewModel {
  final String id;
  final int rating;
  final String? comment;
  final String reviewerName;
  final String? reviewerAvatar;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String name = '';
    String? avatar;
    if (json['reviewer'] is Map<String, dynamic>) {
      name = json['reviewer']['full_name'] ?? json['reviewer']['fullName'] ?? '';
      avatar = json['reviewer']['avatar_url'] ?? json['reviewer']['avatarUrl'];
    }

    return ReviewModel(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      reviewerName: name,
      reviewerAvatar: avatar,
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'reviewer': {
        'full_name': reviewerName,
        'avatar_url': reviewerAvatar,
      },
      'created_at': createdAt,
    };
  }
}
