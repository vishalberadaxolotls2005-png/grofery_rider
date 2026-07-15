import '../model/earnings_model.dart';

abstract class EarningsState {}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final EarningsResponse response;
  final bool isFetchingMore;
  final bool hasReachedMax;
  final int currentPage;

  EarningsLoaded(
    this.response, {
    this.isFetchingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  EarningsLoaded copyWith({
    EarningsResponse? response,
    bool? isFetchingMore,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return EarningsLoaded(
      response ?? this.response,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class EarningsStatsLoaded extends EarningsState {
  final EarningsStatsResponse response;

  EarningsStatsLoaded(this.response);
}

class EarningsDateRangeLoaded extends EarningsState {
  final EarningsResponse response;

  EarningsDateRangeLoaded(this.response);
}

class EarningsInactive extends EarningsState {
  final String message;

  EarningsInactive(this.message);
}

class EarningsError extends EarningsState {
  final String message;

  EarningsError(this.message);
}
