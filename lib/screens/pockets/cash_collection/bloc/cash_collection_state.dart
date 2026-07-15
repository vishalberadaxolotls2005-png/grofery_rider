import '../model/cash_collection_model.dart';

abstract class CashCollectionState {}

class CashCollectionInitial extends CashCollectionState {}

class CashCollectionLoading extends CashCollectionState {}

class CashCollectionLoaded extends CashCollectionState {
  final CashCollectionResponse response;
  final String selectedDateRange;
  final bool isFetchingMore;
  final bool hasReachedMax;
  final int currentPage;
  final String? submissionStatus;
  
  CashCollectionLoaded({
    required this.response,
    required this.selectedDateRange,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.submissionStatus,
  });

  CashCollectionLoaded copyWith({
    CashCollectionResponse? response,
    String? selectedDateRange,
    bool? isFetchingMore,
    bool? hasReachedMax,
    int? currentPage,
    String? submissionStatus,
  }) {
    return CashCollectionLoaded(
      response: response ?? this.response,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}

class CashCollectionStatsLoaded extends CashCollectionState {
  final CashCollectionResponse response;
  
  CashCollectionStatsLoaded({required this.response});
}

class CashCollectionDateRangeLoaded extends CashCollectionState {
  final CashCollectionResponse response;
  final String dateRange;
  final bool isFetchingMore;
  final bool hasReachedMax;
  final int currentPage;
  final String? submissionStatus;
  
  CashCollectionDateRangeLoaded({
    required this.response,
    required this.dateRange,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.submissionStatus,
  });

  CashCollectionDateRangeLoaded copyWith({
    CashCollectionResponse? response,
    String? dateRange,
    bool? isFetchingMore,
    bool? hasReachedMax,
    int? currentPage,
    String? submissionStatus,
  }) {
    return CashCollectionDateRangeLoaded(
      response: response ?? this.response,
      dateRange: dateRange ?? this.dateRange,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}

class CashCollectionError extends CashCollectionState {
  final String message;
  
  CashCollectionError({required this.message});
} 
