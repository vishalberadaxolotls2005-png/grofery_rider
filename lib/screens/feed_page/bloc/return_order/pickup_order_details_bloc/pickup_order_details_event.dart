part of 'pickup_order_details_bloc.dart';

sealed class PickupOrderDetailsEvent extends Equatable {
  const PickupOrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchPickupOrderDetails extends PickupOrderDetailsEvent {
  final String returnId;

  const FetchPickupOrderDetails(this.returnId);

  @override
  List<Object?> get props => [returnId];
}
