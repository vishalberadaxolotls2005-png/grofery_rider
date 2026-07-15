import 'package:equatable/equatable.dart';

abstract class ItemsCollectedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ItemsCollected extends ItemsCollectedEvent {
  final String orderItemId;

  ItemsCollected(this.orderItemId);

  @override
  List<Object> get props => [orderItemId];
}

class ItemsCollectedWithOtp extends ItemsCollectedEvent {
  final String orderItemId;
  final String otp;

  ItemsCollectedWithOtp({
    required this.orderItemId,
    required this.otp,
  });

  @override
  List<Object> get props => [orderItemId, otp];
}

class ItemsDelivered extends ItemsCollectedEvent {
  final String orderItemId;

  ItemsDelivered(this.orderItemId);

  @override
  List<Object> get props => [orderItemId];
} 
