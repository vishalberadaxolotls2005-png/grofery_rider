import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/widgets/custom_text.dart';

class PaymentRow extends StatelessWidget {
  final String label;
  final String value;

  const PaymentRow({
    super.key,
    required this.label,
    required this.value,
  });

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      case 'cod':
      case 'cash on delivery':
        return Colors.blue;
      case 'online':
      case 'card':
      case 'upi':
      case 'wallet':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cod':
      case 'cash on delivery':
        return Icons.money;
      case 'online':
      case 'card':
        return Icons.credit_card;
      case 'upi':
        return Icons.account_balance;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: CustomText(
              text: label,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              
            ),
          ),
           SizedBox(width: 16.w),
          Expanded(
            child: Container(
              padding:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(value).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _getPaymentStatusColor(value).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(value),
                    size: 16.sp,
                    color: _getPaymentStatusColor(value),
                  ),
                   SizedBox(width: 8.w),
                  CustomText(
                    text: value.toUpperCase(),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _getPaymentStatusColor(value),
                    
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
