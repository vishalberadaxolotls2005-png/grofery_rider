import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/screens/pockets/withdrawal/model/withdrawal_model.dart';
import 'package:grofery_rider/utils/currency_formatter.dart';

class WithdrawalDetailsSheet extends StatelessWidget {
  final WithdrawalModel withdrawal;

  const WithdrawalDetailsSheet({super.key, required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(withdrawal.status, context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: CurrencyFormatter.formatAmount(
                          context,
                          withdrawal.amount?.toStringAsFixed(2) ?? '0.00',
                        ),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      CustomText(
                        text: statusInfo.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: statusInfo.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Details
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                _buildDetailRow(
                  context,
                  AppLocalizations.of(context)!.requestId,
                  '#${withdrawal.id ?? 'N/A'}',
                ),
                if (withdrawal.requestNote?.isNotEmpty ?? false)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context)!.requestNote,
                    withdrawal.requestNote ?? '',
                  ),
                if (withdrawal.adminRemark?.isNotEmpty ?? false)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context)!.adminRemark,
                    withdrawal.adminRemark ?? '',
                  ),
                if (withdrawal.processedAt != null)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context)!.processedAt,
                    _formatDateTime(withdrawal.processedAt!),
                  ),
                if (withdrawal.transactionId != null)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context)!.transactionId,
                    withdrawal.transactionId ?? '',
                  ),
                _buildDetailRow(
                  context,
                  AppLocalizations.of(context)!.createdAt,
                  _formatDateTime(withdrawal.createdAt ?? ''),
                ),
                if (withdrawal.updatedAt != null &&
                    withdrawal.updatedAt != withdrawal.createdAt)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context)!.updatedAt,
                    _formatDateTime(withdrawal.updatedAt!),
                  ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CustomText(
              text: label,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: CustomText(
              text: value,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
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

  String _formatDateTime(String dateString) {
    if (dateString.isEmpty) return 'N/A';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
