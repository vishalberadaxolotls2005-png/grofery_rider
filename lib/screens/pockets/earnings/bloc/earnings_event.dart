abstract class EarningsEvent {}

class FetchEarnings extends EarningsEvent {
  final String? dateRange;

  FetchEarnings({this.dateRange});
}

class FetchEarningsStats extends EarningsEvent {}

class FetchWeeklyEarnings extends EarningsEvent {}

class FetchMonthlyEarnings extends EarningsEvent {}

class FetchYearlyEarnings extends EarningsEvent {}

class LoadMoreEarnings extends EarningsEvent {
  final String? dateRange;
  LoadMoreEarnings({this.dateRange});
}
