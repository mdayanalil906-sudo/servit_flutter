class ExpertProfile {
  final String uid;
  final String expertId;
  final String name;
  final String email;
  final String phone;
  final String category;
  final double priceMin;
  final double priceMax;
  final String description;
  final String experience;
  final String state;
  final String district;
  final String address;
  final String landmark;
  final String pincode;
  final String profilePhoto;
  final bool isVerified;
  final String verificationStatus;
  final bool isOnline;
  final String membershipStatus;
  final String membershipType;
  final DateTime? membershipStartDate;
  final DateTime? membershipEndDate;
  final bool isExpertPremium;
  final double rating;
  final int jobs;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpertProfile({
    required this.uid,
    required this.expertId,
    required this.name,
    required this.email,
    required this.phone,
    this.category = '',
    this.priceMin = 0,
    this.priceMax = 0,
    this.description = '',
    this.experience = '',
    this.state = '',
    this.district = '',
    this.address = '',
    this.landmark = '',
    this.pincode = '',
    this.profilePhoto = '',
    this.isVerified = false,
    this.verificationStatus = '',
    this.isOnline = false,
    this.membershipStatus = '',
    this.membershipType = '',
    this.membershipStartDate,
    this.membershipEndDate,
    this.isExpertPremium = false,
    this.rating = 0,
    this.jobs = 0,
    this.role = 'expert',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ExpertProfile.fromMap(Map<String, dynamic> map, String uid) {
    return ExpertProfile(
      uid: uid,
      expertId: map['expertId'] ?? uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      category: map['category'] ?? '',
      priceMin: (map['priceMin'] ?? 0).toDouble(),
      priceMax: (map['priceMax'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      experience: map['experience'] ?? '',
      state: map['state'] ?? '',
      district: map['district'] ?? map['city'] ?? '',
      address: map['address'] ?? '',
      landmark: map['landmark'] ?? '',
      pincode: map['pincode'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      isVerified: map['isVerified'] ?? false,
      verificationStatus: map['verificationStatus'] ?? '',
      isOnline: map['isOnline'] ?? false,
      membershipStatus: map['membershipStatus'] ?? '',
      membershipType: map['membershipType'] ?? '',
      membershipStartDate: map['membershipStartDate'] != null
          ? DateTime.tryParse(map['membershipStartDate'])
          : null,
      membershipEndDate: map['membershipEndDate'] != null
          ? DateTime.tryParse(map['membershipEndDate'])
          : null,
      isExpertPremium: map['isExpertPremium'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
      jobs: map['jobs'] ?? 0,
      role: map['role'] ?? 'expert',
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
      'expertId': expertId,
      'name': name,
      'email': email,
      'phone': phone,
      'category': category,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'description': description,
      'experience': experience,
      'state': state,
      'district': district,
      'address': address,
      'landmark': landmark,
      'pincode': pincode,
      'profilePhoto': profilePhoto,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'isOnline': isOnline,
      'membershipStatus': membershipStatus,
      'membershipType': membershipType,
      'membershipStartDate': membershipStartDate?.toIso8601String(),
      'membershipEndDate': membershipEndDate?.toIso8601String(),
      'isExpertPremium': isExpertPremium,
      'rating': rating,
      'jobs': jobs,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  bool get hasActiveMembership =>
      isExpertPremium &&
      membershipEndDate != null &&
      membershipEndDate!.isAfter(DateTime.now());

  int get daysLeft {
    if (membershipEndDate == null) return 0;
    return membershipEndDate!.difference(DateTime.now()).inDays;
  }

  ExpertProfile copyWith({
    String? name,
    String? phone,
    String? category,
    double? priceMin,
    double? priceMax,
    String? description,
    String? experience,
    String? state,
    String? district,
    String? profilePhoto,
    bool? isVerified,
    String? verificationStatus,
    bool? isOnline,
    String? membershipStatus,
    String? membershipType,
    DateTime? membershipStartDate,
    DateTime? membershipEndDate,
    bool? isExpertPremium,
    double? rating,
    int? jobs,
  }) {
    return ExpertProfile(
      uid: uid,
      expertId: expertId,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      description: description ?? this.description,
      experience: experience ?? this.experience,
      state: state ?? this.state,
      district: district ?? this.district,
      address: address,
      landmark: landmark,
      pincode: pincode,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isOnline: isOnline ?? this.isOnline,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      membershipType: membershipType ?? this.membershipType,
      membershipStartDate: membershipStartDate ?? this.membershipStartDate,
      membershipEndDate: membershipEndDate ?? this.membershipEndDate,
      isExpertPremium: isExpertPremium ?? this.isExpertPremium,
      rating: rating ?? this.rating,
      jobs: jobs ?? this.jobs,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
