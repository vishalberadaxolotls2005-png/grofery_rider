import 'package:equatable/equatable.dart';

abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrderDetails extends OrderDetailsEvent {
  final int orderId;

  const FetchOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class MarkItemReachedDestination extends OrderDetailsEvent {
  final int orderId;
  final int itemId;

  const MarkItemReachedDestination(this.orderId, this.itemId);

  @override
  List<Object?> get props => [orderId, itemId];
}
