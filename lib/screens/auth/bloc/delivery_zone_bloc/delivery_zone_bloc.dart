import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/delivery_zone_model.dart';
import '../../repo/delivery_zone_repo.dart';
import 'delivery_zone_event.dart';
import 'delivery_zone_state.dart';

class DeliveryZoneBloc extends Bloc<DeliveryZoneEvent, DeliveryZoneState> {
  int _offset = 0;
  final int _limit = 15;
  bool _hasReachedMax = false;
  final DeliveryZoneRepo _deliveryZoneRepo = DeliveryZoneRepo();

  DeliveryZoneBloc() : super(DeliveryZoneInitial()) {
    on<FetchDeliveryZones>(_onFetchDeliveryZones);
    on<LoadMoreDeliveryZones>(_onLoadMoreDeliveryZones);
    on<SelectDeliveryZone>(_onSelectDeliveryZone);
  }

  Future<void> _onFetchDeliveryZones(
    FetchDeliveryZones event,
    Emitter<DeliveryZoneState> emit,
  ) async {
    try {
      emit(DeliveryZoneLoading());
      _offset = 0;
      _hasReachedMax = false;
      late List<DeliveryZoneModel> deliveryZones;

      final response = await _deliveryZoneRepo.getDeliveryZone(
        offset: _offset,
        limit: _limit,
      );

      try {
        deliveryZones =
            (response['data']['data'] as List<dynamic>?)
                ?.map(
                  (item) =>
                      DeliveryZoneModel.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            [];
      } catch (e, s) {
        debugPrint(s.toString());
      }

      final int currentPage = response['data']['current_page'] as int;
      final int lastPage = response['data']['last_page'] as int;
      emit(
        DeliveryZoneLoaded(
          deliveryZones: deliveryZones,
          hasReachedMax: currentPage >= lastPage,
        ),
      );
    } catch (e) {
      emit(DeliveryZoneError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreDeliveryZones(
    LoadMoreDeliveryZones event,
    Emitter<DeliveryZoneState> emit,
  ) async {
    if (_hasReachedMax) return;

    try {
      final currentState = state;
      if (currentState is DeliveryZoneLoaded) {
        _offset += _limit;

        final response = await _deliveryZoneRepo.getDeliveryZone(
          offset: _offset,
          limit: _limit,
        );

        final List<DeliveryZoneModel> moreDeliveryZones =
            (response['data']['data'] as List<dynamic>?)
                ?.map(
                  (item) =>
                      DeliveryZoneModel.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            [];
        final int currentPage = response['data']['current_page'] as int;
        final int lastPage = response['data']['last_page'] as int;

        _hasReachedMax = currentPage >= lastPage;

        emit(
          DeliveryZoneLoaded(
            deliveryZones: [
              ...currentState.deliveryZones,
              ...moreDeliveryZones,
            ],
            hasReachedMax: _hasReachedMax,
          ),
        );
      }
    } catch (e) {
      emit(DeliveryZoneError(message: e.toString()));
    }
  }

  void _onSelectDeliveryZone(
    SelectDeliveryZone event,
    Emitter<DeliveryZoneState> emit,
  ) {
    final currentState = state;
    if (currentState is DeliveryZoneLoaded) {
      emit(
        DeliveryZoneLoaded(
          deliveryZones: currentState.deliveryZones,
          hasReachedMax: currentState.hasReachedMax,
          selectedZone: event.selectedZone,
        ),
      );
    }
  }
}
