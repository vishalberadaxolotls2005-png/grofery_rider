import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_rider/config/app_images.dart';
import 'package:grofery_rider/router/app_routes.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../config/colors.dart';
import '../../../utils/widgets/toast_message.dart';
import '../../../utils/widgets/custom_textfield.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_text.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_event.dart';
import '../bloc/auth_bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          log('State $state');

          if (state is AuthSuccess) {
            ToastManager.show(context: context, message: state.message);
            GoRouter.of(context).push(AppRoutes.dashboard);
          } else if (state is AuthFailure) {
            ToastManager.show(context: context, message: state.error);
          }
        },
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.borderColor, AppColors.borderColor],
              ),
            ),
            child: Column(
              children: [
                /// Green area - approximately half of the screen
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// logo
                      logo(),
                    ],
                  ),
                ),

                /// Form section - approximately half of the screen
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22.r),
                        topRight: Radius.circular(22.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 15.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: AppLocalizations.of(context)!.welcomeBack,
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          SizedBox(height: 20.h),
                          email(),
                          SizedBox(height: 12.h),

                          /// Password
                          password(),
                          SizedBox(height: 10.h),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                context.push(AppRoutes.forgotPassword);
                              },
                              child: CustomText(
                                text: AppLocalizations.of(context)!.forgotPassword,
                                color: AppColors.primaryColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),

                          /// Submit button
                          submitButton(),
                          SizedBox(height: 8.h),
                          navigateToRegister(),
                          SizedBox(height: 20.h), // Bottom padding for scroll
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget logo() {
    return Column(
      children: [
        SizedBox(
          height: 200.h,
          width: 250.w,
          child: Image.asset(
            AppImages.splashLogo,
            width: 250.w,
            height: 200.h,
            fit: BoxFit.contain,
          ),
        ),

        // CustomText(text: "Hyper Local Rider ",fontSize: 30.sp,)
      ],
    );
  }

  Widget email() {
    return CustomTextFormField(
      controller: _emailController,
      // labelText: AppLocalizations.of(context)!.email,
      hintText: AppLocalizations.of(context)!.enterYourEmail,
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterYourEmail;
        }
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return AppLocalizations.of(context)!.pleaseEnterAValidEmail;
        }
        return null;
      },
    );
  }

  Widget password() {
    return CustomTextFormField(
      controller: _passwordController,
      // labelText: AppLocalizations.of(context)!.password,
      hintText: AppLocalizations.of(context)!.enterYourPassword,
      prefixIcon: Icons.lock,
      suffixIcon: _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
      onSuffixIconTap: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterYourPassword;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context)!.passwordMustBeAtLeast6Characters;
        }
        return null;
      },
    );
  }

  Widget submitButton() {
    return CustomButton(
      textSize: 15.sp,
      text: AppLocalizations.of(context)!.login,
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<AuthBloc>().add(
            LoginRequest(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
        }
      },
    );
  }

  Widget navigateToRegister() {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push(AppRoutes.register);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(text: AppLocalizations.of(context)!.dontHaveAccount),
          SizedBox(width: 5.w),
          CustomText(
            text: AppLocalizations.of(context)!.register,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
