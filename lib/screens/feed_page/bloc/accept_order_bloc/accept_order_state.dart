import 'package:equatable/equatable.dart';

abstract class AcceptOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AcceptOrderInitial extends AcceptOrderState {}

class AcceptOrderLoading extends AcceptOrderState {}

class AcceptOrderSuccess extends AcceptOrderState {
  final String message;

  AcceptOrderSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AcceptOrderCompleted extends AcceptOrderState {
  final String orderId;

  AcceptOrderCompleted(this.orderId);

  @override
  List<Object> get props => [orderId];
}

class AcceptOrderError extends AcceptOrderState {
  final String errorMessage;

  AcceptOrderError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
