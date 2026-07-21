import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/colors.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../../../config/app_images.dart';
import '../../../../utils/widgets/custom_card.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../bloc/accept_order_bloc/accept_order_bloc.dart';
import '../../bloc/accept_order_bloc/accept_order_event.dart';
import '../../bloc/accept_order_bloc/accept_order_state.dart';
import '../../bloc/available_orders_bloc/available_orders_bloc.dart';
import '../../bloc/available_orders_bloc/available_orders_event.dart';
import '../../model/available_orders.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/widgets/toast_message.dart';
import '../../../../utils/currency_formatter.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class AvailableGroupOrderCard extends StatelessWidget {
  final PincodeClusterItem clusterItem;

  const AvailableGroupOrderCard({super.key, required this.clusterItem});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AcceptOrderBloc(),
      child: _AvailableGroupOrderCardContent(clusterItem: clusterItem),
    );
  }
}

class _AvailableGroupOrderCardContent extends StatelessWidget {
  final PincodeClusterItem clusterItem;

  const _AvailableGroupOrderCardContent({required this.clusterItem});

  @override
  Widget build(BuildContext context) {
    final pincodeCluster = clusterItem.cluster;
    final firstOrder = pincodeCluster.orders?.isNotEmpty == true ? pincodeCluster.orders!.first : null;
    
    String exactTimeSlot = clusterItem.timeSlot ?? 'Unknown Time Slot';
    if (firstOrder?.deliveryTimeSlot != null) {
      final dt = firstOrder!.deliveryTimeSlot!;
      if (dt.startTime != null && dt.endTime != null) {
        exactTimeSlot = '${dt.startTime} - ${dt.endTime}';
      } else if (dt.title != null) {
        exactTimeSlot = dt.title!;
      }
    }
    
    // Calculate total earnings or payable
    double totalAmount = 0;
    if (pincodeCluster.orders != null) {
      for (var order in pincodeCluster.orders!) {
        totalAmount += double.tryParse(order.totalPayable ?? '0') ?? 0;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with earnings and distance
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expected earning / Total Value
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Total Value",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: CurrencyFormatter.formatAmount(
                          context,
                          totalAmount.toStringAsFixed(2),
                        ),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ],
                  ),
                  // Pincode / Cluster Info
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'Pincode',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        SizedBox(height: 1.h),
                        CustomText(
                          text: '${pincodeCluster.pincode ?? '-'}',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pickup section
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.group_work,
                            size: 14.sp,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: 'Group Order (${pincodeCluster.orderCount ?? 0} Orders)',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                      if (firstOrder?.deliveryRoute?.routeDetails != null &&
                          firstOrder!.deliveryRoute!.routeDetails!.isNotEmpty)
                        GestureDetector(
                          onTap: () => _navigateToMapDeliveryPage(context, firstOrder),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.oppColorChange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.sameColorChange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.map,
                              size: 12.sp,
                              color: Theme.of(context).colorScheme.oppColorChange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 4.r,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomText(
                            text: 'G',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: exactTimeSlot,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              text: 'Multiple pickups/drop-offs in pincode ${pincodeCluster.pincode}',
                              fontSize: 11.sp,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (pincodeCluster.orders != null && pincodeCluster.orders!.isNotEmpty)
                    Column(
                      children: pincodeCluster.orders!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final order = entry.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 22.w,
                                height: 22.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CustomText(
                                    text: '${index + 1}',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: CustomText(
                                  text: 'Order #${order.id ?? order.slug}',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              CustomText(
                                text: CurrencyFormatter.formatAmount(
                                  context,
                                  order.totalPayable ?? '0',
                                ),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // Accept button section
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: BlocConsumer<AcceptOrderBloc, AcceptOrderState>(
                listener: (context, state) {
                  if (state is AcceptOrderSuccess) {
                    ToastManager.show(
                      context: context,
                      message: state.message,
                      type: ToastType.success,
                    );
                    if (firstOrder != null) {
                      _navigateToMapDeliveryPage(context, firstOrder);
                    }
                  } else if (state is AcceptOrderCompleted) {
                    context.read<AvailableOrdersBloc>().add(
                      AllAvailableOrdersList(forceRefresh: true),
                    );
                  } else if (state is AcceptOrderError) {
                    ToastManager.show(
                      context: context,
                      message: state.errorMessage,
                      type: ToastType.error,
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AcceptOrderLoading;

                  return SwipeButton(
                    thumbPadding: EdgeInsets.all(4.w),
                    borderRadius: BorderRadius.circular(22.r),
                    inactiveThumbColor: Colors.white,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: AppColors.primaryColor.withValues(alpha: 0.8),
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
                        child: isLoading
                            ? LoadingWidget(size: 25.w)
                            : Image.asset(
                                AppImages.arrowRight,
                                width: 25.w,
                                height: 25.h,
                              ),
                      ),
                    ),
                    onSwipe: () async {
                      if (!isLoading && pincodeCluster.orders != null && pincodeCluster.orders!.isNotEmpty) {
                        // Extract all order IDs in the group
                        List<int> orderIds = pincodeCluster.orders!
                            .where((o) => o.id != null)
                            .map((o) => o.id!)
                            .toList();

                        if (orderIds.isNotEmpty) {
                          context.read<AcceptOrderBloc>().add(
                            AcceptGroupOrder(orderIds),
                          );
                        } else {
                          ToastManager.show(
                            context: context,
                            message: "No valid orders found in this group.",
                            type: ToastType.error,
                          );
                        }
                      } else if (pincodeCluster.orders == null || pincodeCluster.orders!.isEmpty) {
                        ToastManager.show(
                          context: context,
                          message: "No valid orders found in this group.",
                          type: ToastType.error,
                        );
                      }
                    },
                    child: CustomText(
                      text: isLoading
                          ? AppLocalizations.of(context)!.accepting
                          : "Accept Group Order",
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToMapDeliveryPage(
      BuildContext context,
      Orders order,
      ) async {
    String destinationLat = '0.0';
    String destinationLng = '0.0';

    if (order.deliveryRoute?.routeDetails != null &&
        order.deliveryRoute!.routeDetails!.isNotEmpty) {
      final storeLocation = order.deliveryRoute!.routeDetails!.first;
      if (storeLocation.latitude != null && storeLocation.longitude != null) {
        destinationLat = storeLocation.latitude.toString();
        destinationLng = storeLocation.longitude.toString();
      }
    } else if (order.shippingLatitude != null && order.shippingLongitude != null) {
      destinationLat = order.shippingLatitude.toString();
      destinationLng = order.shippingLongitude.toString();
    }

    try {
      context.push(
        AppRoutes.mapDelivery,
        extra: {
          'order': order,
          'currentLat': destinationLat,
          'currentLng': destinationLng,
          'groupOrders': clusterItem.cluster.orders,
        },
      );
    } catch (e) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.navigationError(e.toString()),
        type: ToastType.error,
      );
    }
  }


}
