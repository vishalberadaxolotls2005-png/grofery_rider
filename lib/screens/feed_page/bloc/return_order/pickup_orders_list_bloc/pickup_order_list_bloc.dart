// bloc/pickup_order_list_bloc/pickup_order_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:grofery_rider/screens/feed_page/model/return_orders_list_model.dart';
import 'package:grofery_rider/screens/feed_page/repo/return_order_repo.dart';

part 'pickup_order_list_event.dart';
part 'pickup_order_list_state.dart';

class PickupOrderListBloc
    extends Bloc<PickupOrderListEvent, PickupOrderListState> {
  final ReturnOrderRepo _repo = ReturnOrderRepo();

  int _offset = 0;
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoadingMore = false;

  PickupOrderListBloc() : super(PickupOrderListInitial()) {
    on<FetchPickupOrders>(_onFetchPickupOrders);
    on<LoadMorePickupOrders>(_onLoadMorePickupOrders);
  }

  Future<void> _onFetchPickupOrders(
    FetchPickupOrders event,
    Emitter<PickupOrderListState> emit,
  ) async {
    if (!event.forceRefresh && state is PickupOrderListLoaded) return;

    if (event.forceRefresh && state is PickupOrderListLoaded) {
      emit(
        PickupOrderListRefreshing(
          orders: (state as PickupOrderListLoaded).orders,
          hasReachedMax: (state as PickupOrderListLoaded).hasReachedMax,
          totalOrders: (state as PickupOrderListLoaded).totalOrders,
        ),
      );
    } else {
      emit(PickupOrderListLoading());
    }

    _offset = 0;
    _hasReachedMax = false;

    try {
      final response = await _repo.getReturnPickups(
        limit: _limit,
        offset: _offset,
      );

      if (response['success'] != true) {
        emit(
          PickupOrderListError(
            response['message'] ?? 'Failed to load pickup orders',
          ),
        );
        return;
      }

      final data = response['data'];
      final pickupsJson = data['pickups'] as List<dynamic>? ?? [];
      final orders =
          pickupsJson
              .map((json) => Pickups.fromJson(json as Map<String, dynamic>))
              .toList();

      final int currentPage = data['current_page'] ?? 1;
      final int lastPage = data['last_page'] ?? 1;
      final int totalOrders = data['total'] ?? 0;
      _hasReachedMax = currentPage >= lastPage;
      _offset += _limit;

      emit(
        PickupOrderListLoaded(orders: orders, hasReachedMax: _hasReachedMax, totalOrders: totalOrders),
      );
    } catch (e) {
      if (kDebugMode) {
        emit(PickupOrderListError(e.toString()));
      }
    }
  }

  Future<void> _onLoadMorePickupOrders(
    LoadMorePickupOrders event,
    Emitter<PickupOrderListState> emit,
  ) async {
    if (_isLoadingMore || _hasReachedMax || state is! PickupOrderListLoaded) {
      return;
    }

    _isLoadingMore = true;

    try {
      final currentState = state as PickupOrderListLoaded;
      final currentOrders = List<Pickups>.from(currentState.orders);

      final response = await _repo.getReturnPickups(
        limit: _limit,
        offset: _offset,
      );

      if (response['success'] != true) return;

      final pickupsJson = response['data']['pickups'] as List<dynamic>? ?? [];
      final newOrders =
          pickupsJson
              .map((json) => Pickups.fromJson(json as Map<String, dynamic>))
              .toList();

      final int currentPage = response['data']['current_page'] ?? 1;
      final int lastPage = response['data']['last_page'] ?? 1;
      final int totalOrders = response['data']['total'] ?? 0;
      _hasReachedMax = currentPage >= lastPage;
      _offset += _limit;

      currentOrders.addAll(newOrders);

      emit(
        PickupOrderListLoaded(
          orders: currentOrders,
          hasReachedMax: _hasReachedMax,
          totalOrders: totalOrders,
        ),
      );
    } catch (e) {
//
    } finally {
      _isLoadingMore = false;
    }
  }
}
