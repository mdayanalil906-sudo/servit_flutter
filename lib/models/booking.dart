class Booking {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String expertId;
  final String expertUid;
  final String expertName;
  final String category;
  final String problemDescription;
  final String bookingDate;
  final String bookingTime;
  String status;
  final String cancelledBy;
  final double estimatedPriceMin;
  final double estimatedPriceMax;
  final double finalPrice;
  final Map<String, dynamic> customerLocation;
  final Map<String, dynamic> expertLocation;
  final String trackingStatus;
  final bool isPremiumUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.expertId,
    required this.expertUid,
    required this.expertName,
    required this.category,
    this.problemDescription = '',
    this.bookingDate = '',
    this.bookingTime = '',
    this.status = 'pending',
    this.cancelledBy = '',
    this.estimatedPriceMin = 0,
    this.estimatedPriceMax = 0,
    this.finalPrice = 0,
    this.customerLocation = const {},
    this.expertLocation = const {},
    this.trackingStatus = '',
    this.isPremiumUser = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      bookingId: map['bookingId'] ?? id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? map['user'] ?? '',
      expertId: map['expertId'] ?? '',
      expertUid: map['expertUid'] ?? '',
      expertName: map['expertName'] ?? map['expert'] ?? '',
      category: map['category'] ?? '',
      problemDescription: map['problemDescription'] ?? map['problem'] ?? '',
      bookingDate: map['bookingDate'] ?? map['date'] ?? '',
      bookingTime: map['bookingTime'] ?? map['time'] ?? '',
      status: map['status'] ?? 'pending',
      cancelledBy: map['cancelledBy'] ?? '',
      estimatedPriceMin: (map['estimatedPriceMin'] ?? map['priceMin'] ?? 0).toDouble(),
      estimatedPriceMax: (map['estimatedPriceMax'] ?? map['priceMax'] ?? 0).toDouble(),
      finalPrice: (map['finalPrice'] ?? map['price'] ?? 0).toDouble(),
      customerLocation: map['customerLocation'] ?? {},
      expertLocation: map['expertLocation'] ?? {},
      trackingStatus: map['trackingStatus'] ?? '',
      isPremiumUser: map['isPremiumUser'] ?? map['isPrime'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'expertId': expertId,
      'expertUid': expertUid,
      'expertName': expertName,
      'category': category,
      'problemDescription': problemDescription,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'status': status,
      'cancelledBy': cancelledBy,
      'estimatedPriceMin': estimatedPriceMin,
      'estimatedPriceMax': estimatedPriceMax,
      'finalPrice': finalPrice,
      'customerLocation': customerLocation,
      'expertLocation': expertLocation,
      'trackingStatus': trackingStatus,
      'isPremiumUser': isPremiumUser,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
