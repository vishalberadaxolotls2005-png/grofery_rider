import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grofery_rider/screens/dashboard/model/ratings_model.dart';
import '../repo/ratings_repo.dart';
import 'ratings_event.dart';
import 'ratings_state.dart';

class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  final RatingsRepo _ratingsRepo;


  RatingsBloc(this._ratingsRepo) : super(RatingsInitial()) {
    on<FetchRatings>(_onFetchRatings);
    on<RefreshRatings>(_onRefreshRatings);
    on<LoadMoreRatings>(_onLoadMoreRatings);
  }

  Future<void> _onFetchRatings(
    FetchRatings event,
    Emitter<RatingsState> emit,
  ) async {
    try {
      emit(RatingsLoading());

      // Fetch both overall ratings and feedback data (initial page)
      final overallRatings = await _ratingsRepo.fetchOverallRatings();
      final feedback = await _ratingsRepo.fetchDeliveryFeedback(page: 1);

      emit(
        RatingsLoaded(
          overallRatings: overallRatings,
          feedback: feedback,
          currentPage: 1,
          hasReachedMax: feedback.data.currentPage >= feedback.data.lastPage,
        ),
      );
    } catch (e) {
      emit(RatingsError(e.toString()));
    }
  }

  Future<void> _onRefreshRatings(
    RefreshRatings event,
    Emitter<RatingsState> emit,
  ) async {
    try {
      // Don't emit loading here to allow current list to remain visible during pull-to-refresh
      // unless currently in error state
      if (state is RatingsError) emit(RatingsLoading());

      final overallRatings = await _ratingsRepo.fetchOverallRatings();
      final feedback = await _ratingsRepo.fetchDeliveryFeedback(page: 1);

      emit(
        RatingsLoaded(
          overallRatings: overallRatings,
          feedback: feedback,
          currentPage: 1,
          hasReachedMax: feedback.data.currentPage >= feedback.data.lastPage,
        ),
      );
    } catch (e) {
      emit(RatingsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreRatings(
    LoadMoreRatings event,
    Emitter<RatingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is RatingsLoaded &&
        !currentState.hasReachedMax &&
        !currentState.isFetchingMore) {
      try {
        emit(currentState.copyWith(isFetchingMore: true));

        final nextPage = currentState.currentPage + 1;
        final newFeedback = await _ratingsRepo.fetchDeliveryFeedback(
          page: nextPage,
        );

        final mergedItems = [
          ...currentState.feedback.data.feedbackItems,
          ...newFeedback.data.feedbackItems,
        ];

        // Create a new FeedbackPaginationData with merged items
        final updatedFeedbackData = FeedbackPaginationData(
          currentPage: newFeedback.data.currentPage,
          lastPage: newFeedback.data.lastPage,
          perPage: newFeedback.data.perPage,
          total: newFeedback.data.total,
          feedbackItems: mergedItems,
        );

        // Create a new DeliveryFeedbackResponse with updated pagination data
        final updatedFeedbackResponse = DeliveryFeedbackResponse(
          success: newFeedback.success,
          message: newFeedback.message,
          data: updatedFeedbackData,
        );

        emit(
          currentState.copyWith(
            feedback: updatedFeedbackResponse,
            currentPage: nextPage,
            hasReachedMax:
                newFeedback.data.currentPage >= newFeedback.data.lastPage,
            isFetchingMore: false,
          ),
        );
      } catch (e) {
        emit(currentState.copyWith(isFetchingMore: false));
        // Optionally emit an error or just stop loading
      }
    }
  }
}
