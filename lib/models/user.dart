class UserProfile {
  final String uid;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String state;
  final String district;
  final String address;
  final String landmark;
  final String pincode;
  final String profilePhoto;
  final String membershipStatus;
  final String membershipType;
  final DateTime? membershipStartDate;
  final DateTime? membershipEndDate;
  final bool isPremium;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.state = '',
    this.district = '',
    this.address = '',
    this.landmark = '',
    this.pincode = '',
    this.profilePhoto = '',
    this.membershipStatus = '',
    this.membershipType = '',
    this.membershipStartDate,
    this.membershipEndDate,
    this.isPremium = false,
    this.role = 'user',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      userId: map['userId'] ?? uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? map['city'] ?? '',
      address: map['address'] ?? '',
      landmark: map['landmark'] ?? '',
      pincode: map['pincode'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      membershipStatus: map['membershipStatus'] ?? '',
      membershipType: map['membershipType'] ?? '',
      membershipStartDate: map['membershipStartDate'] != null
          ? DateTime.tryParse(map['membershipStartDate'])
          : null,
      membershipEndDate: map['membershipEndDate'] != null
          ? DateTime.tryParse(map['membershipEndDate'])
          : null,
      isPremium: map['isPremium'] ?? false,
      role: map['role'] ?? 'user',
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
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'state': state,
      'district': district,
      'address': address,
      'landmark': landmark,
      'pincode': pincode,
      'profilePhoto': profilePhoto,
      'membershipStatus': membershipStatus,
      'membershipType': membershipType,
      'membershipStartDate': membershipStartDate?.toIso8601String(),
      'membershipEndDate': membershipEndDate?.toIso8601String(),
      'isPremium': isPremium,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  bool get hasActiveMembership =>
      isPremium &&
      membershipEndDate != null &&
      membershipEndDate!.isAfter(DateTime.now());

  int get daysLeft {
    if (membershipEndDate == null) return 0;
    return membershipEndDate!.difference(DateTime.now()).inDays;
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? state,
    String? district,
    String? address,
    String? landmark,
    String? pincode,
    String? profilePhoto,
    String? membershipStatus,
    String? membershipType,
    DateTime? membershipStartDate,
    DateTime? membershipEndDate,
    bool? isPremium,
  }) {
    return UserProfile(
      uid: uid,
      userId: userId,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      district: district ?? this.district,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      pincode: pincode ?? this.pincode,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      membershipType: membershipType ?? this.membershipType,
      membershipStartDate: membershipStartDate ?? this.membershipStartDate,
      membershipEndDate: membershipEndDate ?? this.membershipEndDate,
      isPremium: isPremium ?? this.isPremium,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
