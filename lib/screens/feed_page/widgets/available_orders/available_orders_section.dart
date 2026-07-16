import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../bloc/available_orders_bloc/available_orders_bloc.dart';
import '../../bloc/available_orders_bloc/available_orders_event.dart';
import '../../bloc/available_orders_bloc/available_orders_state.dart';
import 'available_order_card.dart';
import 'available_group_order_card.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import '../../bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import '../../model/available_orders.dart';

class AvailableOrdersSection extends StatefulWidget {
  final bool isDeliveryBoyActive; // Add this parameter

  const AvailableOrdersSection({
    super.key,
    required this.isDeliveryBoyActive, // Add this parameter
  });

  @override
  State<AvailableOrdersSection> createState() => _AvailableOrdersSectionState();
}

class _AvailableOrdersSectionState extends State<AvailableOrdersSection> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false; // Add loading state for refresh button

  @override
  void initState() {
    super.initState();
    // Only load available orders when the delivery boy is active
    if (widget.isDeliveryBoyActive) {
      context.read<AvailableOrdersBloc>().add(AllAvailableOrdersList());
    }
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Don't auto-refresh when switching tabs. Only refresh on explicit user action.
    // Remove the automatic refresh call here to prevent tab switching from triggering refresh.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AvailableOrdersBloc>().add(LoadMoreAvailableOrders(''));
    }
  }

  @override
  Widget build(BuildContext context) {
    // If delivery boy is inactive, show inactive widget
    if (!widget.isDeliveryBoyActive) {
      return _buildInactiveWidget();
    }

    return BlocConsumer<AvailableOrdersBloc, AvailableOrdersState>(
      listener: (context, state) {
        // if (state is AvailableOrdersError) {
        //   ToastManager.show(
        //     context: context,
        //     message: state.errorMessage,
        //     type: ToastType.error,
        //   );
        // }
        // Update loading state based on bloc state
        if (state is AvailableOrdersLoading) {
          setState(() {
            _isRefreshing = true;
          });
        } else if (state is AvailableOrdersLoaded ||
            state is AvailableOrdersError) {
          setState(() {
            _isRefreshing = false;
          });
        }
      },
      builder: (context, state) {
        if (state is AvailableOrdersLoading) {
          return const Center(child: LoadingWidget());
        }

        if (state is AvailableOrdersLoaded ||
            state is AvailableOrdersRefreshing) {
          final allOrders =
              state is AvailableOrdersLoaded
                  ? (state).availableOrders
                  : (state as AvailableOrdersRefreshing).availableOrders;
          final hasReachedMax =
              state is AvailableOrdersLoaded
                  ? (state).hasReachedMax
                  : (state as AvailableOrdersRefreshing).hasReachedMax;

          if (allOrders.isEmpty) {
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
                  // Image.asset(AppImages.noOrder, height: 200.h, width: 200.w),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: AppLocalizations.of(context)!.noAvailableOrders,
                    fontSize: 18.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: AppLocalizations.of(context)!.ordersWillAppearHere,
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
                              // Set loading state immediately when button is clicked
                              setState(() {
                                _isRefreshing = true;
                              });
                              context.read<AvailableOrdersBloc>().add(
                                AllAvailableOrdersList(forceRefresh: true),
                              );
                            },
                    icon:
                        _isRefreshing
                            ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                              ? AppLocalizations.of(context)!.refreshing
                              : AppLocalizations.of(context)!.refresh,
                      fontSize: 16,
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.availableOrders,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      text: AppLocalizations.of(
                        context,
                      )!.ordersCount(allOrders.length.toString()),
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<AvailableOrdersBloc>().add(
                          AllAvailableOrdersList(forceRefresh: true),
                        );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Enable overscroll even with few items
                        padding: EdgeInsets.only(bottom: 16.h),
                        itemCount: allOrders.length + (hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= allOrders.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Center(child: LoadingWidget(size: 100.sp)),
                            );
                          }

                          final item = allOrders[index];
                          if (item is PincodeClusterItem) {
                            return AvailableGroupOrderCard(clusterItem: item);
                          } else if (item is Orders) {
                            return AvailableOrderCard(order: item);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

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
              // Image.asset(AppImages.noOrder, height: 200.h, width: 200.w),
              SizedBox(height: 16.h),
              CustomText(
                text: AppLocalizations.of(context)!.noAvailableOrders,
                fontSize: 18.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: AppLocalizations.of(context)!.ordersWillAppearHere,
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
                  // Set loading state immediately when button is clicked
                  setState(() {
                    _isRefreshing = true;
                  });
                  context.read<AvailableOrdersBloc>().add(
                    AllAvailableOrdersList(forceRefresh: true),
                  );
                },
                icon:
                _isRefreshing
                    ? SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
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
                      ? AppLocalizations.of(context)!.refreshing
                      : AppLocalizations.of(context)!.refresh,
                  fontSize: 16,
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
      },
    );
  }

  Widget _buildInactiveWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/notactive.json',
              width: 200.w,
              height: 200.h,
              fit: BoxFit.cover,
              repeat: true,
              animate: true,
            ),
            // SizedBox(height: 14.h),
            CustomText(
              text: AppLocalizations.of(context)!.accountInactive,
              fontSize: 22.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            CustomText(
              text: AppLocalizations.of(context)!.activateAccountToViewOrders,
              fontSize: 16.sp,
              color: Colors.grey[600],
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () {
                // Try to activate the status
                context.read<DeliveryBoyStatusBloc>().add(ToggleStatus(true));
              },
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 20.sp,
              ),
              label: CustomText(
                text: AppLocalizations.of(context)!.activateAccount,
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 2,
              ),
            ),
            SizedBox(height: 16.h),
            CustomText(
              text: AppLocalizations.of(context)!.tapPowerButtonToGoOnline,
              fontSize: 14.sp,
              color: Colors.grey[500],
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
