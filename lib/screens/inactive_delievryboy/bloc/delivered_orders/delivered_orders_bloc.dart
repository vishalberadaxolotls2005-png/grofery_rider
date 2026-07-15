import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../../config/api_base_helper.dart';

import '../../../feed_page/model/available_orders.dart';
import '../../../feed_page/repo/my_orders.dart';

import 'delivered_orders_event.dart';
import 'delivered_orders_state.dart';

class DeliveredOrdersBloc
    extends Bloc<DeliveredOrdersEvent, DeliveredOrdersState> {
  int _offset = 0;
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoading = false;

  DeliveredOrdersBloc() : super(DeliveredOrdersInitial()) {
    on<LoadDeliveredOrders>(_onLoadDeliveredOrders);
    on<SearchDeliveredOrders>(_onSearchDeliveredOrders);
    on<LoadMoreDeliveredOrders>(_onLoadMoreDeliveredOrders);
  }

  Future<void> _onLoadDeliveredOrders(
    LoadDeliveredOrders event,
    Emitter<DeliveredOrdersState> emit,
  ) async {
    try {
      // Only load if we don't have data or if explicitly requested
      if (state is DeliveredOrdersLoaded) {
        // If we already have data, don't reload unless it's a manual refresh
        if (!event.forceRefresh) {
          return; // Keep existing data
        }
        final currentState = state as DeliveredOrdersLoaded;
        emit(
          DeliveredOrdersRefreshing(
            deliveredOrders: currentState.deliveredOrders,
            hasReachedMax: currentState.hasReachedMax,
            totalOrders: currentState.totalOrders,
          ),
        );
      } else {
        emit(DeliveredOrdersLoading());
      }

      _offset = 0;
      _hasReachedMax = false;

      final response = await MyOrdersRepo().getDeliveredOrders(
        limit: _limit,
        offset: _offset,
        search: '',
      );

      final List<Orders> orders =
          (response['data']['orders'] as List<dynamic>?)
              ?.map((item) => Orders.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final int currentPage = response['data']['current_page'] as int;
      final int lastPage = response['data']['last_page'] as int;
      final int totalOrders = response['data']['total'] ?? 0;

      _offset += _limit;
      _hasReachedMax = currentPage >= lastPage;

      if (response['success'] == true) {
        emit(
          DeliveredOrdersLoaded(
            deliveredOrders: orders,
            hasReachedMax: _hasReachedMax,
            totalOrders: totalOrders,
          ),
        );
      } else {
        emit(
          DeliveredOrdersError(
            response['message'] ?? 'Failed to load delivered orders',
          ),
        );
      }
    } on ApiException catch (e) {
      if (kDebugMode) {

      }
      emit(DeliveredOrdersError("Error: $e"));
    } catch (e) {
      if (kDebugMode) {

      }
      emit(DeliveredOrdersError("Unexpected error: $e"));
    }
  }

  Future<void> _onSearchDeliveredOrders(
    SearchDeliveredOrders event,
    Emitter<DeliveredOrdersState> emit,
  ) async {
    try {
      emit(DeliveredOrdersLoading());
      _offset = 0;
      _hasReachedMax = false;

      final response = await MyOrdersRepo().getDeliveredOrders(
        limit: _limit,
        offset: _offset,
        search: event.searchQuery,
      );

      final List<Orders> orders =
          (response['data']['orders'] as List<dynamic>?)
              ?.map((item) => Orders.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final int currentPage = response['data']['current_page'] as int;
      final int lastPage = response['data']['last_page'] as int;
      final int totalOrders = response['data']['total'] ?? 0;

      _hasReachedMax = currentPage >= lastPage;

      if (response['success'] == true) {
        emit(
          DeliveredOrdersLoaded(
            deliveredOrders: orders,
            hasReachedMax: _hasReachedMax,
            totalOrders: totalOrders,
          ),
        );
      } else {
        emit(
          DeliveredOrdersError(
            response['message'] ?? 'Failed to search delivered orders',
          ),
        );
      }
    } on ApiException catch (e) {
      emit(DeliveredOrdersError("Error: $e"));
    } catch (e) {
      if (kDebugMode) {

      }
      emit(DeliveredOrdersError("Unexpected error: $e"));
    }
  }

  Future<void> _onLoadMoreDeliveredOrders(
    LoadMoreDeliveredOrders event,
    Emitter<DeliveredOrdersState> emit,
  ) async {
    if (state is DeliveredOrdersLoaded && !_hasReachedMax && !_isLoading) {
      _isLoading = true;
      try {
        final currentState = state as DeliveredOrdersLoaded;
        List<Orders> currentOrders = List<Orders>.from(
          currentState.deliveredOrders,
        );

        final response = await MyOrdersRepo().getDeliveredOrders(
          limit: _limit,
          offset: _offset,
          search: '',
        );

        final List<Orders> newOrders =
            (response['data']['orders'] as List<dynamic>?)
                ?.map((item) => Orders.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final int currentPage = response['data']['current_page'] as int;
        final int lastPage = response['data']['last_page'] as int;
        final int totalOrders = response['data']['total'] ?? 0;

        _offset += _limit;
        _hasReachedMax = currentPage >= lastPage;

        currentOrders.addAll(newOrders);

        if (response['success'] == true) {
          emit(
            DeliveredOrdersLoaded(
              deliveredOrders: currentOrders,
              hasReachedMax: _hasReachedMax,
              totalOrders: totalOrders,
            ),
          );
        } else {
          emit(
            DeliveredOrdersError(
              response['message'] ?? 'Failed to load settings delivered orders',
            ),
          );
        }
      } on ApiException catch (e) {
        emit(DeliveredOrdersError("Error: $e"));
      } catch (e) {
        if (kDebugMode) {

        }
        emit(DeliveredOrdersError("Unexpected error: $e"));
      } finally {
        _isLoading = false;
      }
    }
  }
}
