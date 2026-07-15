import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/widgets/custom_text.dart';

class DistanceIndicatorWidget extends StatelessWidget {
  final double distance;

  const DistanceIndicatorWidget({
    super.key,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.straighten,
            color: Theme.of(context).colorScheme.onSurface,
            size: 16.sp,
          ),
          SizedBox(width: 4.w),
          CustomText(
            text: '${distance.toStringAsFixed(1)} km',
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ],
      ),
    );
  }
}
