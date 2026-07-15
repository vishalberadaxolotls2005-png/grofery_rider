import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grofery_rider/config/colors.dart';
import 'package:grofery_rider/screens/feed_page/widgets/my_orders/my_order_card.dart';
import 'package:grofery_rider/utils/widgets/loading_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/empty_state_widget.dart';
import '../../bloc/my_orders_bloc/my_orders_bloc.dart';
import '../../bloc/my_orders_bloc/my_orders_event.dart';
import '../../bloc/my_orders_bloc/my_orders_state.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class MyOrdersSection extends StatefulWidget {
  final bool isDarkTheme;
  final bool isDeliveryBoyActive;

  const MyOrdersSection({
    super.key,
    required this.isDarkTheme,
    required this.isDeliveryBoyActive,
  });

  @override
  State<MyOrdersSection> createState() => _MyOrdersSectionState();
}

class _MyOrdersSectionState extends State<MyOrdersSection>
    with AutomaticKeepAliveClientMixin<MyOrdersSection> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Only load my orders when the delivery boy is active and if not already loaded
    if (widget.isDeliveryBoyActive) {
      final state = context.read<MyOrdersBloc>().state;
      if (state is MyOrdersInitial) {
        context.read<MyOrdersBloc>().add(AllMyOrdersList());
      }
    }

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final currentState = context.read<MyOrdersBloc>().state;
      if (currentState is MyOrdersLoaded) {
        context.read<MyOrdersBloc>().add(
          LoadMoreMyOrders(currentState.selectedFilter),
        );
      }
    }
  }

  void _showFilterBottomSheet(String currentFilter) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: AppLocalizations.of(context)!.filter,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      _buildFilterOption(
                        currentFilter,
                        'all',
                        AppLocalizations.of(context)!.all,
                        Icons.done_all_sharp,
                      ),
                      _buildFilterOption(
                        currentFilter,
                        'assigned',
                        AppLocalizations.of(context)!.assigned,
                        Icons.assignment,
                      ),
                      _buildFilterOption(
                        currentFilter,
                        'in_progress',
                        AppLocalizations.of(context)!.outForDelivery,
                        Icons.delivery_dining,
                      ),
                      _buildFilterOption(
                        currentFilter,
                        'completed',
                        AppLocalizations.of(context)!.delivered,
                        Icons.check_circle,
                      ),
                      _buildFilterOption(
                        currentFilter,
                        'canceled',
                        AppLocalizations.of(context)!.cancelled,
                        Icons.cancel,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    String currentFilter,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = currentFilter == value;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Reload orders with new filter
        context.read<MyOrdersBloc>().add(
          AllMyOrdersList(type: value, forceRefresh: true),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).iconTheme.color,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomText(
                text: label,
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).primaryColor,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(String currentFilter) {
    switch (currentFilter) {
      case 'all':
        return AppLocalizations.of(context)!.all;
      case 'assigned':
        return AppLocalizations.of(context)!.assigned;
      case 'in_progress':
        return AppLocalizations.of(context)!.outForDelivery;
      case 'completed':
        return AppLocalizations.of(context)!.delivered;
      case 'canceled':
        return AppLocalizations.of(context)!.cancelled;
      default:
        return AppLocalizations.of(context)!.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<MyOrdersBloc, MyOrdersState>(
      listener: (context, state) {
        /*if (state is MyOrdersError) {
          ToastManager.show(
            context: context,
            message: state.errorMessage,
            type: ToastType.error,
          );
        }*/
        if (state is MyOrdersLoading) {
          setState(() {
            _isRefreshing = true;
          });
        } else if (state is MyOrdersLoaded || state is MyOrdersError) {
          setState(() {
            _isRefreshing = false;
          });
        }
      },
      builder: (context, state) {
        // Check if delivery boy is not active
        if (!widget.isDeliveryBoyActive) {
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
                  text: AppLocalizations.of(context)!.noOrdersFound,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: AppLocalizations.of(context)!.noOrdersAcceptedYet,
                  fontSize: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                CustomText(
                  text: "Please activate your status to see your orders",
                  fontSize: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is MyOrdersLoading) {
          return const Center(child: LoadingWidget());
        }

        if (state is MyOrdersError) {
          return EmptyStateWidget.noData(
            onRetry: () {
              context.read<MyOrdersBloc>().add(AllMyOrdersList());
            },
          );
        }

        if (state is MyOrdersLoaded || state is MyOrdersRefreshing) {
          final myOrders =
              state is MyOrdersLoaded
                  ? (state).myOrders
                  : (state as MyOrdersRefreshing).myOrders;
          final hasReachedMax =
              state is MyOrdersLoaded
                  ? (state).hasReachedMax
                  : (state as MyOrdersRefreshing).hasReachedMax;
          final totalOrders =
              state is MyOrdersLoaded
                  ? (state).totalOrders
                  : (state as MyOrdersRefreshing).totalOrders;
          final selectedFilter =
              state is MyOrdersLoaded
                  ? (state).selectedFilter
                  : (state as MyOrdersRefreshing).selectedFilter;
          final isRefreshing = state is MyOrdersRefreshing;

          // Filter orders based on selected filter. Respect the selected
          // filter instead of unconditionally removing completed/canceled.
          final filteredOrders = () {
            final list = myOrders.toList();
            if (selectedFilter == 'completed') {
              return list.where((order) {
                final status = order.status?.toLowerCase();
                return status == 'delivered' || status == 'completed';
              }).toList();
            } else if (selectedFilter == 'canceled') {
              return list.where((order) {
                final status = order.status?.toLowerCase();
                return status == 'canceled';
              }).toList();
            } else if (selectedFilter == 'in_progress') {
              return list.where((order) {
                final status = order.status?.toLowerCase();
                return status == 'in_progress' ||
                    status == 'out_for_delivery' ||
                    status == 'on_the_way';
              }).toList();
            }

            // Default: 'assigned' or any other value -> show non-finalized orders
            return list.where((order) {
              final status = order.status?.toLowerCase();
              return status != 'delivered' &&
                  status != 'completed' &&
                  status != 'canceled';
            }).toList();
          }();

          // Always show header (filter row) even when there are zero results.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.myOrders,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    Row(
                      children: [
                        CustomText(
                          text: AppLocalizations.of(
                            context,
                          )!.ordersCount(totalOrders.toString()),
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentGeometry.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0.h),
                  child: InkWell(
                    onTap: () => _showFilterBottomSheet(selectedFilter),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 18.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            text: _getFilterLabel(selectedFilter),
                            fontSize: 12.sp,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<MyOrdersBloc>().add(
                          AllMyOrdersList(forceRefresh: true),
                        );
                      },
                      child: Builder(
                        builder: (context) {
                          if (filteredOrders.isEmpty) {
                            return ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 16.h),
                              children: [
                                SizedBox(height: 40.h),
                                Center(
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
                                            AppLocalizations.of(
                                              context,
                                            )!.noOrdersFound,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      SizedBox(height: 8.h),
                                      CustomText(
                                        text:
                                            AppLocalizations.of(
                                              context,
                                            )!.noOrdersAcceptedYet,
                                        fontSize: 14.sp,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
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
                                                  context
                                                      .read<MyOrdersBloc>()
                                                      .add(
                                                        AllMyOrdersList(
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
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
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
                                                  : AppLocalizations.of(
                                                    context,
                                                  )!.refresh,
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24.w,
                                            vertical: 12.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 16.h),
                            itemCount:
                                filteredOrders.length + (hasReachedMax ? 0 : 1),
                            itemBuilder: (context, index) {
                              if (index >= filteredOrders.length) {
                                return Padding(
                                  padding: EdgeInsets.all(16.0.w),
                                  child: Center(
                                    child: LoadingWidget(size: 100.sp),
                                  ),
                                );
                              }

                              final order = filteredOrders[index];
                              return MyOrderCard(
                                order: order,
                                isDarkTheme: widget.isDarkTheme,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (isRefreshing)
                      Align(
                        alignment: AlignmentGeometry.topCenter,
                        child: Container(
                          padding: EdgeInsets.all(8.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4.r,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }

        return EmptyStateWidget.noData(
          onRetry: () {
            context.read<MyOrdersBloc>().add(AllMyOrdersList());
          },
        );
      },
    );
  }
}
