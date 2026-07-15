import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_text.dart';
import '../currency_formatter.dart';

class UIHelperService {
  static Widget buildBreakdownRow(
    BuildContext context,
    String label,
    double? amount,
  ) {
    if (amount == null || amount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, fontSize: 14.sp, color: Colors.grey),
          CustomText(
            text: CurrencyFormatter.formatAmount(context, amount),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
