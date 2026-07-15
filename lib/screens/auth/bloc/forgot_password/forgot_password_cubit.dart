
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grofery_rider/screens/auth/repo/auth_repo.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(ForgotPasswordInitial());

  Future<void> forgotPassword({required String email}) async {
    emit(ForgotPasswordLoading());
    try {
      final response = await _authRepository.forgotPassword(email: email);
      if (response['success'] == true) {
        emit(ForgotPasswordSuccess(response['message']));
      } else {
        emit(ForgotPasswordFailed(response['message']));
      }
    } catch (e) {
      emit(ForgotPasswordFailed(e.toString()));
    }
  }
}
