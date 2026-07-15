import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_rider/config/colors.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/screens/auth/bloc/forgot_password/forgot_password_cubit.dart';
import 'package:grofery_rider/screens/auth/repo/auth_repo.dart';
import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_textfield.dart';
import 'package:grofery_rider/utils/widgets/toast_message.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isValid = email.isNotEmpty &&
        RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    if (_isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(authRepository: AuthRepository()),
      child: CustomScaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.backgroundColor,
        body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              ToastManager.show(context: context, message: state.message);
              context.pop();
            } else if (state is ForgotPasswordFailed) {
              ToastManager.show(context: context, message: state.message);
            }
          },
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 100.h,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 60.h),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textColor,
                            size: 28.r,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Logo / Icon
                      Center(
                        child: Container(
                          padding: EdgeInsets.all(24.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 80.r,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // Title
                      CustomText(
                        text: AppLocalizations.of(context)!.forgotPassword,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.center,
                        color: AppColors.textColor,
                      ),

                      SizedBox(height: 12.h),

                      // Description
                      CustomText(
                        text: AppLocalizations.of(context)!.forgotPasswordDescription,
                        textAlign: TextAlign.center,
                        fontSize: 15.sp,
                        color: AppColors.textSecondaryColor,
                        height: 1.5,
                      ),

                      SizedBox(height: 48.h),

                      // Email field
                      CustomTextFormField(
                        controller: _emailController,
                        hintText: AppLocalizations.of(context)!.enterYourEmail,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                          }
                          if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return AppLocalizations.of(context)!.pleaseEnterAValidEmail;
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 40.h),

                      // Submit button
                      BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                        builder: (context, state) {
                          final isLoading = state is ForgotPasswordLoading;

                          return CustomButton(
                            text: AppLocalizations.of(context)!.sendResetLink,
                            isLoading: isLoading,
                            height: 40.h,
                            borderRadius: 16.r,
                            textSize: 14.sp,
                            backgroundColor: _isEmailValid && !isLoading
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withValues(alpha: 0.5),
                            onPressed: (_isEmailValid && !isLoading)
                                ? () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ForgotPasswordCubit>().forgotPassword(
                                  email: _emailController.text.trim(),
                                );
                              }
                            }
                                : null,
                          );
                        },
                      ),

                      SizedBox(height: 60.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    super.dispose();
  }
}
