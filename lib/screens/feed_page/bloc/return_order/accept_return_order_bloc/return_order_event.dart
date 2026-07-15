part of 'return_order_bloc.dart';

abstract class ReturnOrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AcceptReturnOrder extends ReturnOrderEvent {
  final String returnId;

  AcceptReturnOrder({required this.returnId});
}

final class UpdateReturnOrderStatus extends ReturnOrderEvent {
  final String returnId;
  final String status;

  UpdateReturnOrderStatus({required this.returnId, required this.status});
}
