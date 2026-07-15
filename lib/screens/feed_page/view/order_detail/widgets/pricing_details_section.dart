import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/currency_formatter.dart';
import '../../../../../utils/widgets/custom_card.dart';
import '../../../../../utils/widgets/custom_text.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../model/available_orders.dart';

class PricingDetailsSection extends StatelessWidget {
  final Orders order;
  final bool isExpanded;
  final VoidCallback onToggle;

  const PricingDetailsSection({
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
                    Icons.receipt_long,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: AppLocalizations.of(context)!.pricingDetails,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceRow(
                    context,
                    AppLocalizations.of(context)!.subtotal,
                    CurrencyFormatter.formatAmount(
                      context,
                      order.subtotal ?? '0',
                    ),
                  ),
                  _buildPriceRow(
                    context,
                    AppLocalizations.of(context)!.totalPayable,
                    CurrencyFormatter.formatAmount(
                      context,
                      order.totalPayable ?? '0',
                    ),
                  ),
                  Divider(height: 24.h),
                  _buildPriceRow(
                    context,
                    AppLocalizations.of(context)!.finalTotal,
                    CurrencyFormatter.formatAmount(
                      context,
                      order.finalTotal ?? '0',
                    ),
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

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color:
                isTotal
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          CustomText(
            text: amount,
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color:
                isTotal
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
