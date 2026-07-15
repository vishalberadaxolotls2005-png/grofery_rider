import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:lottie/lottie.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/toast_message.dart';
import '../../../utils/currency_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../../feed_page/model/available_orders.dart';
import '../bloc/delivered_orders/delivered_orders_bloc.dart';

import '../bloc/delivered_orders/delivered_orders_event.dart';
import '../bloc/delivered_orders/delivered_orders_state.dart';

class ViewHistoryOfOrders extends StatefulWidget {
  const ViewHistoryOfOrders({super.key});

  @override
  State<ViewHistoryOfOrders> createState() => _ViewHistoryOfOrdersState();
}

class _ViewHistoryOfOrdersState extends State<ViewHistoryOfOrders> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Load completed orders when the page is initialized
    context.read<DeliveredOrdersBloc>().add(const LoadDeliveredOrders());

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DeliveredOrdersBloc>().add(
        const LoadMoreDeliveredOrders(''),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.viewHistory,
      ),

      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<DeliveredOrdersBloc, DeliveredOrdersState>(
              listener: (context, state) {
                if (state is DeliveredOrdersError) {
                  ToastManager.show(
                    context: context,
                    message: state.errorMessage,
                    type: ToastType.error,
                  );
                }
                // Update loading state based on bloc state
                if (state is DeliveredOrdersLoading) {
                  setState(() {
                    _isRefreshing = true;
                  });
                } else if (state is DeliveredOrdersLoaded ||
                    state is DeliveredOrdersError) {
                  setState(() {
                    _isRefreshing = false;
                  });
                }
              },
              builder: (context, state) {
                if (state is DeliveredOrdersLoading && !_isRefreshing) {
                  return const Center(child: LoadingWidget());
                }

                if (state is DeliveredOrdersError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.w,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text:
                              AppLocalizations.of(context)!.errorLoadingOrders,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: state.errorMessage,
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DeliveredOrdersBloc>().add(
                              const LoadDeliveredOrders(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: CustomText(
                            text: AppLocalizations.of(context)!.retry,
                            fontSize: 16.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DeliveredOrdersLoaded ||
                    state is DeliveredOrdersRefreshing) {
                  final deliveredOrders =
                      state is DeliveredOrdersLoaded
                          ? (state).deliveredOrders
                          : (state as DeliveredOrdersRefreshing)
                              .deliveredOrders;
                  final hasReachedMax =
                      state is DeliveredOrdersLoaded
                          ? (state).hasReachedMax
                          : (state as DeliveredOrdersRefreshing).hasReachedMax;
                  final totalOrders =
                      state is DeliveredOrdersLoaded
                          ? (state).totalOrders
                          : (state as DeliveredOrdersRefreshing).totalOrders;

                  if (deliveredOrders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 200.h,
                            width: 250.w,
                            child: Lottie.asset(
                              'assets/lottie/NotDataFound.json',
                              width: 150.w,
                              height: 150.h,
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          CustomText(
                            text:
                                AppLocalizations.of(context)!.noDeliveredOrders,
                            fontSize: 18.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 8.h),
                          CustomText(
                            text:
                                AppLocalizations.of(
                                  context,
                                )!.noDeliveredOrdersYet,
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton.icon(
                            onPressed:
                                _isRefreshing
                                    ? null
                                    : () {
                                      setState(() {
                                        _isRefreshing = true;
                                      });
                                      context.read<DeliveredOrdersBloc>().add(
                                        const LoadDeliveredOrders(
                                          forceRefresh: true,
                                        ),
                                      );
                                    },
                            icon:
                                _isRefreshing
                                    ? SizedBox(
                                      width: 20.sp,
                                      height: 20.sp,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                            label: CustomText(
                              text:
                                  _isRefreshing
                                      ? "Refreshing..."
                                      : AppLocalizations.of(context)!.refresh,
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with count
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text:
                                  AppLocalizations.of(context)!.ordersDelivered,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: CustomText(
                                text: totalOrders.toString(),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Orders List
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<DeliveredOrdersBloc>().add(
                              const LoadDeliveredOrders(forceRefresh: true),
                            );
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount:
                                deliveredOrders.length +
                                (hasReachedMax ? 0 : 1),
                            itemBuilder: (context, index) {
                              if (index >= deliveredOrders.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  child: Center(
                                    child: LoadingWidget(size: 100.sp),
                                  ),
                                );
                              }

                              final order = deliveredOrders[index];
                              return _DeliveredOrderCard(order: order);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveredOrderCard extends StatelessWidget {
  final Orders order;

  const _DeliveredOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section with gradient
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withValues(alpha: 0.08),
                  Colors.green.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order ID with icon
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 18.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "Order ID",
                              fontSize: 11.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 2.h),
                            CustomText(
                              text: "#${order.uuid ?? 'N/A'}",
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Status badge with shadow
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green,
                        Colors.green.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 14.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: AppLocalizations.of(context)!.completed,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info with enhanced styling
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 18.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: CustomText(
                              text: order.shippingName ?? 'N/A',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 18.sp,
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: CustomText(
                              text: _buildAddressText(),
                              fontSize: 13.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // Phone
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.phone_rounded,
                              size: 18.sp,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          CustomText(
                            text:
                                "${order.shippingPhonecode ?? ''} ${order.shippingPhone ?? 'N/A'}",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Order Details with cards
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        context,
                        order.items != null && order.items!.length > 1
                            ? AppLocalizations.of(context)!.items
                            : AppLocalizations.of(context)!.item,


                        "${order.items?.length ?? 0}",
                        Icons.inventory_2_rounded,
                        Colors.purple,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildDetailCard(
                        context,
                        AppLocalizations.of(context)!.total,
                        CurrencyFormatter.formatAmount(
                          context,
                          order.finalTotal ?? '0',
                        ),
                        Icons.payments_rounded,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Delivery date with icon
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.event_available_rounded,
                          size: 18.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: AppLocalizations.of(context)!.deliveredOn,
                              fontSize: 11.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 2.h),
                            CustomText(
                              text: _formatDate(order.updatedAt),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24.sp, color: color),
          SizedBox(height: 8.h),
          CustomText(
            text: value,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: label,
            fontSize: 11.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _buildAddressText() {
    final parts = <String>[];
    if (order.shippingAddress1?.isNotEmpty == true) {
      parts.add(order.shippingAddress1!);
    }
    if (order.shippingAddress2?.isNotEmpty == true) {
      parts.add(order.shippingAddress2!);
    }
    if (order.shippingLandmark?.isNotEmpty == true) {
      parts.add(order.shippingLandmark!);
    }
    if (order.shippingCity?.isNotEmpty == true) parts.add(order.shippingCity!);
    if (order.shippingState?.isNotEmpty == true) {
      parts.add(order.shippingState!);
    }

    return parts.isEmpty ? 'Address not available' : parts.join(', ');
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

// Wrapper class that provides the BlocProvider
class ViewHistoryOfOrdersWithBloc extends StatelessWidget {
  const ViewHistoryOfOrdersWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveredOrdersBloc(),
      child: const ViewHistoryOfOrders(),
    );
  }
}
