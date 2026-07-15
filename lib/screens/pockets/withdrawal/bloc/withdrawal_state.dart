import 'package:equatable/equatable.dart';
import '../model/withdrawal_model.dart';

abstract class WithdrawalState extends Equatable {
  const WithdrawalState();

  @override
  List<Object?> get props => [];
}

class WithdrawalInitial extends WithdrawalState {}

class WithdrawalLoading extends WithdrawalState {}

class WithdrawalSuccess extends WithdrawalState {
  final WithdrawalResponse response;
  final bool isFetchingMore;
  final bool hasReachedMax;
  final int currentPage;

  const WithdrawalSuccess(
    this.response, {
    this.isFetchingMore = false,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  WithdrawalSuccess copyWith({
    WithdrawalResponse? response,
    bool? isFetchingMore,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return WithdrawalSuccess(
      response ?? this.response,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [response, isFetchingMore, hasReachedMax, currentPage];
}

class SingleWithdrawalSuccess extends WithdrawalState {
  final SingleWithdrawalResponse response;

  const SingleWithdrawalSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class CreateWithdrawalSuccess extends WithdrawalState {
  final Map<String, dynamic> response;

  const CreateWithdrawalSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class WithdrawalError extends WithdrawalState {
  final String errorMessage;

  const WithdrawalError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
