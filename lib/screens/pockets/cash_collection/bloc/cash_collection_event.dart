abstract class CashCollectionEvent {}

class FetchCashCollection extends CashCollectionEvent {
  final String? dateRange;
  
  FetchCashCollection({this.dateRange});
}

class FetchCashCollectionStats extends CashCollectionEvent {}

class FetchCashCollectionByDateRange extends CashCollectionEvent {
  final String dateRange;
  final String? submissionStatus;
  
  FetchCashCollectionByDateRange(this.dateRange, {this.submissionStatus});
}

class FetchLast30Minutes extends CashCollectionEvent {}

class FetchLast1Hour extends CashCollectionEvent {}

class FetchLast5Hours extends CashCollectionEvent {}

class FetchLast1Day extends CashCollectionEvent {}

class FetchLast7Days extends CashCollectionEvent {}

class FetchLast30Days extends CashCollectionEvent {}

class FetchLast365Days extends CashCollectionEvent {} 
class LoadMoreCashCollection extends CashCollectionEvent {}
