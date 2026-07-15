// widgets/return_order/return_store_details_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/screens/feed_page/model/return_orders_list_model.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class ReturnStoreDetailsSection extends StatelessWidget {
  final Pickups pickup;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ReturnStoreDetailsSection({
    super.key,
    required this.pickup,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final store = pickup.store;

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
                  Icon(Icons.store, color: Theme.of(context).colorScheme.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: AppLocalizations.of(context)!.storeDetails,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 24.sp),
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
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8.r)),
                    child: Center(
                      child: Text(
                        store?.name?[0].toUpperCase() ?? "S",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: store?.name ?? AppLocalizations.of(context)!.unknown, fontSize: 16.sp, fontWeight: FontWeight.w600),
                        SizedBox(height: 4.h),
                        if (store?.address != null)
                          CustomText(text: store!.address!, fontSize: 14.sp, color: Colors.grey[600]),
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
