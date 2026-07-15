// return_orders_section.dart  ← RENAME THIS FILE (recommended)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/screens/feed_page/bloc/return_order/return_orders_list_bloc/return_order_list_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import '../../bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import '../return_order/return_order_card.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class ReturnOrdersSection extends StatefulWidget {
  final bool isDeliveryBoyActive;

  const ReturnOrdersSection({super.key, required this.isDeliveryBoyActive});

  @override
  State<ReturnOrdersSection> createState() => _ReturnOrdersSectionState();
}

class _ReturnOrdersSectionState extends State<ReturnOrdersSection>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false; // Add loading state for refresh button

  @override
  bool get wantKeepAlive => true; // Keeps state when switching tabs

  @override
  void initState() {
    super.initState();
    if (widget.isDeliveryBoyActive) {
      context.read<ReturnOrderListBloc>().add(FetchReturnOrders());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Don't auto-refresh when switching tabs. Only refresh on explicit user action.
    // Remove the automatic refresh call here to prevent tab switching from triggering refresh.
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ReturnOrderListBloc>().add(LoadMoreReturnOrders());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // ← THIS IS THE KEY FIX: Use a layout that fills the screen
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child:
          widget.isDeliveryBoyActive
              ? _buildActiveContent()
              : _buildInactiveWidget(),
    );
  }

  Widget _buildActiveContent() {
    return BlocConsumer<ReturnOrderListBloc, ReturnOrderListState>(
      listener: (context, state) {
        /*if (state is ReturnOrderListError) {
          ToastManager.show(
            context: context,
            message: state.message,
            type: ToastType.error,
          );
        }*/
        // Update loading state based on bloc state
        if (state is ReturnOrderListLoading) {
          setState(() {
            _isRefreshing = true;
          });
        } else if (state is ReturnOrderListLoaded ||
            state is ReturnOrderListError) {
          setState(() {
            _isRefreshing = false;
          });
        }
      },
      builder: (context, state) {
        if (state is ReturnOrderListLoading) {
          return const Center(child: LoadingWidget());
        }

        if (state is ReturnOrderListLoaded ||
            state is ReturnOrderListRefreshing) {
          final orders =
              state is ReturnOrderListLoaded
                  ? (state).orders
                  : (state as ReturnOrderListRefreshing).orders;
          final hasReachedMax =
              state is ReturnOrderListLoaded
                  ? (state).hasReachedMax
                  : (state as ReturnOrderListRefreshing).hasReachedMax;
          final isRefreshing = state is ReturnOrderListRefreshing;

          if (orders.isEmpty) {
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
                    text: AppLocalizations.of(context)!.noReturnOrdersAvailable,
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
                              context.read<ReturnOrderListBloc>().add(
                                FetchReturnOrders(forceRefresh: true),
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
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.availPickupOrders,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    CustomText(
                      text: AppLocalizations.of(
                        context,
                      )!.ordersCount(orders.length.toString()),
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
                        context.read<ReturnOrderListBloc>().add(
                          FetchReturnOrders(forceRefresh: true),
                        );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        itemCount: orders.length + (hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= orders.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: LoadingWidget(size: 60)),
                            );
                          }
                          return ReturnOrderCard(pickup: orders[index]);
                        },
                      ),
                    ),
                    if (isRefreshing)
                      Positioned(
                        top: 10,
                        right: 30,
                        child: Container(
                          padding: EdgeInsets.all(8.h),
                          decoration: BoxDecoration(
                            color: Colors.green,
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
                            child: CircularProgressIndicator(),
                          ),
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
                text: AppLocalizations.of(context)!.noReturnOrdersAvailable,
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
                          context.read<ReturnOrderListBloc>().add(
                            FetchReturnOrders(forceRefresh: true),
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
                        : Icon(Icons.refresh, color: Colors.white, size: 20.sp),
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
