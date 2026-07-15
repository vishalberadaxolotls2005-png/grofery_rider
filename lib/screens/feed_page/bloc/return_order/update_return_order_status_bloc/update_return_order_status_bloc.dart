import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:grofery_rider/config/api_base_helper.dart';
import 'package:grofery_rider/screens/feed_page/repo/return_order_repo.dart';

part 'update_return_order_status_event.dart';
part 'update_return_order_status_state.dart';

class UpdateReturnOrderStatusBloc
    extends Bloc<UpdateReturnOrderStatusEvent, UpdateReturnOrderStatusState> {
  final ReturnOrderRepo _repo = ReturnOrderRepo();

  UpdateReturnOrderStatusBloc() : super(UpdateReturnOrderStatusInitial()) {
    on<UpdateReturnOrderStatus>(_onUpdateReturnOrderStatus);
  }

  Future<void> _onUpdateReturnOrderStatus(
    UpdateReturnOrderStatus event,
    Emitter<UpdateReturnOrderStatusState> emit,
  ) async {
    try {
      emit(UpdateReturnOrderStatusInitial());

      final response = await _repo.updateReturnOrderStatus(
        event.returnId,
        event.status,
      );

      if (response['success'] == true) {
        final String message =
            response['message'] ?? 'Status updated successfully';

        emit(
          UpdateReturnOrderStatusSuccess(
            message: message,
            returnId: event.returnId,
          ),
        );

        emit(ReturnOrderStatusCompleted(event.returnId));
      } else {
        emit(
          UpdateReturnOrderStatusFailed(
            response['message'] ?? 'Failed to update status',
          ),
        );
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        emit(UpdateReturnOrderStatusFailed("Network error: $e"));
      }
    } catch (e) {
      if (kDebugMode) {
        emit(
        UpdateReturnOrderStatusFailed(
          "Something went wrong. Please try again.",
        ),
      );
      }
    }
  }
}
