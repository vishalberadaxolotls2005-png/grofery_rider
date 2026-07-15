import 'package:equatable/equatable.dart';

import '../../model/delivery_zone_model.dart';


abstract class DeliveryZoneEvent extends Equatable {
  const DeliveryZoneEvent();

  @override
  List<Object?> get props => [];
}

class FetchDeliveryZones extends DeliveryZoneEvent {
  const FetchDeliveryZones();

  @override
  List<Object?> get props => [];
}

class LoadMoreDeliveryZones extends DeliveryZoneEvent {
  const LoadMoreDeliveryZones();

  @override
  List<Object?> get props => [];
}
class SelectDeliveryZone extends DeliveryZoneEvent {
  final DeliveryZoneModel selectedZone;

  const SelectDeliveryZone({required this.selectedZone});

  @override
  List<Object?> get props => [selectedZone];
}
