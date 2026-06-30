class Ticket {
  final String id;
  final String type;
  final String description;
  final String status;
  final DateTime createdAt;
  final String screenshot;
  final String userId;
  final String user;
  final String userEmail;

  Ticket({
    required this.id,
    this.type = '',
    required this.description,
    this.status = 'open',
    DateTime? createdAt,
    this.screenshot = '',
    this.userId = '',
    this.user = '',
    this.userEmail = '',
  }) : createdAt = createdAt ?? DateTime.now();

  factory Ticket.fromMap(Map<String, dynamic> map, String id) {
    return Ticket(
      id: id,
      type: map['type'] ?? '',
      description: map['description'] ?? map['desc'] ?? '',
      status: map['status'] ?? 'open',
      createdAt: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : (map['createdAt'] != null
              ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
              : DateTime.now()),
      screenshot: map['screenshot'] ?? '',
      userId: map['userId'] ?? '',
      user: map['user'] ?? '',
      userEmail: map['userEmail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'description': description,
      'status': status,
      'date': createdAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'screenshot': screenshot,
      'userId': userId,
      'user': user,
      'userEmail': userEmail,
    };
  }
}
