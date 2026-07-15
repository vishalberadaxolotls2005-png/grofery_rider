import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../../utils/widgets/custom_textfield.dart';
import '../../../../utils/widgets/custom_text.dart';

class PasswordSection extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const PasswordSection({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<PasswordSection> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.security,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 16.h),
        // Password
        CustomTextFormField(
          controller: widget.passwordController,
          labelText: AppLocalizations.of(context)!.password,
          hintText: AppLocalizations.of(context)!.enterYourPassword,
          prefixIcon: Icons.lock,
          suffixIcon:
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          onSuffixIconTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterYourPassword;
            }
            if (value.length < 8) {
              return AppLocalizations.of(
                context,
              )!.passwordMustBeAtLeast8Characters;
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return AppLocalizations.of(
                context,
              )!.passwordMustContainUppercaseLowercaseAndNumber;
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        // Confirm Password
        CustomTextFormField(
          controller: widget.confirmPasswordController,
          labelText: AppLocalizations.of(context)!.confirmPassword,
          hintText: AppLocalizations.of(context)!.confirmYourPassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon:
              _isConfirmPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
          onSuffixIconTap: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
          obscureText: !_isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseConfirmYourPassword;
            }
            if (value != widget.passwordController.text) {
              return AppLocalizations.of(context)!.passwordsDoNotMatch;
            }
            return null;
          },
        ),
      ],
    );
  }
}
