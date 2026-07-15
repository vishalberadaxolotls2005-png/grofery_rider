import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class WithdrawalEmptyState extends StatelessWidget {
  const WithdrawalEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 48.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(height: 24.h),
          CustomText(
            text: AppLocalizations.of(context)!.noWithdrawalsYet,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: CustomText(
              text: AppLocalizations.of(context)!.noWithdrawalsYetDescription,
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
