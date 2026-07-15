import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/config/colors.dart';
import '../../../../config/theme_bloc.dart';
import '../../../../utils/widgets/custom_text.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color valueColor;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.valueColor = Colors.transparent, // Default to transparent to use theme color
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(

        builder: (context, themeState) {
      final isDarkTheme = themeState.currentTheme == 'dark';
          return Expanded(
        child: Container(
          constraints: BoxConstraints(minHeight: 100.h),
          // Minimum height instead of fixed
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(10.h),
              decoration: BoxDecoration(
                color:  (isDarkTheme ? AppColors.cardDarkColor : Colors.white),
                borderRadius: BorderRadius.circular( 16.r),

                border: Border.all(
                  color:isDarkTheme? Colors.grey.withValues(alpha:0.1):Colors.grey.withValues(alpha:0.3),
                  width: 1,
                ),
                boxShadow:  [
                  BoxShadow(
                    color: isDarkTheme
                        ? Colors.black.withValues(alpha:0.2)
                        : Colors.grey.withValues(alpha:0.1),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    textAlign: TextAlign.center,
                    text: title,
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: value,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: valueColor == Colors.transparent
                        ? Theme.of(context).colorScheme.onSurface
                        : valueColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
