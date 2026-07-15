// widgets/return_order/return_earnings_details_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/screens/feed_page/model/return_orders_list_model.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/currency_formatter.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class ReturnEarningsDetailsSection extends StatelessWidget {
  final Pickups pickup;
  final bool isExpanded;
  final VoidCallback onToggle;

  const ReturnEarningsDetailsSection({
    super.key,
    required this.pickup,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final earnings = pickup.earnings;

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(onTap: onToggle, child: _header(context)),
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
                children: [
                  _row(
                    context,
                    AppLocalizations.of(context)!.baseFees,
                    earnings?.breakdown?.baseFee,
                  ),
                  _row(
                    context,
                    AppLocalizations.of(context)!.pickupFees,
                    earnings?.breakdown?.perStorePickupFee,
                  ),
                  _row(
                    context,
                    AppLocalizations.of(context)!.distanceBasedFee,
                    earnings?.breakdown?.distanceBasedFee,
                  ),
                  _row(
                    context,
                    AppLocalizations.of(context)!.incentive,
                    earnings?.breakdown?.perOrderIncentive,
                  ),
                  Divider(
                    height: 24,
                    thickness: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  _row(
                    context,
                    AppLocalizations.of(context)!.totalEarnings,
                    earnings?.total,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Padding(
    padding: EdgeInsets.all(16.h),
    child: Row(
      children: [
        Icon(
          Icons.account_balance_wallet,
          color: Theme.of(context).colorScheme.primary,
          size: 20.sp,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.earningsDetails,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
        Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
      ],
    ),
  );

  Widget _row(
    BuildContext context,
    String label,
    dynamic amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            CurrencyFormatter.formatAmount(context, amount?.toString() ?? '0'),
            style: TextStyle(
              fontSize: isTotal ? 18.sp : 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
