class Payment {
  final String id;
  final String paymentId;
  final String userId;
  final String expertId;
  final String type;
  final double amount;
  final String description;
  final String bookingId;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.paymentId,
    this.userId = '',
    this.expertId = '',
    required this.type,
    required this.amount,
    this.description = '',
    this.bookingId = '',
    this.status = 'completed',
    this.paymentMethod = 'razorpay',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Payment.fromMap(Map<String, dynamic> map, String id) {
    return Payment(
      id: id,
      paymentId: map['paymentId'] ?? id,
      userId: map['userId'] ?? '',
      expertId: map['expertId'] ?? '',
      type: map['type'] ?? 'general',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      bookingId: map['bookingId'] ?? '',
      status: map['status'] ?? 'completed',
      paymentMethod: map['paymentMethod'] ?? 'razorpay',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'userId': userId,
      'expertId': expertId,
      'type': type,
      'amount': amount,
      'description': description,
      'bookingId': bookingId,
      'status': status,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
