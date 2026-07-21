import 'package:equatable/equatable.dart';

abstract class AcceptOrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AcceptOrder extends AcceptOrderEvent {
  final int orderId;

  AcceptOrder(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class AcceptGroupOrder extends AcceptOrderEvent {
  final List<int> orderIds;

  AcceptGroupOrder(this.orderIds);

  @override
  List<Object> get props => [orderIds];
}
