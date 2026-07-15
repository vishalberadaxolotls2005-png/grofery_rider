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
