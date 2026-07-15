import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/colors.dart';
import '../../config/theme_bloc.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.gradient,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkTheme = themeState.currentTheme == 'dark';

        final cardWidget = Container(
          width: width ?? double.infinity,
          height: height,
          padding: padding ?? EdgeInsets.all(15.h),
          decoration: BoxDecoration(
            color:
                backgroundColor ??
                (isDarkTheme ? AppColors.cardDarkColor : Colors.white),
            borderRadius: BorderRadius.circular(borderRadius ?? 16.r),

            border: Border.all(
              color:
                  isDarkTheme
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            gradient: gradient,
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color:
                        isDarkTheme
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
          ),
          child: child,
        );

        if (onTap != null) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
              child: cardWidget,
            ),
          );
        }

        return cardWidget;
      },
    );
  }
}

// Variant with different styles
class CustomCardVariant extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final VoidCallback? onTap;

  const CustomCardVariant({
    super.key,
    required this.child,
    this.variant = CardVariant.primary,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkTheme = themeState.currentTheme == 'dark';

        Color backgroundColor;
        Color? borderColor;
        List<BoxShadow>? boxShadow;

        switch (variant) {
          case CardVariant.primary:
            backgroundColor =
                isDarkTheme ? AppColors.cardDarkColor : Colors.white;
            boxShadow = [
              BoxShadow(
                color:
                    isDarkTheme
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.1),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ];
            break;
          case CardVariant.secondary:
            backgroundColor =
                isDarkTheme ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA);
            boxShadow = [
              BoxShadow(
                color:
                    isDarkTheme
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                blurRadius: 4.r,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ];
            break;
          case CardVariant.outline:
            backgroundColor = Colors.transparent;
            borderColor =
                isDarkTheme
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.3);
            break;
          case CardVariant.elevated:
            backgroundColor =
                isDarkTheme ? AppColors.cardDarkColor : Colors.white;
            boxShadow = [
              BoxShadow(
                color:
                    isDarkTheme
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.15),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ];
            break;
        }

        return CustomCard(
          width: width,
          height: height,
          padding: padding,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          border:
              borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
          boxShadow: boxShadow,
          onTap: onTap,
          child: child,
        );
      },
    );
  }
}

enum CardVariant { primary, secondary, outline, elevated }
