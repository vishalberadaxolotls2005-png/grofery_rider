import 'package:flutter_bloc/flutter_bloc.dart';
import 'withdrawal_event.dart';
import 'withdrawal_state.dart';
import '../repo/withdrawal_repo.dart';
import '../model/withdrawal_model.dart';

class WithdrawalBloc extends Bloc<WithdrawalEvent, WithdrawalState> {
  final WithdrawalRepo _withdrawalRepo;

  WithdrawalBloc(this._withdrawalRepo) : super(WithdrawalInitial()) {
    on<CreateWithdrawal>(_onCreateWithdrawal);
    on<FetchWithdrawals>(_onFetchWithdrawals);
    on<FetchWithdrawalById>(_onFetchWithdrawalById);
    on<LoadMoreWithdrawals>(_onLoadMoreWithdrawals);
  }

  Future<void> _onCreateWithdrawal(
    CreateWithdrawal event,
    Emitter<WithdrawalState> emit,
  ) async {
    emit(WithdrawalLoading());
    try {

      final request = CreateWithdrawalRequest(
        amount: event.amount,
        requestNote: event.note,
      );
      final response = await _withdrawalRepo.createWithdrawal(request);
      

      
      if (response['success'] == true) {
        emit(CreateWithdrawalSuccess(response));
      } else {
        emit(WithdrawalError(response['message'] ?? 'Failed to create withdrawal'));
      }
    } catch (error) {

      emit(WithdrawalError(error.toString()));
    }
  }

  Future<void> _onFetchWithdrawals(
    FetchWithdrawals event,
    Emitter<WithdrawalState> emit,
  ) async {
    emit(WithdrawalLoading());
    try {
      final response = await _withdrawalRepo.getWithdrawals(perPage: 10, page: 1);
      if (response['success'] == true) {
        try {
          final withdrawalResponse = WithdrawalResponse.fromJson(response);
          emit(
            WithdrawalSuccess(
              withdrawalResponse,
              currentPage: 1,
              hasReachedMax: (withdrawalResponse.data?.data.length ?? 0) < 10,
            ),
          );
        } catch (parseError) {
          emit(WithdrawalError('Data format error: Please contact support'));
        }
      } else {
        emit(WithdrawalError(response['message'] ?? 'Failed to fetch withdrawals'));
      }
    } catch (error) {

      if (error.toString().contains('Map<String, dynamic> is not a subtype of') || 
          error.toString().contains('type \'String\' is not a subtype of type \'int\'')) {
        emit(WithdrawalError('Data format error: Please contact support'));
      } else {
        emit(WithdrawalError(error.toString()));
      }
    }
  }

  Future<void> _onFetchWithdrawalById(
    FetchWithdrawalById event,
    Emitter<WithdrawalState> emit,
  ) async {
    emit(WithdrawalLoading());
    try {

      final response = await _withdrawalRepo.getWithdrawalById(event.id);
      

      
      if (response['success'] == true) {
        try {
          final singleWithdrawalResponse = SingleWithdrawalResponse.fromJson(response);

          emit(SingleWithdrawalSuccess(singleWithdrawalResponse));
        } catch (parseError) {

          emit(WithdrawalError('Data format error: Please contact support'));
        }
      } else {
        emit(WithdrawalError(response['message'] ?? 'Failed to fetch withdrawal details'));
      }
    } catch (error) {

      if (error.toString().contains('Map<String, dynamic> is not a subtype of') || 
          error.toString().contains('type \'String\' is not a subtype of type \'int\'')) {
        emit(WithdrawalError('Data format error: Please contact support'));
      } else {
        emit(WithdrawalError(error.toString()));
      }
    }
  }

  Future<void> _onLoadMoreWithdrawals(
    LoadMoreWithdrawals event,
    Emitter<WithdrawalState> emit,
  ) async {
    try {
      if (state is WithdrawalSuccess) {
        final currentState = state as WithdrawalSuccess;
        if (currentState.hasReachedMax || currentState.isFetchingMore) return;

        emit(currentState.copyWith(isFetchingMore: true));

        final response = await _withdrawalRepo.getWithdrawals(
          perPage: 10,
          page: currentState.currentPage + 1,
        );

        if (response['success'] == true) {
          final withdrawalResponse = WithdrawalResponse.fromJson(response);
          final newWithdrawals = withdrawalResponse.data?.data ?? [];

          if (newWithdrawals.isEmpty) {
            emit(currentState.copyWith(isFetchingMore: false, hasReachedMax: true));
          } else {
            final updatedWithdrawals = List<WithdrawalModel>.from(
              currentState.response.data?.data ?? [],
            )..addAll(newWithdrawals);

            emit(
              currentState.copyWith(
                isFetchingMore: false,
                currentPage: currentState.currentPage + 1,
                hasReachedMax: newWithdrawals.length < 10,
                response: WithdrawalResponse(
                  success: withdrawalResponse.success,
                  message: withdrawalResponse.message,
                  data: WithdrawalPaginationData(
                    currentPage: withdrawalResponse.data!.currentPage,
                    data: updatedWithdrawals,
                    firstPageUrl: withdrawalResponse.data!.firstPageUrl,
                    from: withdrawalResponse.data?.from,
                    lastPage: withdrawalResponse.data!.lastPage,
                    lastPageUrl: withdrawalResponse.data!.lastPageUrl,
                    links: withdrawalResponse.data!.links,
                    nextPageUrl: withdrawalResponse.data?.nextPageUrl,
                    path: withdrawalResponse.data!.path,
                    perPage: withdrawalResponse.data!.perPage,
                    prevPageUrl: withdrawalResponse.data?.prevPageUrl,
                    to: withdrawalResponse.data?.to,
                    total: withdrawalResponse.data!.total,
                  ),
                ),
              ),
            );
          }
        } else {
          emit(currentState.copyWith(isFetchingMore: false));
        }
      }
    } catch (e) {
      // Potentially silent or show minimal error for "load more"
    }
  }
} 
