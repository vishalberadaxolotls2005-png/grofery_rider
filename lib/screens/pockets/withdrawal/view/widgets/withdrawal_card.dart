import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/screens/pockets/withdrawal/model/withdrawal_model.dart';
import 'withdrawal_details_sheet.dart';
import '../../../../../utils/currency_formatter.dart';

class WithdrawalCard extends StatelessWidget {
  final WithdrawalModel withdrawal;
  final VoidCallback? onTap;

  const WithdrawalCard({super.key, required this.withdrawal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(withdrawal.status, context);


    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap ?? () => _showWithdrawalDetails(context),
        child: CustomCard(
          padding: EdgeInsets.zero,
          // borderRadius: 16,
          child: Column(
            children: [
              // Header with amount and status
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: statusInfo.color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  children: [
                    // Amount
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: CurrencyFormatter.formatAmount(
                              context,
                              withdrawal.amount?.toStringAsFixed(2) ?? '0.00',
                            ),

                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text:
                                AppLocalizations.of(context)!.withdrawalRequest,

                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: statusInfo.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusInfo.icon,
                            color: statusInfo.color,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: statusInfo.text,

                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: statusInfo.color,
                          ),
                        ],
                      ),
                    ),
                    // Admin remark indicator
                    if (withdrawal.adminRemark?.isNotEmpty ?? false) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blue,
                          size: 14.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Details
              Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // Request note if available
                    if (withdrawal.requestNote?.isNotEmpty ?? false) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.note,
                            size: 16.sp,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CustomText(
                              text: withdrawal.requestNote ?? '',
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                    ],
                    // Admin remark if available
                    if (withdrawal.adminRemark?.isNotEmpty ?? false) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 16,
                            color: Colors.blue.withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text:
                                      AppLocalizations.of(context)!.adminRemark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.withValues(alpha: 0.8),
                                ),
                                SizedBox(height: 4),
                                CustomText(
                                  text: withdrawal.adminRemark ?? '',
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                    ],
                    // Date and ID
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              SizedBox(width: 4),
                              CustomText(
                                text: _formatDate(withdrawal.createdAt ?? ''),
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomText(
                          text: 'ID: ${withdrawal.id ?? 'N/A'}',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WithdrawalDetailsSheet(withdrawal: withdrawal),
    );
  }

  StatusInfo _getStatusInfo(String? status, BuildContext context) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return StatusInfo(
          color: Colors.orange,
          icon: Icons.pending,
          text: AppLocalizations.of(context)!.pending,
        );
      case 'approved':
        return StatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          text: AppLocalizations.of(context)!.approved,
        );
      case 'rejected':
        return StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          text: AppLocalizations.of(context)!.rejected,
        );
      default:
        return StatusInfo(
          color: Colors.grey,
          icon: Icons.help,
          text: AppLocalizations.of(context)!.unknown,
        );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class StatusInfo {
  final Color color;
  final IconData icon;
  final String text;

  StatusInfo({required this.color, required this.icon, required this.text});
}
