part of 'pickup_order_list_bloc.dart';


abstract class PickupOrderListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPickupOrders extends PickupOrderListEvent {
  final bool forceRefresh;

  FetchPickupOrders({this.forceRefresh = false});
}

class LoadMorePickupOrders extends PickupOrderListEvent {}

class RefreshPickupOrders extends PickupOrderListEvent {}
