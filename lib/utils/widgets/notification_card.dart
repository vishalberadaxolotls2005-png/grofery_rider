import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlueBorderCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? elevation;

  const BlueBorderCard({
    super.key,
    required this.child,
    this.borderColor = Colors.blue,
    this.borderWidth = 5.0,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      color: backgroundColor ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Blue left border indicator
            Container(
              width: borderWidth.w,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),

            // Main content area
            Expanded(
              child: Padding(
                padding: padding ?? EdgeInsets.all(16.w),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
