part of 'forgot_password_cubit.dart';

@immutable
sealed class ForgotPasswordState {}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordLoading extends ForgotPasswordState {}

final class ForgotPasswordSuccess extends ForgotPasswordState {
  final String message;

  ForgotPasswordSuccess(this.message);
}

final class ForgotPasswordFailed extends ForgotPasswordState {
  final String message;

  ForgotPasswordFailed(this.message);
}
