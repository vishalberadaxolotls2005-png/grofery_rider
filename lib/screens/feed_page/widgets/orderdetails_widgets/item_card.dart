import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import '../../../../config/colors.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/custom_button.dart';
import '../../model/available_orders.dart';
import '../../../../utils/currency_formatter.dart';
import '../../bloc/items_collected_bloc/items_collected_bloc.dart';
import '../../bloc/items_collected_bloc/items_collected_state.dart';
import '../../../../l10n/app_localizations.dart';

import 'package:flutter_swipe_button/flutter_swipe_button.dart';

class ItemCard extends StatelessWidget {
  final Items item;
  final String? orderStatus;
  final bool from;
  final bool isCollected;
  final bool isDelivered;
  final bool isLoading;
  final bool isOtpVerified;
  final VoidCallback? onCollect;
  final Function(int?, String?)? onDelivered;
  final Function(int?, String?)? onTap;
  final VoidCallback? onReachedDestination;

  const ItemCard({
    super.key,
    required this.item,
    required this.orderStatus,
    required this.from,
    required this.isCollected,
    required this.isDelivered,
    required this.isLoading,
    this.isOtpVerified = false,
    this.onCollect,
    this.onDelivered,
    this.onTap,
    this.onReachedDestination,
  });

  void _showDeliveryBottomSheet(
    BuildContext context,
    bool shouldOpenOtpDialog,
  ) {
    int maxQuantity = item.quantity ?? 1;
    int selectedQuantity = maxQuantity;
    TextEditingController reasonController = TextEditingController();
    String? reasonError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.w,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.w,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomText(
                    text: 'Confirm Delivery',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 16.h),
                  // Item details
                  Row(
                    children: [
                      Container(
                        width: 70.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          image:
                              item.product?.image != null &&
                                      item.product!.image!.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(item.product!.image!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child:
                            (item.product?.image == null ||
                                    item.product!.image!.isEmpty)
                                ? Center(
                                  child: Icon(
                                    Icons.shopping_bag,
                                    color: Colors.blue,
                                    size: 30.sp,
                                  ),
                                )
                                : const SizedBox(),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text:
                                  item.title ??
                                  AppLocalizations.of(context)!.unknownItem,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 8.h),
                            CustomText(
                              text: CurrencyFormatter.formatAmount(
                                context,
                                item.price ?? '0',
                              ),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Quantity selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Delivery Quantity',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (selectedQuantity > 1) {
                                  setModalState(() {
                                    selectedQuantity--;
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove),
                              color:
                                  selectedQuantity > 1
                                      ? Colors.black
                                      : Colors.grey,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: CustomText(
                                text: selectedQuantity.toString(),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (selectedQuantity < maxQuantity) {
                                  setModalState(() {
                                    selectedQuantity++;
                                  });
                                }
                              },
                              icon: const Icon(Icons.add),
                              color:
                                  selectedQuantity < maxQuantity
                                      ? Colors.black
                                      : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (selectedQuantity < maxQuantity) ...[
                    SizedBox(height: 16.h),
                    CustomText(
                      text: 'Reason for partial delivery',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: reasonController,
                      onChanged: (value) {
                        if (reasonError != null && value.trim().isNotEmpty) {
                          setModalState(() {
                            reasonError = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter reason (e.g., damaged, missing)',
                        errorText: reasonError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 30.h),
                  SwipeButton(
                    thumbPadding: EdgeInsets.all(4.w),
                    borderRadius: BorderRadius.circular(22.r),
                    inactiveThumbColor: Colors.white,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: AppColors.primaryColor.withValues(
                      alpha: 0.8,
                    ),
                    width: double.infinity,
                    height: 45.h,
                    thumb: Container(
                      width: 40.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(17.r),
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 1.w,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    onSwipe: () async {
                      if (selectedQuantity < maxQuantity &&
                          reasonController.text.trim().isEmpty) {
                        setModalState(() {
                          reasonError =
                              'Please enter a reason for partial delivery';
                        });
                        return;
                      }

                      Navigator.pop(bottomSheetContext);
                      if (shouldOpenOtpDialog) {
                        onTap?.call(selectedQuantity, reasonController.text);
                      } else {
                        onDelivered?.call(
                          selectedQuantity,
                          reasonController.text,
                        );
                      }
                    },
                    child: CustomText(
                      text: 'Swipe to Deliver',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if item requires OTP
    final bool requiresOtp = item.product?.requiresOtp == 1;
    // Check if OTP dialog should open when delivered button is clicked
    final bool shouldOpenOtpDialog =
        orderStatus?.toLowerCase() == 'out_for_delivery' &&
        item.status?.toLowerCase() == 'collected' &&
        requiresOtp &&
        item.otpVerified == 0 &&
        !isOtpVerified;

    return BlocBuilder<ItemsCollectedBloc, ItemsCollectedState>(
      builder: (context, state) {
        return GestureDetector(
          onTap:
              onTap == null
                  ? null
                  : () {
                    _showDeliveryBottomSheet(context, shouldOpenOtpDialog);
                  },
          child: CustomCard(
            padding: EdgeInsets.all(16.w),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        image:
                            item.product?.image != null &&
                                    item.product!.image!.isNotEmpty
                                ? DecorationImage(
                                  image: NetworkImage(item.product!.image!),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    // Handled by the child icon eventually
                                  },
                                )
                                : null,
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child:
                          (item.product?.image == null ||
                                  item.product!.image!.isEmpty)
                              ? Center(
                                child: Icon(
                                  Icons.shopping_bag,
                                  color: Colors.blue,
                                  size: 20.sp,
                                ),
                              )
                              : const SizedBox(),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomText(
                                  text:
                                      item.title ??
                                      AppLocalizations.of(context)!.unknownItem,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          //  SizedBox(height: 4.h),
                          // CustomText(
                          //   text: '${AppLocalizations.of(context)!.itemId}: ${item.id ?? 'N/A'}',
                          //   fontSize: 12.sp,
                          //   color: Colors.grey[600],
                          //
                          //
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text:
                              '${AppLocalizations.of(context)!.quantity}: ${item.quantity ?? 1}',
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          text: CurrencyFormatter.formatAmount(
                            context,
                            item.price ?? '0',
                          ),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ],
                    ),

                    // Collection mode logic
                    if (isDelivered) ...[
                      // Show tick mark and "Delivered" text when item is delivered
                      Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: AppLocalizations.of(context)!.delivered,
                            fontSize: 12.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ] else if (isCollected &&
                        !isDelivered &&
                        item.reachedDestination == false) ...[
                      // Show tick mark and "Collected" text when item is collected but not delivered
                      Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 24.sp,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: AppLocalizations.of(context)!.collected,
                            fontSize: 12.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ] else if (isDelivered &&
                        item.reachedDestination == true) ...[
                      // Show tick mark and "Delivered" text when item is delivered and has reached destination
                      Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24.sp,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            text: AppLocalizations.of(context)!.delivered,
                            fontSize: 12.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ] else if (item.reachedDestination == true &&
                        isCollected &&
                        !isDelivered) ...[
                      // Show "Deliver" button when item has reached destination (highest priority)
                      CustomButton(
                        width: 100.w,
                        height: 40.h,
                        textSize: 15.sp,
                        text: AppLocalizations.of(context)!.deliver,
                        onPressed:
                            () => _showDeliveryBottomSheet(
                              context,
                              shouldOpenOtpDialog,
                            ),
                        isLoading: isLoading,
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                        borderRadius: 8.r,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (orderStatus?.toLowerCase() ==
                            'out_for_delivery' &&
                        item.status?.toLowerCase() == 'collected' &&
                        !isOtpVerified) ...[
                      // Show "Deliver" button when order status is "out_for_delivery" and item status is "collected"
                      CustomButton(
                        width: 100.w,
                        height: 40.h,
                        textSize: 15.sp,
                        text: AppLocalizations.of(context)!.deliver,
                        onPressed:
                            () => _showDeliveryBottomSheet(
                              context,
                              shouldOpenOtpDialog,
                            ),
                        isLoading: isLoading,
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                        borderRadius: 8.r,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else if (isCollected) ...[
                      // Show tick mark and "Collected" text when item is collected (for collection mode or assigned orders)
                      // BUT if order status is "out_for_delivery", show "Deliver" button instead
                      if (orderStatus?.toLowerCase() == 'out_for_delivery' ||
                          item.reachedDestination == true) ...[
                        // Show "Deliver" button when reached destination and item is collected
                        CustomButton(
                          width: 100.w,
                          height: 40.h,
                          textSize: 15.sp,
                          text: AppLocalizations.of(context)!.deliver,
                          onPressed:
                              () => _showDeliveryBottomSheet(
                                context,
                                shouldOpenOtpDialog,
                              ),
                          isLoading: isLoading,
                          backgroundColor: AppColors.primaryColor,
                          textColor: Colors.white,
                          borderRadius: 8.r,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          textStyle: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        // Show "Collected" tickmark when item is collected but has not reached destination and not out for delivery
                        Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 24.sp,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              text: AppLocalizations.of(context)!.collected,
                              fontSize: 12.sp,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ],
                    ] else ...[
                      // Show "Collect" button when item is not collected
                      // Show "Collect" button when item is not collected
                      CustomButton(
                        width: 100.w,
                        height: 40.h,
                        textSize: 15.sp,
                        text: AppLocalizations.of(context)!.collect,
                        onPressed: () {
                          onCollect?.call();
                        },
                        isLoading: isLoading,
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                        borderRadius: 8.r,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        textStyle: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
