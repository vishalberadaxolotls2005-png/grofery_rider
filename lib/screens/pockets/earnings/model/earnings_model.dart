// Utility class for safe parsing
class _ParseUtils {
  static int? parseInt(dynamic value) {
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

  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

class EarningsModel {
  final int? id;
  final int? orderId;
  final String? orderDate;
  final EarningsDetailModel? earnings;
  final String? paymentStatus;
  final String? paidAt;
  final String? createdAt;

  EarningsModel({
    this.id,
    this.orderId,
    this.orderDate,
    this.earnings,
    this.paymentStatus,
    this.paidAt,
    this.createdAt,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {






    return EarningsModel(
      id: _ParseUtils.parseInt(json['id']),
      orderId: _ParseUtils.parseInt(json['order_id']),
      orderDate: json['order_date'],
      earnings:
          json['earnings'] != null
              ? EarningsDetailModel.fromJson(json['earnings'])
              : null,
      paymentStatus: json['payment_status'],
      paidAt: json['paid_at'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_date': orderDate,
      'earnings': earnings?.toJson(),
      'payment_status': paymentStatus,
      'paid_at': paidAt,
      'created_at': createdAt,
    };
  }
}

class EarningsDetailModel {
  final String? baseFee;
  final String? perStorePickupFee;
  final String? distanceBasedFee;
  final String? perOrderIncentive;
  final String? total;

  EarningsDetailModel({
    this.baseFee,
    this.perStorePickupFee,
    this.distanceBasedFee,
    this.perOrderIncentive,
    this.total,
  });

  factory EarningsDetailModel.fromJson(Map<String, dynamic> json) {




    return EarningsDetailModel(
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

class EarningsStatisticsModel {
  final double? totalEarnings;
  final double? pendingEarnings;
  final double? paidEarnings;
  final int? totalOrders;
  final EarningsBreakdownModel? earningsBreakdown;

  EarningsStatisticsModel({
    this.totalEarnings,
    this.pendingEarnings,
    this.paidEarnings,
    this.totalOrders,
    this.earningsBreakdown,
  });

  factory EarningsStatisticsModel.fromJson(Map<String, dynamic> json) {
    return EarningsStatisticsModel(
      totalEarnings: _ParseUtils.parseDouble(json['total_earnings']),
      pendingEarnings: _ParseUtils.parseDouble(json['pending_earnings']),
      paidEarnings: _ParseUtils.parseDouble(json['paid_earnings']),
      totalOrders: _ParseUtils.parseInt(json['total_orders']),
      earningsBreakdown:
          json['earnings_breakdown'] != null
              ? EarningsBreakdownModel.fromJson(json['earnings_breakdown'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_earnings': totalEarnings,
      'pending_earnings': pendingEarnings,
      'paid_earnings': paidEarnings,
      'total_orders': totalOrders,
      'earnings_breakdown': earningsBreakdown?.toJson(),
    };
  }
}

class EarningsBreakdownModel {
  final double? baseFee;
  final double? perStorePickupFee;
  final double? distanceBasedFee;
  final double? perOrderIncentive;

  EarningsBreakdownModel({
    this.baseFee,
    this.perStorePickupFee,
    this.distanceBasedFee,
    this.perOrderIncentive,
  });

  factory EarningsBreakdownModel.fromJson(Map<String, dynamic> json) {
    return EarningsBreakdownModel(
      baseFee: _ParseUtils.parseDouble(json['base_fee']),
      perStorePickupFee: _ParseUtils.parseDouble(json['per_store_pickup_fee']),
      distanceBasedFee: _ParseUtils.parseDouble(json['distance_based_fee']),
      perOrderIncentive: _ParseUtils.parseDouble(json['per_order_incentive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fee': baseFee,
      'per_store_pickup_fee': perStorePickupFee,
      'distance_based_fee': distanceBasedFee,
      'per_order_incentive': perOrderIncentive,
    };
  }
}

class EarningsListModel {
  final int? total;
  final int? perPage;
  final int? currentPage;
  final int? lastPage;
  final List<EarningsModel>? earnings;

  EarningsListModel({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.earnings,
  });

  factory EarningsListModel.fromJson(Map<String, dynamic> json) {
    return EarningsListModel(
      total: _ParseUtils.parseInt(json['total']),
      perPage: _ParseUtils.parseInt(json['per_page']),
      currentPage: _ParseUtils.parseInt(json['current_page']),
      lastPage: _ParseUtils.parseInt(json['last_page']),
      earnings:
          json['earnings'] != null
              ? List<EarningsModel>.from(
                json['earnings'].map((x) => EarningsModel.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'per_page': perPage,
      'current_page': currentPage,
      'last_page': lastPage,
      'earnings': earnings?.map((x) => x.toJson()).toList(),
    };
  }
}

class EarningsDateRangeModel {
  final List<String>? dateRanges;

  EarningsDateRangeModel({this.dateRanges});

  factory EarningsDateRangeModel.fromJson(Map<String, dynamic> json) {
    return EarningsDateRangeModel(
      dateRanges: json['data'] != null ? List<String>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': dateRanges};
  }
}

class EarningsResponse {
  final bool? success;
  final String? message;
  final EarningsListData? data;

  EarningsResponse({this.success, this.message, this.data});

  factory EarningsResponse.fromJson(Map<String, dynamic> json) {






    return EarningsResponse(
      success: json['success'],
      message: json['message'],
      data:
          json['data'] != null ? EarningsListData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class EarningsListData {
  final int? total;
  final int? perPage;
  final int? currentPage;
  final int? lastPage;
  final List<EarningsModel>? earnings;

  EarningsListData({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.earnings,
  });

  factory EarningsListData.fromJson(Map<String, dynamic> json) {







    return EarningsListData(
      total: _ParseUtils.parseInt(json['total']),
      perPage: _ParseUtils.parseInt(json['per_page']),
      currentPage: _ParseUtils.parseInt(json['current_page']),
      lastPage: _ParseUtils.parseInt(json['last_page']),
      earnings:
          json['earnings'] != null
              ? List<EarningsModel>.from(
                json['earnings'].map((x) => EarningsModel.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'per_page': perPage,
      'current_page': currentPage,
      'last_page': lastPage,
      'earnings': earnings?.map((x) => x.toJson()).toList(),
    };
  }
}

class EarningsStatsResponse {
  final bool? success;
  final String? message;
  final EarningsStatisticsModel? data;

  EarningsStatsResponse({this.success, this.message, this.data});

  factory EarningsStatsResponse.fromJson(Map<String, dynamic> json) {
    return EarningsStatsResponse(
      success: json['success'],
      message: json['message'],
      data:
          json['data'] != null
              ? EarningsStatisticsModel.fromJson(json['data'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class EarningsDateRangeResponse {
  final bool? success;
  final String? message;
  final List<String>? data;

  EarningsDateRangeResponse({this.success, this.message, this.data});

  factory EarningsDateRangeResponse.fromJson(Map<String, dynamic> json) {
    return EarningsDateRangeResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? List<String>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data};
  }
}
