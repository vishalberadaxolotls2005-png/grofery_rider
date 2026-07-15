import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grofery_rider/config/global.dart';

import 'package:grofery_rider/screens/auth/repo/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequest>(_onLoginRequest);
    on<RegisterRequest>(_onRegisterRequest);
  }

  Future<void> _onLoginRequest(
    LoginRequest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await AuthRepository().login(
        email: event.email,
        password: event.password,
      );
      if (response['success'] == true) {
        final token = response['data']['access_token'].toString();

        await Global.setUserToken(token);
        print('TOKEN : $token');

        emit(AuthSuccess(message: response['message']));
      } else {
        emit(AuthFailure(error: response['message']));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onRegisterRequest(
    RegisterRequest event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Map<String, dynamic> response = {};
      final response = await AuthRepository().register(
        name: event.name,
        email: event.email,
        mobile: event.mobile,
        password: event.password,
        confirmPassword: event.confirmPassword,
        address: event.address,
        driverLicenseNumber: event.driverLicenseNumber,
        vehicleType: event.vehicleType,
        deliveryZoneId: event.deliveryZoneId,
        driverLicenseFile: event.driverLicenseFile!, // File
        vehicleRegistrationFile: event.vehicleRegistrationFile!, // File
        country: event.country,
        iso2: event.iso2,
      );

      if (response['success'] == true) {
        final token = response['access_token'].toString();

        await Global.setUserToken(token);
        print('TOKEN : $token');

        emit(AuthSuccess(message: response['message']));
      } else {
        emit(AuthFailure(error: response['message']));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
