// widgets/return_order/return_order_items_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/screens/feed_page/model/return_orders_list_model.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class ReturnOrderItemsSection extends StatelessWidget {
  final Pickups pickup;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ReturnOrderItemsSection({
    super.key,
    required this.pickup,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final product = pickup.orderItem?.product;
    final variant = pickup.orderItem?.variant;

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
                    Icons.shopping_bag,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: AppLocalizations.of(context)!.orderItems,
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
            Padding(
              padding: EdgeInsets.all(16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product != null || variant != null)
                    _buildReturnItemTile(context, product: product, variant: variant)
                  else
                    CustomText(
                      text: AppLocalizations.of(context)!.noData,
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReturnItemTile(
      BuildContext context, {
        required Product? product,
        required Variant? variant,
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, color: Colors.blue, size: 28.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: product?.name ?? variant?.title ?? AppLocalizations.of(context)!.unknownItem,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
