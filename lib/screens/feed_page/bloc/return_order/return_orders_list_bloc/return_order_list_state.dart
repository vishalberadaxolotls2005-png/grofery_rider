part of 'return_order_list_bloc.dart';

abstract class ReturnOrderListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReturnOrderListInitial extends ReturnOrderListState {}

class ReturnOrderListLoading extends ReturnOrderListState {}

class ReturnOrderListRefreshing extends ReturnOrderListState {
  final List<Pickups> orders; // adjust type based on your model
  final bool hasReachedMax;

  ReturnOrderListRefreshing({
    required this.orders,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [orders, hasReachedMax];
}

class ReturnOrderListLoaded extends ReturnOrderListState {
  final List<Pickups> orders;
  final bool hasReachedMax;

  ReturnOrderListLoaded({required this.orders, required this.hasReachedMax});

  @override
  List<Object?> get props => [orders, hasReachedMax];
}

class ReturnOrderListError extends ReturnOrderListState {
  final String message;

  ReturnOrderListError(this.message);

  @override
  List<Object?> get props => [message];
}
