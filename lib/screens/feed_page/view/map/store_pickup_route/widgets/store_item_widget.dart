import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/widgets/custom_text.dart';
import '../../../../model/available_orders.dart';

class StoreItemWidget extends StatelessWidget {
  final RouteDetails store;
  final int index;
  final bool shouldShowNumbers;

  const StoreItemWidget({
    super.key,
    required this.store,
    required this.index,
    required this.shouldShowNumbers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Store Number Badge (only show if more than 2 items)
           if (shouldShowNumbers)
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.amber,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Center(
                child: CustomText(
                  text: '${index + 1}',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          if (shouldShowNumbers) SizedBox(width: 12.w),
          
          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        text: store.storeName ?? 'Store ${index + 1}',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                if (store.address != null && store.address!.isNotEmpty)
                  CustomText(
                    text: store.address!,
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
