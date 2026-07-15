import 'package:equatable/equatable.dart';

abstract class MyOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllMyOrdersList extends MyOrdersEvent {
  final String? type;
  final int? typeId;
  final bool forceRefresh;

  AllMyOrdersList({this.type, this.typeId, this.forceRefresh = false});

  @override
  List<Object?> get props => [type, typeId, forceRefresh];
}

class SearchMyOrders extends MyOrdersEvent {
  final String searchQuery;
  final String? type;
  final int? typeId;

  SearchMyOrders(this.searchQuery, this.typeId, this.type);

  @override
  List<Object?> get props => [searchQuery, typeId, type];
}

class LoadMoreMyOrders extends MyOrdersEvent {

  final String currentFilter;

  LoadMoreMyOrders(this.currentFilter);

  @override
  List<Object?> get props => [];
}
