part of 'update_return_order_status_bloc.dart';

abstract class UpdateReturnOrderStatusEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class UpdateReturnOrderStatus extends UpdateReturnOrderStatusEvent {
  final String returnId;
  final String status;

  UpdateReturnOrderStatus({required this.status, required this.returnId});
}
