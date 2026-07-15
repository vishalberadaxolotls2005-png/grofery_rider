import 'package:equatable/equatable.dart';
import '../../model/delivery_zone_model.dart';

abstract class DeliveryZoneState extends Equatable {
  const DeliveryZoneState();
  @override
  List<Object?> get props => [];
}

class DeliveryZoneInitial extends DeliveryZoneState {
  const DeliveryZoneInitial();
  @override
  List<Object?> get props => [];
}

class DeliveryZoneLoading extends DeliveryZoneState {
  const DeliveryZoneLoading();
  @override
  List<Object?> get props => [];
}

class DeliveryZoneLoaded extends DeliveryZoneState {
  final List<DeliveryZoneModel> deliveryZones;
  final bool hasReachedMax;
  final DeliveryZoneModel? selectedZone;

  const DeliveryZoneLoaded({
    required this.deliveryZones,
    required this.hasReachedMax,
    this.selectedZone,
  });

  @override
  List<Object?> get props => [deliveryZones, hasReachedMax, selectedZone];
}

class DeliveryZoneError extends DeliveryZoneState {
  final String message;

  const DeliveryZoneError({required this.message});

  @override
  List<Object?> get props => [message];
}
