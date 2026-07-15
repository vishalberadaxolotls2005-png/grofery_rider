import 'package:equatable/equatable.dart';

abstract class AvailableOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AllAvailableOrdersList extends AvailableOrdersEvent {
  final String? type;
  final int? typeId;
  final bool forceRefresh;

  AllAvailableOrdersList({this.type, this.typeId, this.forceRefresh = false});

  @override
  List<Object?> get props => [type, typeId, forceRefresh];
}

class SearchAvailableOrders extends AvailableOrdersEvent {
  final String searchQuery;
  final String? type;
  final int? typeId;

  SearchAvailableOrders(this.searchQuery, this.typeId, this.type);

  @override
  List<Object?> get props => [searchQuery, typeId, type];
}

class LoadMoreAvailableOrders extends AvailableOrdersEvent {
  final String searchWord;

  LoadMoreAvailableOrders(this.searchWord);

  @override
  List<Object?> get props => [];
}
