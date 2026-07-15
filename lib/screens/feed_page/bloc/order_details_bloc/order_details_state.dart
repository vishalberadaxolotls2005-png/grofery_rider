import 'package:equatable/equatable.dart';
import '../../model/available_orders.dart';

abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsSuccess extends OrderDetailsState {
  final Orders order;

  const OrderDetailsSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderDetailsError extends OrderDetailsState {
  final String errorMessage;

  const OrderDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
