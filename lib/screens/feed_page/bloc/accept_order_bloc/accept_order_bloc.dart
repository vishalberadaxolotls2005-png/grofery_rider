import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../config/api_base_helper.dart';

import '../../repo/accept_order.dart';
import 'accept_order_event.dart';
import 'accept_order_state.dart';

class AcceptOrderBloc extends Bloc<AcceptOrderEvent, AcceptOrderState> {
  AcceptOrderBloc() : super(AcceptOrderInitial()) {
    on<AcceptOrder>(_onAcceptOrder);
    on<AcceptGroupOrder>(_onAcceptGroupOrder);
  }

  Future<void> _onAcceptOrder(
    AcceptOrder event,
    Emitter<AcceptOrderState> emit,
  ) async {
    try {
      emit(AcceptOrderLoading());

      final response = await AcceptOrderRepo().updateAcceptOrder(
        orderId: event.orderId,
      );

      if (response['success'] == true) {
        emit(
          AcceptOrderSuccess(
            response['message'] ?? 'Order accepted successfully',
          ),
        );

        // Emit a custom event to notify that the order was accepted
        // This will be used by the UI to refresh the available orders list
        emit(AcceptOrderCompleted(event.orderId.toString()));
      } else {
        emit(AcceptOrderError(response['message'] ?? 'Failed to accept order'));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {

      }
      emit(AcceptOrderError(e.errorMessage));
    } catch (e) {
      if (kDebugMode) {

      }
      emit(AcceptOrderError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAcceptGroupOrder(
    AcceptGroupOrder event,
    Emitter<AcceptOrderState> emit,
  ) async {
    try {
      emit(AcceptOrderLoading());

      int successCount = 0;
      String lastError = '';

      for (int id in event.orderIds) {
        try {
          final response = await AcceptOrderRepo().updateAcceptOrder(
            orderId: id,
          );
          if (response['success'] == true) {
            successCount++;
          } else {
            lastError = response['message'] ?? 'Failed to accept order $id';
          }
        } catch (e) {
          lastError = e.toString().replaceAll('Exception: ', '');
        }
      }

      if (successCount > 0) {
        emit(
          AcceptOrderSuccess(
            'Accepted $successCount out of ${event.orderIds.length} orders successfully',
          ),
        );
        emit(AcceptOrderCompleted(event.orderIds.first.toString()));
      } else {
        emit(AcceptOrderError(lastError.isNotEmpty ? lastError : 'Failed to accept group orders'));
      }
    } catch (e) {
      emit(AcceptOrderError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
