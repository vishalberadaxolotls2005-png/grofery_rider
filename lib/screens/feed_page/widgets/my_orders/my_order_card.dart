import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_rider/config/colors.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/router/app_routes.dart';
import 'package:grofery_rider/screens/feed_page/model/available_orders.dart';
import 'package:grofery_rider/utils/currency_formatter.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';


import 'package:grofery_rider/utils/time_utils.dart';

class MyOrderCard extends StatelessWidget {
  final Orders order;
  final bool isDarkTheme;
  final List<dynamic>? groupOrders;

  const MyOrderCard({super.key, required this.order, required this.isDarkTheme, this.groupOrders});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0.h),
      child: GestureDetector(
        onTap: () {
          context.push(AppRoutes.orderDetails, extra: {
            'orderId': order.id!,
            'from': false,
            'sourceTab': 1, // 1 = My Orders tab
            'groupOrders': groupOrders,
          });
        },
        child: CustomCard(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Order #${order.id ?? 'N/A'}',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      if (order.createdAt != null && order.createdAt!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5)),
                            SizedBox(width: 4.w),
                            CustomText(
                              text: TimeUtils.getTimeAgo(order.createdAt, context),
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.5),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status ?? '').withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CustomText(
                      text: _getLocalizedStatus(order.status ?? '', context),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(order.status ?? ''),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Delivery address
              if (order.shippingAddress1 != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.w,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        text: '${order.shippingAddress1}${order.shippingAddress2 != null ? ', ${order.shippingAddress2}' : ''}',
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 12.h),

              // Order details
              Row(
                children: [
                  // Items count
                  if (order.items != null)
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 16.w,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                        ),
                        SizedBox(width: 4.w),
                        CustomText(
                          text: "${order.items!.length.toString()} ${AppLocalizations.of(context)!.items}",
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                        ),
                      ],
                    ),

                  SizedBox(width: 16.w),

                  // Distance
                  if (order.deliveryRoute?.totalDistance != null)
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                        ),
                        SizedBox(width: 4.w),
                        CustomText(
                          text: '${order.deliveryRoute!.totalDistance!.toStringAsFixed(1)} ${AppLocalizations.of(context)!.km}',
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                        ),
                      ],
                    ),
                ],
              ),

              if (order.deliveryTimeSlot != null)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: Colors.orange.withValues(alpha: 0.8),
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: '${order.deliveryTimeSlot!.title} (${order.deliveryTimeSlot!.startTime} - ${order.deliveryTimeSlot!.endTime})',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 16.h),

              // Earnings
              if (order.earnings?.total != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.earnings,
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                    CustomText(
                      text: CurrencyFormatter.formatAmount(context, order.earnings!.total),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedStatus(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppLocalizations.of(context)!.pending;
      case 'confirmed':
        return AppLocalizations.of(context)!.confirmed;
      case 'preparing':
        return AppLocalizations.of(context)!.preparing;
      case 'ready':
        return AppLocalizations.of(context)!.ready;
      case 'delivered':
        return AppLocalizations.of(context)!.delivered;
      case 'assigned':
        return AppLocalizations.of(context)!.assigned;
      case 'out_for_delivery':
        return AppLocalizations.of(context)!.outForDelivery;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {

    switch (status.toLowerCase()) {
      case 'out_for_delivery':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
