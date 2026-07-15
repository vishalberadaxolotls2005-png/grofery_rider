import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/widgets/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';

class DeliveryAddressWidget extends StatelessWidget {
  final String? shippingAddress1;
  final String? shippingAddress2;

  const DeliveryAddressWidget({
    super.key,
    this.shippingAddress1,
    this.shippingAddress2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          // Delivery Icon
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(Icons.location_on, color: Colors.white, size: 14.sp),
            ),
          ),
          SizedBox(width: 12.w),

          // Delivery Address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.deliveryAddress,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                CustomText(
                  text:
                      '${shippingAddress1 ?? ''}${shippingAddress2 != null ? ', $shippingAddress2' : ''}',
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
