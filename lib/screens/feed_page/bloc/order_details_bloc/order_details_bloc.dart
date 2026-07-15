import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_details_event.dart';
import 'order_details_state.dart';
import '../../repo/order_details.dart';
import '../../model/available_orders.dart';

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  final OrderDetailsRepo _orderDetailsRepo;

  // Use SharedPreferences instead of static map for persistence across hot restarts
  static SharedPreferences? _prefs;
  static const String _reachedDestinationPrefix = 'reached_destination_';

  OrderDetailsBloc(this._orderDetailsRepo) : super(OrderDetailsInitial()) {
    on<FetchOrderDetails>(_onFetchOrderDetails);
    on<MarkItemReachedDestination>(_onMarkItemReachedDestination);
    _initializePrefs();
  }

  // Initialize SharedPreferences
  Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Helper method to get the storage key for an item
  String _getStorageKey(int orderId, int itemId) =>
      '${_reachedDestinationPrefix}order_${orderId}_item_$itemId';

  // Helper method to save reachedDestination status
  Future<void> _saveReachedDestinationStatus(
    int orderId,
    int itemId,
    bool status,
  ) async {
    await _initializePrefs();
    final storageKey = _getStorageKey(orderId, itemId);
    await _prefs!.setBool(storageKey, status);

  }

  // Helper method to get reachedDestination status
  Future<bool?> _getReachedDestinationStatus(int orderId, int itemId) async {
    await _initializePrefs();
    final storageKey = _getStorageKey(orderId, itemId);
    final status = _prefs!.getBool(storageKey);

    return status;
  }

  Future<void> _onFetchOrderDetails(
    FetchOrderDetails event,
    Emitter<OrderDetailsState> emit,
  ) async {


    emit(OrderDetailsLoading());
    try {
      final response = await _orderDetailsRepo.getOrderDetails(event.orderId);

      if (response['success'] == true && response['data'] != null) {

        final order = Orders.fromJson(response['data']['order']);


        // Restore reachedDestination status from SharedPreferences
        if (order.items != null) {

          final updatedItems = await Future.wait(
            order.items!.map((item) async {
              if (item.id != null) {
                final savedStatus = await _getReachedDestinationStatus(
                  event.orderId,
                  item.id!,
                );

                if (savedStatus == true) {

                  return item.copyWith(reachedDestination: true);
                }
              }
              return item;
            }),
          );

          final updatedOrder = order.copyWith(items: updatedItems);
          emit(OrderDetailsSuccess(updatedOrder));
        } else {
          emit(OrderDetailsSuccess(order));
        }
      } else {
        emit(
          OrderDetailsError(
            response['message'] ?? 'Failed to fetch order details',
          ),
        );
      }
    } catch (error) {
      emit(OrderDetailsError(error.toString()));
    }
  }

  Future<void> _onMarkItemReachedDestination(
    MarkItemReachedDestination event,
    Emitter<OrderDetailsState> emit,
  ) async {


    // Get current state
    final currentState = state;
    if (currentState is OrderDetailsSuccess) {
      final currentOrder = currentState.order;

      // Update the specific item's reachedDestination status
      final updatedItems =
          currentOrder.items?.map((item) {
            if (item.id == event.itemId) {

              return item.copyWith(reachedDestination: true);
            }
            return item;
          }).toList();

      if (updatedItems != null) {
        // Save the reachedDestination status to SharedPreferences
        await _saveReachedDestinationStatus(event.orderId, event.itemId, true);

        // Create updated order with modified items
        final updatedOrder = currentOrder.copyWith(items: updatedItems);
        emit(OrderDetailsSuccess(updatedOrder));

      }
    } else {
//
    }
  }
}
