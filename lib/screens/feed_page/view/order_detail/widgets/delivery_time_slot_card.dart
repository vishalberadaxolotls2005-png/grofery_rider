import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import '../../../../../utils/widgets/custom_text.dart';
import '../../../model/available_orders.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class DeliveryTimeSlotCard extends StatelessWidget {
  final Orders order;

  const DeliveryTimeSlotCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.deliveryTimeSlot == null) return const SizedBox.shrink();

    return CustomCard(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.orange,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.deliveryTimeSlot,
                  fontSize: 15.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: order.deliveryTimeSlot!.title ?? 'N/A',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: CustomText(
              text: '${order.deliveryTimeSlot!.startTime} - ${order.deliveryTimeSlot!.endTime}',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
