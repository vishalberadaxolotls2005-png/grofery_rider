class CashCollectionModel {
  final int? id;
  final int? orderId;
  final String? orderDate;
  final String? cashCollected;
  final String? cashSubmitted;
  final String? remainingAmount;
  final String? submissionStatus;
  final String? createdAt;

  CashCollectionModel({
    this.id,
    this.orderId,
    this.orderDate,
    this.cashCollected,
    this.cashSubmitted,
    this.remainingAmount,
    this.submissionStatus,
    this.createdAt,
  });

  factory CashCollectionModel.fromJson(Map<String, dynamic> json) {
    return CashCollectionModel(
      id: json['id'],
      orderId: json['order_id'],
      orderDate: json['order_date'],
      cashCollected: json['cash_collected']?.toString(),
      cashSubmitted: json['cash_submitted']?.toString(),
      remainingAmount: json['remaining_amount']?.toString(),
      submissionStatus: json['submission_status'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_date': orderDate,
      'cash_collected': cashCollected,
      'cash_submitted': cashSubmitted,
      'remaining_amount': remainingAmount,
      'submission_status': submissionStatus,
      'created_at': createdAt,
    };
  }
}

class CashCollectionDetailModel {
  final String? baseFee;
  final String? perStorePickupFee;
  final String? distanceBasedFee;
  final String? perOrderIncentive;
  final String? total;

  CashCollectionDetailModel({
    this.baseFee,
    this.perStorePickupFee,
    this.distanceBasedFee,
    this.perOrderIncentive,
    this.total,
  });

  factory CashCollectionDetailModel.fromJson(Map<String, dynamic> json) {
    return CashCollectionDetailModel(
      baseFee: json['base_fee']?.toString(),
      perStorePickupFee: json['per_store_pickup_fee']?.toString(),
      distanceBasedFee: json['distance_based_fee']?.toString(),
      perOrderIncentive: json['per_order_incentive']?.toString(),
      total: json['total']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fee': baseFee,
      'per_store_pickup_fee': perStorePickupFee,
      'distance_based_fee': distanceBasedFee,
      'per_order_incentive': perOrderIncentive,
      'total': total,
    };
  }
}

class CashCollectionResponse {
  final bool? success;
  final String? message;
  final CashCollectionData? data;

  CashCollectionResponse({this.success, this.message, this.data});

  factory CashCollectionResponse.fromJson(Map<String, dynamic> json) {
    return CashCollectionResponse(
      success: json['success'],
      message: json['message'],
      data:
          json['data'] != null
              ? CashCollectionData.fromJson(json['data'])
              : null,
    );
  }
}

class CashCollectionData {
  final int? total;
  final int? perPage;
  final int? currentPage;
  final int? lastPage;
  final List<CashCollectionModel>? cashCollections;

  CashCollectionData({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.cashCollections,
  });

  factory CashCollectionData.fromJson(Map<String, dynamic> json) {
    return CashCollectionData(
      total: json['total'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      cashCollections:
          json['cash_collections'] != null
              ? List<CashCollectionModel>.from(
                json['cash_collections'].map(
                  (x) => CashCollectionModel.fromJson(x),
                ),
              )
              : null,
    );
  }
}
