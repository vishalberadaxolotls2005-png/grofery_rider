class HomeStatsResponse {
  final bool success;
  final String message;
  final List<HomeStatsData> data;

  HomeStatsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HomeStatsResponse.fromJson(Map<String, dynamic> json) {
    List<HomeStatsData> dataList = [];
    if (json['data'] is List) {
      dataList = (json['data'] as List<dynamic>)
          .map((item) => HomeStatsData.fromJson(item))
          .toList();
    } else if (json['data'] is Map<String, dynamic>) {
      // Handle the case where data is a single object (like verification error)
      // We can either map it to HomeStatsData if it fits, or just leave it empty
      // for now as our UI expects a list for success states.
    }

    return HomeStatsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataList,
    );
  }
}

class HomeStatsData {
  final String key;
  final dynamic value;

  HomeStatsData({required this.key, required this.value});

  factory HomeStatsData.fromJson(Map<String, dynamic> json) {
    return HomeStatsData(key: json['key'] ?? '', value: json['value']);
  }

  // Helper methods to get specific data types
  ProfileData? get profileData {
    if (key == 'profile' && value is Map<String, dynamic>) {
      return ProfileData.fromJson(value);
    }
    return null;
  }

  SummaryData? get summaryData {
    if (key == 'summary' && value is Map<String, dynamic>) {
      return SummaryData.fromJson(value);
    }
    return null;
  }

  PerformanceMetricsData? get performanceMetricsData {
    if (key == 'performanceMetrics' && value is Map<String, dynamic>) {
      return PerformanceMetricsData.fromJson(value);
    }
    return null;
  }

  TodayProgressData? get todayProgressData {
    if (key == 'todayProgress' && value is Map<String, dynamic>) {
      return TodayProgressData.fromJson(value);
    }
    return null;
  }

  EarningsAnalyticsData? get earningsAnalyticsData {
    if (key == 'earningsAnalytics' && value is Map<String, dynamic>) {
      return EarningsAnalyticsData.fromJson(value);
    }
    return null;
  }
}

class ProfileData {
  final DeliveryBoyData deliveryBoy;

  ProfileData({required this.deliveryBoy});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      deliveryBoy: DeliveryBoyData.fromJson(json['deliveryBoy'] ?? {}),
    );
  }
}

class DeliveryBoyData {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String status;
  final double rating;
  final int totalDeliveries;

  DeliveryBoyData({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    required this.status,
    required this.rating,
    required this.totalDeliveries,
  });

  factory DeliveryBoyData.fromJson(Map<String, dynamic> json) {
    return DeliveryBoyData(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      status: json['status'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalDeliveries: json['totalDeliveries'] ?? 0,
    );
  }
}

class SummaryData {
  final PeriodData today;
  final PeriodData thisWeek;
  final PeriodData thisMonth;
  final PeriodData total;

  SummaryData({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.total,
  });

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      today: PeriodData.fromJson(json['today'] ?? {}),
      thisWeek: PeriodData.fromJson(json['thisWeek'] ?? {}),
      thisMonth: PeriodData.fromJson(json['thisMonth'] ?? {}),
      total: PeriodData.fromJson(json['total'] ?? {}),
    );
  }
}

class PeriodData {
  final double earnings;
  final int orders;
  final double rating;

  PeriodData({
    required this.earnings,
    required this.orders,
    required this.rating,
  });

  factory PeriodData.fromJson(Map<String, dynamic> json) {
    return PeriodData(
      earnings: (json['earnings'] ?? 0.0).toDouble(),
      orders: json['orders'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
}

class PerformanceMetricsData {
  final int ordersDelivered;
  final double averageRating;

  PerformanceMetricsData({
    required this.ordersDelivered,
    required this.averageRating,
  });

  factory PerformanceMetricsData.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricsData(
      ordersDelivered: json['ordersDelivered'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
    );
  }
}

class TodayProgressData {
  final double earnings;
  final int trips;
  final String sessions;
  final int gigs;

  TodayProgressData({
    required this.earnings,
    required this.trips,
    required this.sessions,
    required this.gigs,
  });

  factory TodayProgressData.fromJson(Map<String, dynamic> json) {
    return TodayProgressData(
      earnings: (json['earnings'] ?? 0.0).toDouble(),
      trips: json['trips'] ?? 0,
      sessions: json['sessions'] ?? '',
      gigs: json['gigs'] ?? 0,
    );
  }
}

class EarningsAnalyticsData {
  final AnalyticsSummary summary;
  final AnalyticsCharts charts;

  EarningsAnalyticsData({required this.summary, required this.charts});

  factory EarningsAnalyticsData.fromJson(Map<String, dynamic> json) {
    return EarningsAnalyticsData(
      summary: AnalyticsSummary.fromJson(json['summary'] ?? {}),
      charts: AnalyticsCharts.fromJson(json['charts'] ?? {}),
    );
  }
}

class AnalyticsSummary {
  final double totalEarnings;
  final double averageEarnings;
  final int totalOrders;
  final double averageRating;

  AnalyticsSummary({
    required this.totalEarnings,
    required this.averageEarnings,
    required this.totalOrders,
    required this.averageRating,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      averageEarnings: (json['averageEarnings'] ?? 0.0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
    );
  }
}

class AnalyticsCharts {
  final ChartData weekly;
  final ChartData monthly;
  final ChartData yearly;

  AnalyticsCharts({
    required this.weekly,
    required this.monthly,
    required this.yearly,
  });

  factory AnalyticsCharts.fromJson(Map<String, dynamic> json) {
    return AnalyticsCharts(
      weekly: ChartData.fromJson(json['weekly'] ?? {}),
      monthly: ChartData.fromJson(json['monthly'] ?? {}),
      yearly: ChartData.fromJson(json['yearly'] ?? {}),
    );
  }
}

class ChartData {
  final String period;
  final List<ChartPoint> data;

  ChartData({required this.period, required this.data});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      period: json['period'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ChartPoint.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ChartPoint {
  final String label;
  final double earnings;
  final int orders;
  final double? percentage;

  ChartPoint({
    required this.label,
    required this.earnings,
    required this.orders,
    this.percentage,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      label: json['day'] ?? json['week'] ?? json['month'] ?? '',
      earnings: (json['earnings'] ?? 0.0).toDouble(),
      orders: json['orders'] ?? 0,
      percentage:
          json['percentage'] != null
              ? (json['percentage'] ?? 0.0).toDouble()
              : null,
    );
  }
}
