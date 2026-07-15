part of 'pickup_order_details_bloc.dart';

sealed class PickupOrderDetailsState extends Equatable {
  const PickupOrderDetailsState();

  @override
  List<Object?> get props => [];
}

final class PickupOrderDetailsInitial extends PickupOrderDetailsState {}

final class PickupOrderDetailsLoading extends PickupOrderDetailsState {}

final class PickupOrderDetailsSuccess extends PickupOrderDetailsState {
  final Pickups pickup;

  const PickupOrderDetailsSuccess(this.pickup);

  @override
  List<Object?> get props => [pickup];
}

final class PickupOrderDetailsError extends PickupOrderDetailsState {
  final String message;

  const PickupOrderDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
