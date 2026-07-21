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
  final int? quantity;
  final String? reason;

  ItemsCollectedWithOtp({
    required this.orderItemId,
    required this.otp,
    this.quantity,
    this.reason,
  });

  @override
  List<Object> get props => [orderItemId, otp, quantity ?? -1, reason ?? ''];
}

class ItemsDelivered extends ItemsCollectedEvent {
  final String orderItemId;
  final int? quantity;
  final String? reason;

  ItemsDelivered({
    required this.orderItemId,
    this.quantity,
    this.reason,
  });

  @override
  List<Object> get props => [orderItemId, quantity ?? -1, reason ?? ''];
} 
