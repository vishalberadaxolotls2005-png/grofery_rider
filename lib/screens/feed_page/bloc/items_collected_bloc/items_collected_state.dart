import 'package:equatable/equatable.dart';

abstract class ItemsCollectedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ItemsCollectedInitial extends ItemsCollectedState {}

class ItemsCollectedLoading extends ItemsCollectedState {}

class ItemsCollectedSuccess extends ItemsCollectedState {
  final String message;
  final String? itemId;
  final String? action;
  final Map<String, dynamic>? responseData;

  ItemsCollectedSuccess(this.message, {this.itemId, this.action, this.responseData});

  @override
  List<Object?> get props => [message, itemId, action, responseData];
}

class ItemsCollectedError extends ItemsCollectedState {
  final String errorMessage;

  ItemsCollectedError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
