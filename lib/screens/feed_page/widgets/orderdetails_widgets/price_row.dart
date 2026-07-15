import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/colors.dart';

import '../../../../utils/widgets/custom_text.dart';

class PriceRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;

  const PriceRow({
    super.key,
    required this.label,
    required this.amount,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color:
                isTotal
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          CustomText(
            text: amount,
            fontSize: isTotal ? 18.sp : 16.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color:
                isTotal
                    ? AppColors.secondaryColor
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
