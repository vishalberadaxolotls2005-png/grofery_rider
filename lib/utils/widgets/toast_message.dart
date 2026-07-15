import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';

enum ToastType { success, error, warning, info }

class ToastManager {
  static void show({
    required BuildContext context,
    required String message,
    ToastType? type,
    bool showIcon = true,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 16.0,
    double borderRadius = 12.0,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 14.0,
      vertical: 8.0,
    ),
    StyledToastPosition position = StyledToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    backgroundColor ??= _getBackgroundColor(type);
    textColor ??= _getTextColor(type);
    final icon = showIcon ? _getIcon(type, textColor) : null;

    showToastWidget(
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon, SizedBox(width: 8.w)],
            Flexible(
              child: CustomText(
                text: message,
                color: textColor,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
      context: context,
      position: position,
      duration: duration,
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
      animDuration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
  }

  static Color _getBackgroundColor(ToastType? type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF28A745);
      case ToastType.error:
        return const Color(0xFFDC3545);
      case ToastType.warning:
        return const Color(0xFFFFC107);
      case ToastType.info:
        return const Color(0xFF17A2B8);
      default:
        return const Color(0xCC333333);
    }
  }

  static Color _getTextColor(ToastType? type) {
    switch (type) {
      case ToastType.warning:
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  static Icon? _getIcon(ToastType? type, Color color) {
    switch (type) {
      case ToastType.success:
        return Icon(Icons.check_circle_outline, color: color, size: 20);
      case ToastType.error:
        return Icon(Icons.error, color: color, size: 20);
      case ToastType.warning:
        return Icon(Icons.warning, color: color, size: 20);
      case ToastType.info:
        return Icon(Icons.info, color: color, size: 20);
      default:
        return null;
    }
  }
}
