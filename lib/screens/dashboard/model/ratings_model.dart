// Overall Ratings Response (from ratingApi)
class RatingsResponse {
  final bool success;
  final String message;
  final RatingsData data;

  RatingsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RatingsResponse.fromJson(Map<String, dynamic> json) {
    return RatingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: RatingsData.fromJson(json['data'] ?? {}),
    );
  }
}

class RatingsData {
  final int totalReviews;
  final double averageRating;
  final RatingsBreakdown ratingsBreakdown;

  RatingsData({
    required this.totalReviews,
    required this.averageRating,
    required this.ratingsBreakdown,
  });

  factory RatingsData.fromJson(Map<String, dynamic> json) {
    return RatingsData(
      totalReviews: _parseInt(json['total_reviews']),
      averageRating: _parseDouble(json['average_rating']),
      ratingsBreakdown: RatingsBreakdown.fromJson(
        json['ratings_breakdown'] ?? {},
      ),
    );
  }

  // Helper method to safely parse integers from JSON (handles both string and int)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) {
      return value.toInt();
    }
    return 0;
  }

  // Helper method to safely parse doubles from JSON (handles both string and double)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class RatingsBreakdown {
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final int fourStar;
  final int fiveStar;

  RatingsBreakdown({
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.fourStar,
    required this.fiveStar,
  });

  factory RatingsBreakdown.fromJson(Map<String, dynamic> json) {
    return RatingsBreakdown(
      oneStar: _parseInt(json['1_star']),
      twoStar: _parseInt(json['2_star']),
      threeStar: _parseInt(json['3_star']),
      fourStar: _parseInt(json['4_star']),
      fiveStar: _parseInt(json['5_star']),
    );
  }

  // Helper method to safely parse integers from JSON (handles both string and int)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) {
      return value.toInt();
    }
    return 0;
  }
}

// Delivery Feedback Response (from feedbackApi)
class DeliveryFeedbackResponse {
  final bool success;
  final String message;
  final FeedbackPaginationData data;

  DeliveryFeedbackResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DeliveryFeedbackResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryFeedbackResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: FeedbackPaginationData.fromJson(json['data'] ?? {}),
    );
  }
}

class FeedbackPaginationData {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<DeliveryFeedback> feedbackItems;

  FeedbackPaginationData({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.feedbackItems,
  });

  factory FeedbackPaginationData.fromJson(Map<String, dynamic> json) {
    return FeedbackPaginationData(
      currentPage: _parseInt(json['current_page']),
      lastPage: _parseInt(json['last_page']),
      perPage: _parseInt(json['per_page']),
      total: _parseInt(json['total']),
      feedbackItems:
          (json['data'] as List<dynamic>?)
              ?.map((item) => DeliveryFeedback.fromJson(item))
              .toList() ??
          [],
    );
  }

  // Helper method to safely parse integers from JSON (handles both string and int)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) {
      return value.toInt();
    }
    return 0;
  }
}

class DeliveryFeedback {
  final int id;
  final User user;
  final DeliveryBoy deliveryBoy;
  final dynamic order; // Can be null
  final String title;
  final String slug;
  final String description;
  final int rating;
  final DateTime createdAt;

  DeliveryFeedback({
    required this.id,
    required this.user,
    required this.deliveryBoy,
    this.order,
    required this.title,
    required this.slug,
    required this.description,
    required this.rating,
    required this.createdAt,
  });

  factory DeliveryFeedback.fromJson(Map<String, dynamic> json) {
    return DeliveryFeedback(
      id: _parseInt(json['id']),
      user: User.fromJson(json['user'] ?? {}),
      deliveryBoy: DeliveryBoy.fromJson(json['delivery_boy'] ?? {}),
      order: json['order'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      rating: _parseInt(json['rating']),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to safely parse integers from JSON (handles both string and int)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) {
      return value.toInt();
    }
    return 0;
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String? referralCode;
  final String? friendsCode;
  final int rewardPoints;
  final String profileImage;
  final bool status;
  final String country;
  final String iso2;
  final String accessPanel;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.referralCode,
    this.friendsCode,
    required this.rewardPoints,
    required this.profileImage,
    required this.status,
    required this.country,
    required this.iso2,
    required this.accessPanel,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      referralCode: json['referral_code'],
      friendsCode: json['friends_code'],
      rewardPoints: _parseInt(json['reward_points']),
      profileImage: json['profile_image'] ?? '',
      status: json['status'] ?? false,
      country: json['country'] ?? '',
      iso2: json['iso_2'] ?? '',
      accessPanel: json['access_panel'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to safely parse integers from JSON (handles both string and int)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) {
      return value.toInt();
    }
    return 0;
  }
}

class DeliveryBoy {
  final int id;
  final int userId;
  final int deliveryZoneId;
  final String status;
  final String fullName;
  final String address;
  final List<String> driverLicense;
  final String driverLicenseNumber;
  final String vehicleType;
  final List<String> vehicleRegistration;
  final String verificationStatus;
  final String? verificationRemark;
  final DateTime createdAt;

  DeliveryBoy({
    required this.id,
    required this.userId,
    required this.deliveryZoneId,
    required this.status,
    required this.fullName,
    required this.address,
    required this.driverLicense,
    required this.driverLicenseNumber,
    required this.vehicleType,
    required this.vehicleRegistration,
    required this.verificationStatus,
    this.verificationRemark,
    required this.createdAt,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) {
    return DeliveryBoy(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      deliveryZoneId: _parseInt(json['delivery_zone_id']),
      status: json['status'] ?? '',
      fullName: json['full_name'] ?? '',
      address: json['address'] ?? '',
      driverLicense: List<String>.from(json['driver_license'] ?? []),
      driverLicenseNumber: json['driver_license_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      vehicleRegistration: List<String>.from(
        json['vehicle_registration'] ?? [],
      ),
      verificationStatus: json['verification_status'] ?? '',
      verificationRemark: json['verification_remark'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to safely parse integers from JSON (handles both string and int)
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) {
      return value.toInt();
    }
    return 0;
  }
}

// Helper class for calculating ratings statistics
class RatingsStatistics {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;

  RatingsStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  factory RatingsStatistics.fromFeedbackList(
    List<DeliveryFeedback> feedbackList,
  ) {
    if (feedbackList.isEmpty) {
      return RatingsStatistics(
        averageRating: 0.0,
        totalReviews: 0,
        ratingBreakdown: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }

    final totalReviews = feedbackList.length;
    final totalRating = feedbackList.fold<int>(
      0,
      (sum, feedback) => sum + feedback.rating,
    );
    final averageRating = totalRating / totalReviews;

    final ratingBreakdown = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final feedback in feedbackList) {
      ratingBreakdown[feedback.rating] =
          (ratingBreakdown[feedback.rating] ?? 0) + 1;
    }

    return RatingsStatistics(
      averageRating: averageRating,
      totalReviews: totalReviews,
      ratingBreakdown: ratingBreakdown,
    );
  }
}
