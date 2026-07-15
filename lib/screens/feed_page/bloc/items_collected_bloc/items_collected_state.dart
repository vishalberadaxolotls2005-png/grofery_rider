import 'package:equatable/equatable.dart';

abstract class ItemsCollectedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ItemsCollectedInitial extends ItemsCollectedState {}

class ItemsCollectedLoading extends ItemsCollectedState {}

class ItemsCollectedSuccess extends ItemsCollectedState {
  final String message;

  ItemsCollectedSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ItemsCollectedError extends ItemsCollectedState {
  final String errorMessage;

  ItemsCollectedError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
