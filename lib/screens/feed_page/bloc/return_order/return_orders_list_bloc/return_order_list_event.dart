part of 'return_order_list_bloc.dart';

abstract class ReturnOrderListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchReturnOrders extends ReturnOrderListEvent {
  final bool forceRefresh;

  FetchReturnOrders({this.forceRefresh = false});
}

class LoadMoreReturnOrders extends ReturnOrderListEvent {}

class RefreshReturnOrders extends ReturnOrderListEvent {}
