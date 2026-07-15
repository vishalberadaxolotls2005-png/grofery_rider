import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../config/api_base_helper.dart';

import '../../model/available_orders.dart';
import '../../repo/my_orders.dart';

import 'my_orders_event.dart';
import 'my_orders_state.dart';

class MyOrdersBloc extends Bloc<MyOrdersEvent, MyOrdersState> {
  int _offset = 0;
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  String _selectedFilter = 'all';

  MyOrdersBloc() : super(MyOrdersInitial()) {
    on<AllMyOrdersList>(_onAllMyOrders);
    on<SearchMyOrders>(_onSearchMyOrders);
    on<LoadMoreMyOrders>(_onLoadMoreMyOrders);
  }

  Future<void> _onAllMyOrders(
    AllMyOrdersList event,
    Emitter<MyOrdersState> emit,
  ) async {

    if (event.type != null) {
      _selectedFilter = event.type!;
    }
    final String filterType = _selectedFilter;
    try {
      if (state is MyOrdersLoaded) {
        emit(MyOrdersRefreshing(
          myOrders: (state as MyOrdersLoaded).myOrders,
          hasReachedMax: (state as MyOrdersLoaded).hasReachedMax,
          totalOrders: (state as MyOrdersLoaded).totalOrders,
          selectedFilter: _selectedFilter,
        ));
      } else {
        emit(MyOrdersLoading());
      }
      _offset = 0;
      _hasReachedMax = false;

      final response = await MyOrdersRepo().myOrdersList(
        limit: _limit,
        offset: _offset,
        search: '',
        status: filterType == 'all' ? null : filterType,
      );



      // Check if response has error
      if (response['error'] != null) {

        emit(MyOrdersError('API Error: ${response['error']}'));
        return;
      }

      // Check if response has data
      if (response['data'] == null) {

        emit(MyOrdersError('No data received from API'));
        return;
      }

      // Safely extract orders with null checks
      final ordersData = response['data']['orders'];
      if (ordersData == null) {

        emit(MyOrdersError('Orders data not found'));
        return;
      }

      final List<Orders> orders =
          (ordersData as List<dynamic>?)
              ?.map((item) {
                try {
                  if (item == null) {

                    return null;
                  }
                  return Orders.fromJson(item as Map<String, dynamic>);
                } catch (e) {

                  return null;
                }
              })
              .where((order) => order != null) // Filter out null orders
              .cast<Orders>()
              .toList() ??
          [];

      // Safely extract pagination data with null checks
      final currentPage = response['data']['current_page'];
      final lastPage = response['data']['last_page'];
      final totalOrders = response['data']['total'] ?? 0;

      if (currentPage == null || lastPage == null) {

        emit(MyOrdersError('Pagination data incomplete'));
        return;
      }

      final int currentPageInt = currentPage as int;
      final int lastPageInt = lastPage as int;
      final int totalOrdersInt = totalOrders as int;



      _offset += _limit;
      _hasReachedMax = currentPageInt >= lastPageInt;


      if (response['success'] == true) {
        emit(MyOrdersLoaded(
          myOrders: orders,
          hasReachedMax: _hasReachedMax,
          totalOrders: totalOrdersInt,
          selectedFilter: _selectedFilter,
        ));
      } else {
        final errorMessage = response['message'] ?? 'Unknown error occurred';

        // Don't increment offset on error, so we can retry the same page
        emit(MyOrdersError(errorMessage));
      }
    } on ApiException catch (e) {

      emit(MyOrdersError("API Error: $e"));
    } catch (e) {
      if (kDebugMode) {

      }
      emit(MyOrdersError("Unexpected error: $e"));
    }
  }

  Future<void> _onSearchMyOrders(
    SearchMyOrders event,
    Emitter<MyOrdersState> emit,
  ) async {
    try {
      emit(MyOrdersLoading());
      _offset = 0;
      _hasReachedMax = false;

      final response = await MyOrdersRepo().myOrdersList(
        limit: _limit,
        offset: _offset,
        search: event.searchQuery,
      );

      // Check if response has error
      if (response['error'] != null) {

        emit(MyOrdersError('API Error: ${response['error']}'));
        return;
      }

      // Check if response has data
      if (response['data'] == null) {

        emit(MyOrdersError('No data received from API'));
        return;
      }

      // Safely extract orders with null checks
      final ordersData = response['data']['orders'];
      if (ordersData == null) {

        emit(MyOrdersError('Orders data not found'));
        return;
      }

      final List<Orders> orders =
          (ordersData as List<dynamic>?)
              ?.map((item) {
                try {
                  if (item == null) {

                    return null;
                  }
                  return Orders.fromJson(item as Map<String, dynamic>);
                } catch (e) {

                  return null;
                }
              })
              .where((order) => order != null) // Filter out null orders
              .cast<Orders>()
              .toList() ??
          [];

      // Safely extract pagination data with null checks
      final currentPage = response['data']['current_page'];
      final lastPage = response['data']['last_page'];
      final totalOrders = response['data']['total'] ?? 0;

      if (currentPage == null || lastPage == null) {

        emit(MyOrdersError('Pagination data incomplete'));
        return;
      }

      final int currentPageInt = currentPage as int;
      final int lastPageInt = lastPage as int;
      final int totalOrdersInt = totalOrders as int;

      _hasReachedMax = currentPageInt >= lastPageInt;

      if (response['success'] == true) {
        emit(MyOrdersLoaded(
          myOrders: orders,
          hasReachedMax: _hasReachedMax,
          totalOrders: totalOrdersInt,
          selectedFilter: _selectedFilter,
        ));
      } else {
        final errorMessage = response['message'] ?? 'Unknown error occurred';

        // Don't increment offset on error, so we can retry the same page
        emit(MyOrdersError(errorMessage));
      }
    } on ApiException catch (e) {

      emit(MyOrdersError("API Error: $e"));
    } catch (e) {
      if (kDebugMode) {

      }
      emit(MyOrdersError("Unexpected error: $e"));
    }
  }

  Future<void> _onLoadMoreMyOrders(
    LoadMoreMyOrders event,
    Emitter<MyOrdersState> emit,
  ) async {




    if (state is MyOrdersLoaded && !_hasReachedMax && !_isLoading) {

      _isLoading = true;
      try {
        final currentState = state as MyOrdersLoaded;
        List<Orders> currentOrders = List<Orders>.from(currentState.myOrders);


        final response = await MyOrdersRepo().myOrdersList(
          limit: _limit,
          offset: _offset,
          search: '',
          status: event.currentFilter == 'all' ? null : event.currentFilter,
        );



        // Check if response has error
        if (response['error'] != null) {

          // Don't increment offset on error, so we can retry the same page
          emit(MyOrdersError('API Error: ${response['error']}'));
          return;
        }

        // Check if response has data
        if (response['data'] == null) {

          // Don't increment offset on error, so we can retry the same page
          emit(MyOrdersError('No data received from API'));
          return;
        }

        // Safely extract orders with null checks
        final ordersData = response['data']['orders'];
        if (ordersData == null) {

          // Don't increment offset on error, so we can retry the same page
          emit(MyOrdersError('Orders data not found'));
          return;
        }

        final List<Orders> newOrders =
            (ordersData as List<dynamic>?)
                ?.map((item) {
                  try {
                    if (item == null) {

                      return null;
                    }
                    return Orders.fromJson(item as Map<String, dynamic>);
                  } catch (e) {

                    return null;
                  }
                })
                .where((order) => order != null) // Filter out null orders
                .cast<Orders>()
                .toList() ??
            [];

        // Safely extract pagination data with null checks
        final currentPage = response['data']['current_page'];
        final lastPage = response['data']['last_page'];
        final totalOrders = response['data']['total'] ?? 0;

        if (currentPage == null || lastPage == null) {

          // Don't increment offset on error, so we can retry the same page
          emit(MyOrdersError('Pagination data incomplete'));
          return;
        }

        final int currentPageInt = currentPage as int;
        final int lastPageInt = lastPage as int;
        final int totalOrdersInt = totalOrders as int;


        _offset += _limit;
        // Check if we've reached the last page
        _hasReachedMax = currentPageInt >= lastPageInt;


        currentOrders.addAll(newOrders);


        if (response['success'] == true) {

          emit(
            MyOrdersLoaded(
              myOrders: currentOrders,
              hasReachedMax: _hasReachedMax,
              totalOrders: totalOrdersInt,
              selectedFilter: _selectedFilter,
            ),
          );
        } else {
          final errorMessage = response['message'] ?? 'Unknown error occurred';

          // Don't increment offset on error, so we can retry the same page
          emit(MyOrdersError(errorMessage));
        }
      } on ApiException catch (e) {

        emit(MyOrdersError("API Error: $e"));
      } catch (e) {
        if (kDebugMode) {

        }
        emit(MyOrdersError("Unexpected error: $e"));
      } finally {
        _isLoading = false;
      }
    }
  }
}
