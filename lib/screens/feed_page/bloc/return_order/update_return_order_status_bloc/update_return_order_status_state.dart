part of 'update_return_order_status_bloc.dart';

abstract class UpdateReturnOrderStatusState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class UpdateReturnOrderStatusInitial
    extends UpdateReturnOrderStatusState {}

final class UpdateReturnOrderStatusLoading
    extends UpdateReturnOrderStatusState {}

final class UpdateReturnOrderStatusSuccess
    extends UpdateReturnOrderStatusState {
  final String message;
  final String returnId;

  UpdateReturnOrderStatusSuccess({required this.message, required this.returnId});
}

final class UpdateReturnOrderStatusFailed extends UpdateReturnOrderStatusState {
  final String error;
  UpdateReturnOrderStatusFailed(this.error);
}

class ReturnOrderStatusCompleted extends UpdateReturnOrderStatusState {
  final String returnId;

  ReturnOrderStatusCompleted(this.returnId);
}
