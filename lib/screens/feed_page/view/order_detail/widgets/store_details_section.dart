import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/widgets/custom_card.dart';
import '../../../../../utils/widgets/custom_text.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../model/available_orders.dart';

class StoreDetailsSection extends StatelessWidget {
  final Orders order;
  final bool isExpanded;
  final VoidCallback onToggle;

  const StoreDetailsSection({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: AppLocalizations.of(context)!.storeDetails,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
            ),
            Padding(
              padding: EdgeInsets.all(16.h),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: CustomText(
                        text:
                            (order.deliveryRoute?.routeDetails?.firstOrNull?.storeName?.isNotEmpty == true)
                                ? order.deliveryRoute!.routeDetails!.first.storeName![0].toUpperCase()
                                : "S",
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text:
                              order
                                  .deliveryRoute
                                  ?.routeDetails
                                  ?.firstOrNull
                                  ?.storeName ??
                              AppLocalizations.of(context)!.store,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        SizedBox(height: 4.h),
                        if (order.deliveryRoute?.routeDetails?.firstOrNull?.address !=
                            null)
                          CustomText(
                            text:
                                order
                                    .deliveryRoute!
                                    .routeDetails!
                                    .firstOrNull
                                    ?.address ??
                                "",
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        SizedBox(height: 4.h),
                        if (order
                                .deliveryRoute
                                ?.routeDetails
                                ?.firstOrNull
                                ?.distanceFromCustomer !=
                            null)
                          CustomText(
                            text:
                                '${order.deliveryRoute!.routeDetails!.firstOrNull!.distanceFromCustomer!.toStringAsFixed(1)} km from customer',
                            fontSize: 12.sp,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
