import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/app_images.dart';
import 'custom_text.dart';

class InactiveAccountWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const InactiveAccountWidget({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Inactive account image
          Image.asset(
            AppImages.inactive,
            width: 120.w,
            height: 120.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),

          // Title
          CustomText(
            text: 'Account Inactive',

            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          // SizedBox(height: 16.h),

          // Message
          // if (message != null) ...[
          //   CustomText(
          //     text: message!,
          //
          //     fontSize: 16.sp,
          //     textAlign: TextAlign.center,
          //     color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          //   ),
          //   SizedBox(height: 24.h),
          // ] else ...[
          //   CustomText(
          //     text: 'Your account is currently inactive.',
          //
          //     fontSize: 16.sp,
          //     textAlign: TextAlign.center,
          //     color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          //   ),
          //   SizedBox(height: 24.h),
          // ],
          //
          // Retry button (optional)
          // if (onRetry != null) ...[
          //   ElevatedButton(
          //     onPressed: onRetry,
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: AppColors.primaryColor,
          //       foregroundColor: Theme.of(context).colorScheme.onPrimary,
          //       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8.r),
          //       ),
          //     ),
          //     child: CustomText(
          //       text: 'Retry',
          //
          //       fontSize: 16.sp,
          //       fontWeight: FontWeight.w600,
          //       color: Theme.of(context).colorScheme.onPrimary,
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}
