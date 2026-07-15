import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:grofery_rider/config/api_base_helper.dart';
import 'package:grofery_rider/screens/feed_page/repo/return_order_repo.dart';

part 'return_order_event.dart';
part 'return_order_state.dart';

class ReturnOrderBloc extends Bloc<ReturnOrderEvent, ReturnOrderState> {
  final ReturnOrderRepo _repo = ReturnOrderRepo();

  ReturnOrderBloc() : super(ReturnOrderInitial()) {
    on<AcceptReturnOrder>(_onAcceptReturnOrder);
  }

  Future<void> _onAcceptReturnOrder(
    AcceptReturnOrder event,
    Emitter<ReturnOrderState> emit,
  ) async {
    try {
      emit(ReturnOrderLoading());

      final response = await _repo.acceptReturnOrder(event.returnId);

      if (response['success'] == true) {
        final String message =
            response['message'] ?? 'Return order accepted successfully';

        emit(
          AcceptReturnOrderSuccess(message: message, returnId: event.returnId),
        );

        emit(ReturnOrderActionCompleted(event.returnId));
      } else {
        emit(
          ReturnOrderError(
            response['message'] ?? 'Failed to accept return order',
          ),
        );
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        emit(ReturnOrderError("Network error: $e"));
      }
    } catch (e) {
      if (kDebugMode) {
        emit(ReturnOrderError("Something went wrong. Please try again."));
      }
    }
  }
}
