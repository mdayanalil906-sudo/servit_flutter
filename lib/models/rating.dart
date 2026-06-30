class Rating {
  final String id;
  final String bookingId;
  final String userId;
  final String expertId;
  final int stars;
  final String review;
  final String userName;
  final String category;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.expertId,
    required this.stars,
    this.review = '',
    this.userName = '',
    this.category = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Rating.fromMap(Map<String, dynamic> map, String id) {
    return Rating(
      id: id,
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      expertId: map['expertId'] ?? '',
      stars: map['stars'] ?? 5,
      review: map['review'] ?? '',
      userName: map['userName'] ?? '',
      category: map['category'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'expertId': expertId,
      'stars': stars,
      'review': review,
      'userName': userName,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
