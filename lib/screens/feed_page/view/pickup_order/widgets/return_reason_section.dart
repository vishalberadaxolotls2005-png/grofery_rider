// screens/feed_page/view/pickup_order/widgets/return_reason_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/screens/feed_page/model/return_orders_list_model.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class ReturnReasonSection extends StatelessWidget {
  final Pickups pickup;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ReturnReasonSection({
    super.key,
    required this.pickup,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final reason = pickup.reason?.trim();
    final refundAmount = pickup.refundAmount;
    final sellerComment = pickup.sellerComment?.trim();

    // Hide entire section if no data
    if ((reason == null || reason.isEmpty) &&
        refundAmount == null &&
        (sellerComment == null || sellerComment.isEmpty)) {
      return const SizedBox.shrink();
    }

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
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: AppLocalizations.of(context)!.returnDetails,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (reason != null && reason.isNotEmpty) ...[
                    _row(
                      context,
                      AppLocalizations.of(context)!.reason,
                      reason,
                      icon: Icons.rate_review,
                    ),
                    SizedBox(height: 12.h),
                  ],
                  if (refundAmount != null)
                    _row(
                      context,
                      AppLocalizations.of(context)!.refundAmt,
                      "₹${refundAmount.toString()}",
                      icon: Icons.account_balance_wallet,
                      isBold: true,
                    ),
                  if (sellerComment != null && sellerComment.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _row(
                      context,
                      AppLocalizations.of(context)!.sellerComment,
                      sellerComment,
                      icon: Icons.comment,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
