part of 'pickup_order_list_bloc.dart';

abstract class PickupOrderListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickupOrderListInitial extends PickupOrderListState {}

class PickupOrderListLoading extends PickupOrderListState {}

class PickupOrderListRefreshing extends PickupOrderListState {
  final List<Pickups> orders;
  final bool hasReachedMax;
  final int totalOrders;

  PickupOrderListRefreshing({
    required this.orders,
    required this.hasReachedMax,
    required this.totalOrders,
  });

  @override
  List<Object?> get props => [orders, hasReachedMax, totalOrders];
}

class PickupOrderListLoaded extends PickupOrderListState {
  final List<Pickups> orders;
  final bool hasReachedMax;
  final int totalOrders;

  PickupOrderListLoaded({
    required this.orders,
    required this.hasReachedMax,
    required this.totalOrders,
  });

  @override
  List<Object?> get props => [orders, hasReachedMax, totalOrders];
}

class PickupOrderListError extends PickupOrderListState {
  final String message;

  PickupOrderListError(this.message);

  @override
  List<Object?> get props => [message];
}
