import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/widgets/custom_card.dart';
import '../../../../../utils/widgets/custom_text.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../model/available_orders.dart';

class PaymentInformationSection extends StatelessWidget {
  final Orders order;
  final bool isExpanded;
  final VoidCallback onToggle;

  const PaymentInformationSection({
    super.key,
    required this.order,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(  padding: EdgeInsets.zero,child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: AppLocalizations.of(context)!.paymentInformation,
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
            Divider(height: 1, thickness: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
            Padding(
              padding: EdgeInsets.all(16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentRow(
                    context,
                    AppLocalizations.of(context)!.paymentMethod,
                    order.paymentMethod ?? 'N/A',
                  ),
                  _buildPaymentRow(
                    context,
                    AppLocalizations.of(context)!.paymentStatus,
                    order.paymentStatus ?? 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          CustomText(
            text: value,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
