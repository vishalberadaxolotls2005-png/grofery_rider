import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/colors.dart';

import '../../../../utils/widgets/custom_button.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  const ActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: isLoading ? 'Collecting...' : text,
              onPressed: isLoading ? null : onPressed,
              backgroundColor: isEnabled ? AppColors.primaryColor : Colors.grey,
              textColor: Colors.white,
              borderRadius: 8.r,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              isLoading: isLoading,
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
