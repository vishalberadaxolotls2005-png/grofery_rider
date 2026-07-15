// ignore_for_file: empty_catches

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:grofery_rider/screens/feed_page/model/return_orders_list_model.dart';
import 'package:grofery_rider/screens/feed_page/repo/return_order_repo.dart';

part 'return_order_list_event.dart';
part 'return_order_list_state.dart';

class ReturnOrderListBloc
    extends Bloc<ReturnOrderListEvent, ReturnOrderListState> {
  final ReturnOrderRepo _repo = ReturnOrderRepo();

  int _offset = 0;
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoadingMore = false;

  ReturnOrderListBloc() : super(ReturnOrderListInitial()) {
    on<FetchReturnOrders>(_onFetchReturnOrders);
    on<LoadMoreReturnOrders>(_onLoadMoreReturnOrders);
  }

  Future<void> _onFetchReturnOrders(
    FetchReturnOrders event,
    Emitter<ReturnOrderListState> emit,
  ) async {
    // If not force refresh and already loaded → do nothing (pull-to-refresh protection)
    if (!event.forceRefresh && state is ReturnOrderListLoaded) {
      return;
    }

    if (event.forceRefresh && state is ReturnOrderListLoaded) {
      emit(
        ReturnOrderListRefreshing(
          orders: (state as ReturnOrderListLoaded).orders,
          hasReachedMax: (state as ReturnOrderListLoaded).hasReachedMax,
        ),
      );
    } else {
      emit(ReturnOrderListLoading());
    }

    _offset = 0;
    _hasReachedMax = false;

    try {
      final response = await _repo.getReturnOrder(
        limit: _limit,
        offset: _offset,
      ); // Make sure your repo supports limit/offset!

      if (response['success'] != true) {
        emit(
          ReturnOrderListError(
            response['message'] ?? 'Failed to load return orders',
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

      // Adjust pagination logic based on actual API response
      final int currentPage = data['current_page'] ?? 1;
      final int lastPage = data['last_page'] ?? 1;
      _hasReachedMax = currentPage >= lastPage;

      _offset += _limit;

      emit(
        ReturnOrderListLoaded(orders: orders, hasReachedMax: _hasReachedMax),
      );
    } catch (e) {
      if (kDebugMode) {}
      emit(ReturnOrderListError(e.toString()));
    }
  }

  Future<void> _onLoadMoreReturnOrders(
    LoadMoreReturnOrders event,
    Emitter<ReturnOrderListState> emit,
  ) async {
    if (_isLoadingMore || _hasReachedMax || state is! ReturnOrderListLoaded) {
      return;
    }

    _isLoadingMore = true;

    try {
      final currentState = state as ReturnOrderListLoaded;
      final currentOrders = List<Pickups>.from(currentState.orders);

      final response = await _repo.getReturnOrder(
        limit: _limit,
        offset: _offset,
      );

      if (response['success'] != true) {
        // Don't change state on error during load more (or show snackbar via event)
        return;
      }

      final pickupsJson = response['data']['pickups'] as List<dynamic>? ?? [];
      final newOrders =
          pickupsJson
              .map((json) => Pickups.fromJson(json as Map<String, dynamic>))
              .toList();

      final int currentPage = response['data']['current_page'] ?? 1;
      final int lastPage = response['data']['last_page'] ?? 1;
      _hasReachedMax = currentPage >= lastPage;
      _offset += _limit;

      currentOrders.addAll(newOrders);

      emit(
        ReturnOrderListLoaded(
          orders: currentOrders,
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
    } finally {
      _isLoadingMore = false;
    }
  }
}
