import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../config/colors.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../router/app_routes.dart';
import '../../../../../../utils/widgets/custom_button.dart';
import '../../../../../../utils/widgets/custom_text.dart';
import '../../../../model/available_orders.dart';
import 'store_item_widget.dart';
import 'delivery_address_widget.dart';

class BottomCardWidget extends StatefulWidget {
  final Orders order;
  final bool hasReachedDestination;
  final List<RouteDetails> filteredStores;
  final bool shouldShowNumbers;
  final double distanceToStores; // Add distance parameter

  const BottomCardWidget({
    super.key,
    required this.order,
    required this.hasReachedDestination,
    required this.filteredStores,
    required this.shouldShowNumbers,
    required this.distanceToStores, // Add distance parameter
  });

  @override
  State<BottomCardWidget> createState() => _BottomCardWidgetState();
}

class _BottomCardWidgetState extends State<BottomCardWidget> {
  bool _isExpanded = true; // Default to expanded

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height:
            _isExpanded ? null : 80.h, // null = auto height based on content
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            // Draggable handle bar
            GestureDetector(
              onTap: _toggleExpansion,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 10.h),
                child: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 26.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),

            // Content with conditional display
            if (_isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Take minimum height needed
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.store,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: CustomText(
                            text:
                                widget.hasReachedDestination
                                    ? AppLocalizations.of(
                                      context,
                                    )!.deliveryRoute
                                    : '${AppLocalizations.of(context)!.storePickup} ',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        // Distance
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: CustomText(
                            text:
                                '${widget.distanceToStores.toStringAsFixed(1)} ${AppLocalizations.of(context)!.km}', // Use actual calculated distance
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Stores List
                    ...widget.filteredStores.asMap().entries.map((entry) {
                      final index = entry.key;
                      final store = entry.value;
                      return StoreItemWidget(
                        store: store,
                        index: index,
                        shouldShowNumbers: widget.shouldShowNumbers,
                      );
                    }),

                    // Delivery Address (only show when hasReachedDestination is true)
                    if (widget.hasReachedDestination)
                      DeliveryAddressWidget(
                        shippingAddress1: widget.order.shippingAddress1,
                        shippingAddress2: widget.order.shippingAddress2,
                      ),

                    SizedBox(height: 20.h),

                    // View Details Button
                    CustomButton(
                      text: AppLocalizations.of(context)!.viewDetails,
                      width: double.infinity,
                      textSize: 15.sp,
                      // borderRadius: 12.r,
                      backgroundColor: AppColors.primaryColor,
                      textColor: Colors.white,
                      onPressed: () {
                        context.push(
                          AppRoutes.orderDetails,
                          extra: {
                            'orderId': widget.order.id!,
                            'from': true,
                            'sourceTab': 1, // 1 = My Orders tab
                          },
                        );
                      },
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),

            // Minimized state content
            if (!_isExpanded)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        text:
                            '${widget.filteredStores.length} stores to pickup',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Icon(Icons.touch_app, color: Colors.grey[600], size: 16.sp),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
