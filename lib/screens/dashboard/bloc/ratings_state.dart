import '../model/ratings_model.dart';

abstract class RatingsState {}

class RatingsInitial extends RatingsState {}

class RatingsLoading extends RatingsState {}

class RatingsLoaded extends RatingsState {
  final RatingsResponse overallRatings;
  final DeliveryFeedbackResponse feedback;
  final bool hasReachedMax;
  final bool isFetchingMore;
  final int currentPage;
  
  RatingsLoaded({
    required this.overallRatings,
    required this.feedback,
    this.hasReachedMax = false,
    this.isFetchingMore = false,
    this.currentPage = 1,
  });

  RatingsLoaded copyWith({
    RatingsResponse? overallRatings,
    DeliveryFeedbackResponse? feedback,
    bool? hasReachedMax,
    bool? isFetchingMore,
    int? currentPage,
  }) {
    return RatingsLoaded(
      overallRatings: overallRatings ?? this.overallRatings,
      feedback: feedback ?? this.feedback,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class RatingsError extends RatingsState {
  final String message;
  
  RatingsError(this.message);
}
