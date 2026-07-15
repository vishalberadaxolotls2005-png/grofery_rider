import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import '../../../../../utils/widgets/custom_text.dart';

import '../../../model/available_orders.dart';

class OrderNoteCard extends StatelessWidget {
  final Orders order;

  const OrderNoteCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Only show the card if there's an order note
    // if (order.orderNote == null || order.orderNote!.isEmpty) {
    //   return const SizedBox.shrink();
    // }

    return CustomCard(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.note, color: Colors.orange, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                CustomText(
                  text: 'Order Note',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: CustomText(
                text: order.orderNote!,
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
