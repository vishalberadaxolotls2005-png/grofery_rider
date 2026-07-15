import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';

import '../../../../config/colors.dart';

class ReusableBottomSheet extends StatelessWidget {
  final Widget? child;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final bool showShadow;
  final BorderRadius? borderRadius;
  final Widget? customButton;
  final bool showButton;

  const ReusableBottomSheet({
    super.key,
    this.child,
    this.buttonText,
    this.onButtonPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.padding,
    this.elevation,
    this.showShadow = true,
    this.borderRadius,
    this.customButton,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Content
        if (child != null) child!,

        // Button
        if (showButton) ...[
          if (customButton != null)
            customButton!
          else if (buttonText != null && onButtonPressed != null)
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: buttonText!,
                onPressed: isEnabled ? onButtonPressed : null,
                isLoading: isLoading,
                backgroundColor: AppColors.primaryColor,
                textColor: Colors.white,
                borderRadius: 8.r,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

// Specialized bottom sheet for action buttons
class ActionBottomSheet extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? buttonColor;
  final Color? textColor;
  final String? subtitle;
  final IconData? icon;

  const ActionBottomSheet({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.buttonColor,
    this.textColor,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableBottomSheet(
      backgroundColor: Colors.red,

      padding: EdgeInsets.zero,
      customButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 20.h),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.sameColorChange,
          child: CustomButton(
            padding: EdgeInsets.zero,
            textSize: 15.sp,
            text: buttonText,
            onPressed: isEnabled ? onPressed : null,
            isLoading: isLoading,
            backgroundColor: buttonColor ?? AppColors.primaryColor,
            textColor: textColor ?? Colors.white,
            borderRadius: 5.r,
            // padding:  EdgeInsets.symmetric(vertical: 16.h),
            textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48.sp,
              color: buttonColor ?? AppColors.primaryColor,
            ),
            SizedBox(height: 16.h),
          ],
          if (subtitle != null) ...[
            CustomText(
              text: subtitle!,
              fontSize: 26.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }
}

// Bottom sheet for confirmation dialogs
class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.cancelColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableBottomSheet(
      customButton: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: cancelText,
              onPressed: onCancel ?? () => context.pop(),
              backgroundColor: cancelColor ?? Colors.grey,
              textColor: Colors.white,
              borderRadius: 8,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: confirmText,
              onPressed: onConfirm,
              backgroundColor: confirmColor ?? AppColors.primaryColor,
              textColor: Colors.white,
              borderRadius: 8,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: confirmColor ?? AppColors.primaryColor),
            const SizedBox(height: 16),
          ],
          CustomText(
            text: title,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: message,
            fontSize: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Bottom sheet for form inputs
class FormBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> formFields;
  final String submitText;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool isEnabled;
  final String? subtitle;

  const FormBottomSheet({
    super.key,
    required this.title,
    required this.formFields,
    this.submitText = 'Submit',
    required this.onSubmit,
    this.isLoading = false,
    this.isEnabled = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableBottomSheet(
      buttonText: submitText,
      onButtonPressed: onSubmit,
      isLoading: isLoading,
      isEnabled: isEnabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            CustomText(
              text: subtitle!,
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
          const SizedBox(height: 16),
          ...formFields,
        ],
      ),
    );
  }
}

// Utility function to show bottom sheet
class BottomSheetUtils {
  static Future<T?> showReusableBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      shape: shape,
      builder: (context) => child,
    );
  }

  static Future<T?> showActionBottomSheet<T>({
    required BuildContext context,
    required String buttonText,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Color? buttonColor,
    Color? textColor,
    String? subtitle,
    IconData? icon,
  }) {
    return showReusableBottomSheet<T>(
      context: context,
      child: ActionBottomSheet(
        buttonText: buttonText,
        onPressed: onPressed,
        isLoading: isLoading,
        isEnabled: isEnabled,
        buttonColor: buttonColor,
        textColor: textColor,
        subtitle: subtitle,
        icon: icon,
      ),
    );
  }

  static Future<bool?> showConfirmationBottomSheet({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? cancelColor,
    IconData? icon,
  }) {
    return showReusableBottomSheet<bool>(
      context: context,
      child: ConfirmationBottomSheet(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        icon: icon,
      ),
    );
  }

  static Future<T?> showFormBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<Widget> formFields,
    String submitText = 'Submit',
    required VoidCallback onSubmit,
    bool isLoading = false,
    bool isEnabled = true,
    String? subtitle,
  }) {
    return showReusableBottomSheet<T>(
      context: context,
      child: FormBottomSheet(
        title: title,
        formFields: formFields,
        submitText: submitText,
        onSubmit: onSubmit,
        isLoading: isLoading,
        isEnabled: isEnabled,
        subtitle: subtitle,
      ),
    );
  }
}
