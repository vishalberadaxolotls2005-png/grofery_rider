import 'package:flutter/material.dart';
import 'package:grofery_rider/config/colors.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final double borderWidth;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool filled;

  const CustomDropdownFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius = 16.0,
    this.borderWidth = 1.0,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final backgroundColor = fillColor ?? (isDarkTheme ? AppColors.cardDarkColor : AppColors.cardLightColor);

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      focusNode: focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        labelStyle: labelStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
        hintStyle: hintStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
        filled: true,
        fillColor: backgroundColor,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.3),
            width: borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.3),
            width: borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusedBorderColor ?? theme.colorScheme.primary,
            width: borderWidth + 0.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: errorBorderColor ?? theme.colorScheme.error,
            width: borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: errorBorderColor ?? theme.colorScheme.error,
            width: borderWidth + 0.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: borderWidth,
          ),
        ),
      ),
      style: textStyle ?? theme.textTheme.bodyLarge,
      dropdownColor: backgroundColor,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      isExpanded: true,
      elevation: 4,
    );
  }
}
