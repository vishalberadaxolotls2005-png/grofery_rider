import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../repo/earnings_repo.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';
import '../../../../utils/widgets/toast_message.dart';
import '../../../../utils/widgets/global_error_handler.dart';
import '../model/earnings_model.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepo _earningsRepo;
  final BuildContext? context; // Add context for showing toasts

  EarningsBloc(this._earningsRepo, {this.context}) : super(EarningsInitial()) {
    on<FetchEarnings>(_onFetchEarnings);
    on<FetchEarningsStats>(_onFetchEarningsStats);

    on<FetchWeeklyEarnings>(_onFetchWeeklyEarnings);
    on<FetchMonthlyEarnings>(_onFetchMonthlyEarnings);
    on<FetchYearlyEarnings>(_onFetchYearlyEarnings);
    on<LoadMoreEarnings>(_onLoadMoreEarnings);
  }

  Future<void> _onFetchEarnings(
    FetchEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      emit(EarningsLoading());
      final response = await _earningsRepo.getEarnings(
        dateRange: event.dateRange,
        perPage: 10,
        page: 1,
      );

      // Check if this is a 403 response with API message
      if (GlobalErrorHandler.is403Response(response)) {
        final apiMessage = GlobalErrorHandler.get403Message(response);
        if (context != null) {
          ToastManager.show(
            context: context!,
            message: apiMessage ?? 'Access forbidden',
            type: ToastType.error,
          );
        }
        // Emit special state for 403 responses
        emit(
          EarningsInactive(apiMessage ?? 'Your account is currently inactive'),
        );
        return;
      }

      // Handle normal response
      if (response['success'] == true && response['data'] != null) {
        final earningsResponse = response['data'] as EarningsResponse;
        emit(
          EarningsLoaded(
            earningsResponse,
            currentPage: 1,
            hasReachedMax:
                (earningsResponse.data?.currentPage ?? 1) >=
                (earningsResponse.data?.lastPage ?? 1),
          ),
        );
      } else {
        emit(EarningsError('Failed to load earnings'));
      }
    } catch (error) {
      // Check if this is a 403 error
      if (GlobalErrorHandler.is403Error(error)) {
        emit(EarningsInactive('Your account is currently inactive'));
        return;
      }

      emit(EarningsError(error.toString()));
    }
  }

  Future<void> _onLoadMoreEarnings(
    LoadMoreEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    final currentState = state;
    if (currentState is EarningsLoaded &&
        !currentState.hasReachedMax &&
        !currentState.isFetchingMore) {
      try {
        emit(currentState.copyWith(isFetchingMore: true));

        final nextPage = currentState.currentPage + 1;
        final response = await _earningsRepo.getEarnings(
          dateRange: event.dateRange,
          perPage: 10,
          page: nextPage,
        );

        if (response['success'] == true && response['data'] != null) {
          final newResponse = response['data'] as EarningsResponse;
          final List<EarningsModel> mergedEarnings = [
            ...(currentState.response.data?.earnings ?? []),
            ...(newResponse.data?.earnings ?? []),
          ];

          // Create updated response data
          final updatedData = EarningsListData(
            currentPage: newResponse.data?.currentPage,
            lastPage: newResponse.data?.lastPage,
            perPage: newResponse.data?.perPage,
            total: newResponse.data?.total,
            earnings: mergedEarnings,
          );

          final updatedResponse = EarningsResponse(
            success: newResponse.success,
            message: newResponse.message,
            data: updatedData,
          );

          emit(
            currentState.copyWith(
              response: updatedResponse,
              isFetchingMore: false,
              currentPage: nextPage,
              hasReachedMax:
                  (newResponse.data?.currentPage ?? nextPage) >=
                  (newResponse.data?.lastPage ?? nextPage),
            ),
          );
        } else {
          emit(currentState.copyWith(isFetchingMore: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isFetchingMore: false));
      }
    }
  }

  Future<void> _onFetchEarningsStats(
    FetchEarningsStats event,
    Emitter<EarningsState> emit,
  ) async {
    try {

      emit(EarningsLoading());
      final response = await _earningsRepo.getEarningsStats();







      // Check if this is a 403 response
      if (GlobalErrorHandler.is403Response(response)) {

        final apiMessage = GlobalErrorHandler.get403Message(response);

        if (context != null) {
          ToastManager.show(
            context: context!,
            message: apiMessage ?? 'Access forbidden',
            type: ToastType.error,
          );
        }
        // Emit special state for 403 responses

        emit(
          EarningsInactive(apiMessage ?? 'Your account is currently inactive'),
        );
        return;
      }

      // Handle normal response
      if (response['success'] == true && response['data'] != null) {

        final earningsStatsResponse = response['data'] as EarningsStatsResponse;
        emit(EarningsStatsLoaded(earningsStatsResponse));
      } else {

        emit(EarningsError('Failed to load earnings statistics'));
      }
    } catch (error) {





      // Check if this is a 403 error
      if (GlobalErrorHandler.is403Error(error)) {


        emit(EarningsInactive('Your account is currently inactive'));
        return;
      }


      emit(EarningsError(error.toString()));
    }
  }

  Future<void> _onFetchWeeklyEarnings(
    FetchWeeklyEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      emit(EarningsLoading());
      final response = await _earningsRepo.getEarnings(
        dateRange: 'last_7_days',
        perPage: 10,
        page: 1,
      );

      // Check if this is a 403 response with API message
      if (GlobalErrorHandler.is403Response(response)) {
        final apiMessage = GlobalErrorHandler.get403Message(response);
        if (context != null) {
          ToastManager.show(
            context: context!,
            message: apiMessage ?? 'Access forbidden',
            type: ToastType.error,
          );
        }
        // Emit special state for 403 responses
        emit(
          EarningsInactive(apiMessage ?? 'Your account is currently inactive'),
        );
        return;
      }

      // Handle normal response
      if (response['success'] == true && response['data'] != null) {
        final earningsResponse = response['data'] as EarningsResponse;
        emit(
          EarningsLoaded(
            earningsResponse,
            currentPage: 1,
            hasReachedMax:
                (earningsResponse.data?.currentPage ?? 1) >=
                (earningsResponse.data?.lastPage ?? 1),
          ),
        );
      } else {
        emit(EarningsError('Failed to load weekly earnings'));
      }
    } catch (error) {
      emit(EarningsError(error.toString()));
    }
  }

  Future<void> _onFetchMonthlyEarnings(
    FetchMonthlyEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      emit(EarningsLoading());
      final response = await _earningsRepo.getEarnings(
        dateRange: 'last_30_days',
        perPage: 10,
        page: 1,
      );

      // Check if this is a 403 response with API message
      if (GlobalErrorHandler.is403Response(response)) {
        final apiMessage = GlobalErrorHandler.get403Message(response);
        if (context != null) {
          ToastManager.show(
            context: context!,
            message: apiMessage ?? 'Access forbidden',
            type: ToastType.error,
          );
        }
        // Emit special state for 403 responses
        emit(
          EarningsInactive(apiMessage ?? 'Your account is currently inactive'),
        );
        return;
      }

      // Handle normal response
      if (response['success'] == true && response['data'] != null) {
        final earningsResponse = response['data'] as EarningsResponse;
        emit(
          EarningsLoaded(
            earningsResponse,
            currentPage: 1,
            hasReachedMax:
                (earningsResponse.data?.currentPage ?? 1) >=
                (earningsResponse.data?.lastPage ?? 1),
          ),
        );
      } else {
        emit(EarningsError('Failed to load monthly earnings'));
      }
    } catch (error) {
      emit(EarningsError(error.toString()));
    }
  }

  Future<void> _onFetchYearlyEarnings(
    FetchYearlyEarnings event,
    Emitter<EarningsState> emit,
  ) async {
    try {
      emit(EarningsLoading());
      final response = await _earningsRepo.getEarnings(
        dateRange: 'last_365_days',
        perPage: 10,
        page: 1,
      );

      // Check if this is a 403 response with API message
      if (GlobalErrorHandler.is403Response(response)) {
        final apiMessage = GlobalErrorHandler.get403Message(response);
        if (context != null) {
          ToastManager.show(
            context: context!,
            message: apiMessage ?? 'Access forbidden',
            type: ToastType.error,
          );
        }
        // Emit special state for 403 responses
        emit(
          EarningsInactive(apiMessage ?? 'Your account is currently inactive'),
        );
        return;
      }

      // Handle normal response
      if (response['success'] == true && response['data'] != null) {
        final earningsResponse = response['data'] as EarningsResponse;
        emit(
          EarningsLoaded(
            earningsResponse,
            currentPage: 1,
            hasReachedMax:
                (earningsResponse.data?.currentPage ?? 1) >=
                (earningsResponse.data?.lastPage ?? 1),
          ),
        );
      } else {
        emit(EarningsError('Failed to load yearly earnings'));
      }
    } catch (error) {
      emit(EarningsError(error.toString()));
    }
  }
}
