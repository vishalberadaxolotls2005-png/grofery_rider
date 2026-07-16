import 'package:equatable/equatable.dart';

abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrderDetails extends OrderDetailsEvent {
  final int orderId;
  final List<int>? groupOrderIds;

  const FetchOrderDetails(this.orderId, {this.groupOrderIds});

  @override
  List<Object?> get props => [orderId, groupOrderIds];
}

class MarkItemReachedDestination extends OrderDetailsEvent {
  final int orderId;
  final int itemId;

  const MarkItemReachedDestination(this.orderId, this.itemId);

  @override
  List<Object?> get props => [orderId, itemId];
}
