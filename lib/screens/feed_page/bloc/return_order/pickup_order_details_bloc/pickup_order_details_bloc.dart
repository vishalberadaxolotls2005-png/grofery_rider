// bloc/pickup_order_details/pickup_order_details_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:grofery_rider/screens/feed_page/model/return_orders_list_model.dart';
import 'package:grofery_rider/screens/feed_page/repo/return_order_repo.dart';

part 'pickup_order_details_event.dart';
part 'pickup_order_details_state.dart';

class PickupOrderDetailsBloc
    extends Bloc<PickupOrderDetailsEvent, PickupOrderDetailsState> {
  final ReturnOrderRepo _repo = ReturnOrderRepo();

  PickupOrderDetailsBloc() : super(PickupOrderDetailsInitial()) {
    on<FetchPickupOrderDetails>(_onFetchPickupOrderDetails);
  }

  Future<void> _onFetchPickupOrderDetails(
    FetchPickupOrderDetails event,
    Emitter<PickupOrderDetailsState> emit,
  ) async {
    emit(PickupOrderDetailsLoading());

    try {
      final response = await _repo.getReturnPickupsDetails(event.returnId);

      if (response['success'] == true) {
        // FIX: Extract the inner 'pickup' object!
        final pickupJson = response['data']['pickup'] as Map<String, dynamic>;

        final pickup = Pickups.fromJson(pickupJson);
        emit(PickupOrderDetailsSuccess(pickup));
      } else {
        emit(
          PickupOrderDetailsError(
            response['message'] ?? 'Failed to load pickup details',
          ),
        );
      }
    } catch (e) {

      emit(
        PickupOrderDetailsError('Failed to load details. Please try again.'),
      );
    }
  }
}
