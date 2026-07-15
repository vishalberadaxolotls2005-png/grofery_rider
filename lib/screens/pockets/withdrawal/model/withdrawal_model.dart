class WithdrawalModel {
  final int? id;
  final int? userId;
  final int? deliveryBoyId;
  final double? amount;
  final String? status;
  final String? requestNote;
  final String? adminRemark;
  final String? processedAt;
  final int? processedBy;
  final String? transactionId;
  final String? createdAt;
  final String? updatedAt;
  final DeliveryBoyModel? deliveryBoy;

  WithdrawalModel({
    this.id,
    this.userId,
    this.deliveryBoyId,
    this.amount,
    this.status,
    this.requestNote,
    this.adminRemark,
    this.processedAt,
    this.processedBy,
    this.transactionId,
    this.createdAt,
    this.updatedAt,
    this.deliveryBoy,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      deliveryBoyId: _parseInt(json['delivery_boy_id']),
      amount: _parseDouble(json['amount']),
      status: json['status']?.toString(),
      requestNote: json['request_note']?.toString(),
      adminRemark: json['admin_remark']?.toString(),
      processedAt: json['processed_at']?.toString(),
      processedBy: _parseInt(json['processed_by']),
      transactionId: json['transaction_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deliveryBoy:
          json['delivery_boy'] != null
              ? DeliveryBoyModel.fromJson(json['delivery_boy'])
              : null,
    );
  }

  // Helper method to safely parse integers
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }

  // Helper method to safely parse doubles
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'delivery_boy_id': deliveryBoyId,
      'amount': amount?.toString(),
      'status': status,
      'request_note': requestNote,
      'admin_remark': adminRemark,
      'processed_at': processedAt,
      'processed_by': processedBy,
      'transaction_id': transactionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'delivery_boy': deliveryBoy?.toJson(),
    };
  }
}

class DeliveryBoyModel {
  final int? id;
  final int? userId;
  final int? deliveryZoneId;
  final String? fullName;
  final String? address;
  final String? driverLicense;
  final String? driverLicenseNumber;
  final String? vehicleType;
  final String? vehicleRegistration;
  final String? verificationStatus;
  final String? verificationRemark;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final UserModel? user;

  DeliveryBoyModel({
    this.id,
    this.userId,
    this.deliveryZoneId,
    this.fullName,
    this.address,
    this.driverLicense,
    this.driverLicenseNumber,
    this.vehicleType,
    this.vehicleRegistration,
    this.verificationStatus,
    this.verificationRemark,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.user,
  });

  factory DeliveryBoyModel.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyModel(
      id: WithdrawalModel._parseInt(json['id']),
      userId: WithdrawalModel._parseInt(json['user_id']),
      deliveryZoneId: WithdrawalModel._parseInt(json['delivery_zone_id']),
      fullName: json['full_name']?.toString(),
      address: json['address']?.toString(),
      driverLicense: json['driver_license']?.toString(),
      driverLicenseNumber: json['driver_license_number']?.toString(),
      vehicleType: json['vehicle_type']?.toString(),
      vehicleRegistration: json['vehicle_registration']?.toString(),
      verificationStatus: json['verification_status']?.toString(),
      verificationRemark: json['verification_remark']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'delivery_zone_id': deliveryZoneId,
      'full_name': fullName,
      'address': address,
      'driver_license': driverLicense,
      'driver_license_number': driverLicenseNumber,
      'vehicle_type': vehicleType,
      'vehicle_registration': vehicleRegistration,
      'verification_status': verificationStatus,
      'verification_remark': verificationRemark,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'user': user?.toJson(),
    };
  }
}

class UserModel {
  final int? id;
  final String? mobile;
  final String? referralCode;
  final String? friendsCode;
  final int? rewardPoints;
  final bool? status;
  final String? name;
  final String? email;
  final String? country;
  final String? iso2;
  final String? emailVerifiedAt;
  final String? accessPanel;
  final String? deletedAt;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    this.mobile,
    this.referralCode,
    this.friendsCode,
    this.rewardPoints,
    this.status,
    this.name,
    this.email,
    this.country,
    this.iso2,
    this.emailVerifiedAt,
    this.accessPanel,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: WithdrawalModel._parseInt(json['id']),
      mobile: json['mobile']?.toString(),
      referralCode: json['referral_code']?.toString(),
      friendsCode: json['friends_code']?.toString(),
      rewardPoints: WithdrawalModel._parseInt(json['reward_points']),
      status: _parseBool(json['status']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      country: json['country']?.toString(),
      iso2: json['iso_2']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      accessPanel: json['access_panel']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // Helper method to safely parse boolean values
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': mobile,
      'referral_code': referralCode,
      'friends_code': friendsCode,
      'reward_points': rewardPoints,
      'status': status,
      'name': name,
      'email': email,
      'country': country,
      'iso_2': iso2,
      'email_verified_at': emailVerifiedAt,
      'access_panel': accessPanel,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class WithdrawalResponse {
  final bool success;
  final String message;
  final WithdrawalPaginationData? data;

  WithdrawalResponse({required this.success, required this.message, this.data});

  factory WithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return WithdrawalResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? WithdrawalPaginationData.fromJson(json['data'])
              : null,
    );
  }
}

class WithdrawalPaginationData {
  final int currentPage;
  final List<WithdrawalModel> data;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  WithdrawalPaginationData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory WithdrawalPaginationData.fromJson(Map<String, dynamic> json) {
    return WithdrawalPaginationData(
      currentPage: WithdrawalModel._parseInt(json['current_page']) ?? 1,
      data:
          json['data'] != null
              ? (json['data'] as List)
                  .map((item) => WithdrawalModel.fromJson(item))
                  .toList()
              : [],
      firstPageUrl: json['first_page_url']?.toString() ?? '',
      from: WithdrawalModel._parseInt(json['from']),
      lastPage: WithdrawalModel._parseInt(json['last_page']) ?? 1,
      lastPageUrl: json['last_page_url']?.toString() ?? '',
      links:
          json['links'] != null
              ? (json['links'] as List)
                  .map((item) => PaginationLink.fromJson(item))
                  .toList()
              : [],
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString() ?? '',
      perPage: WithdrawalModel._parseInt(json['per_page']) ?? 15,
      prevPageUrl: json['prev_page_url']?.toString(),
      to: WithdrawalModel._parseInt(json['to']),
      total: WithdrawalModel._parseInt(json['total']) ?? 0,
    );
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({this.url, required this.label, required this.active});

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}

class SingleWithdrawalResponse {
  final bool success;
  final String message;
  final WithdrawalModel? data;

  SingleWithdrawalResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SingleWithdrawalResponse.fromJson(Map<String, dynamic> json) {
    return SingleWithdrawalResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null ? WithdrawalModel.fromJson(json['data']) : null,
    );
  }
}

class CreateWithdrawalRequest {
  final double amount;
  final String requestNote;

  CreateWithdrawalRequest({required this.amount, required this.requestNote});

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'request_note': requestNote};
  }
}
