import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/withdrawal_bloc.dart';
import '../../bloc/withdrawal_event.dart';
import '../../../../../utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class WithdrawalErrorState extends StatelessWidget {
  final String errorMessage;

  const WithdrawalErrorState({super.key, required this.errorMessage});

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
              Icons.error_outline,
              size: 48.sp,
              color: theme.colorScheme.error,
            ),
          ),
          SizedBox(height: 24.h),
          CustomText(
            text: AppLocalizations.of(context)!.somethingWentWrong,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: CustomText(
              text: errorMessage,
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<WithdrawalBloc>().add(FetchWithdrawals());
            },
            icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
            label: CustomText(
              text: AppLocalizations.of(context)!.tryAgain,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
