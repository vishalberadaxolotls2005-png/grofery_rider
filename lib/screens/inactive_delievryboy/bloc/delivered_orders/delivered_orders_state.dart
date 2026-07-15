import 'package:equatable/equatable.dart';
import '../../../feed_page/model/available_orders.dart';

abstract class DeliveredOrdersState extends Equatable {
  const DeliveredOrdersState();

  @override
  List<Object?> get props => [];
}

class DeliveredOrdersInitial extends DeliveredOrdersState {}

class DeliveredOrdersLoading extends DeliveredOrdersState {}

class DeliveredOrdersRefreshing extends DeliveredOrdersState {
  final List<Orders> deliveredOrders;
  final bool hasReachedMax;
  final int totalOrders;

  const DeliveredOrdersRefreshing({
    required this.deliveredOrders,
    required this.hasReachedMax,
    required this.totalOrders,
  });

  @override
  List<Object> get props => [deliveredOrders, hasReachedMax, totalOrders];
}

class DeliveredOrdersLoaded extends DeliveredOrdersState {
  final List<Orders> deliveredOrders;
  final bool hasReachedMax;
  final int totalOrders;

  const DeliveredOrdersLoaded({
    required this.deliveredOrders,
    required this.hasReachedMax,
    required this.totalOrders,
  });

  @override
  List<Object> get props => [deliveredOrders, hasReachedMax, totalOrders];
}

class DeliveredOrdersError extends DeliveredOrdersState {
  final String errorMessage;

  const DeliveredOrdersError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
