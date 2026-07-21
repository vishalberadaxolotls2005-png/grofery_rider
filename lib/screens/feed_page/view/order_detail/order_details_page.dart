// ignore_for_file: unused_element, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import '../../../../config/colors.dart';
import '../../../../utils/currency_formatter.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/custom_appbar_without_navbar.dart';
import '../../../../utils/widgets/custom_scaffold.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../../../utils/widgets/toast_message.dart';
import '../../../system_settings/bloc/system_settings_bloc.dart';
import '../../../system_settings/bloc/system_settings_event.dart';
import '../../../system_settings/bloc/system_settings_state.dart';
import '../../../system_settings/repo/system_settings_repo.dart';
import '../../model/available_orders.dart';
import '../../bloc/items_collected_bloc/items_collected_bloc.dart';
import '../../bloc/items_collected_bloc/items_collected_event.dart';
import '../../bloc/items_collected_bloc/items_collected_state.dart';
import '../../bloc/order_details_bloc/order_details_bloc.dart';
import '../../bloc/order_details_bloc/order_details_event.dart';
import '../../bloc/order_details_bloc/order_details_state.dart';
import '../../bloc/available_orders_bloc/available_orders_bloc.dart';
import '../../bloc/available_orders_bloc/available_orders_event.dart';
import '../../bloc/my_orders_bloc/my_orders_bloc.dart';
import '../../bloc/my_orders_bloc/my_orders_event.dart';
import '../../repo/order_details.dart';
import '../../../../utils/widgets/custom_button.dart';
import '../../../../utils/widgets/reusable_bottom_sheet.dart';
import '../../widgets/orderdetails_widgets/index.dart';
import '../../../../router/app_routes.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'widgets/index.dart' as new_widgets;
import '../../services/order_service.dart';
import '../../services/dialog_service.dart';
import '../../../../utils/services/phone_service.dart';
import '../../../../utils/services/ui_helper_service.dart';
import '../../services/item_card_service.dart';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;
  final bool from;
  final int? sourceTab; // 0 = Available Orders, 1 = My Orders
  final bool? arrivalConfirmed; // Whether arrival has been confirmed
  final List<dynamic>? groupOrders; // List of orders if this is a group order

  const OrderDetailsPage({
    super.key,
    required this.orderId,
    this.from = false,
    this.sourceTab,
    this.arrivalConfirmed,
    this.groupOrders,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class OrderDetailsPageWithBloc extends StatelessWidget {
  final int orderId;
  final bool from;
  final int? sourceTab; // 0 = Available Orders, 1 = My Orders
  final bool? arrivalConfirmed; // Whether arrival has been confirmed
  final List<dynamic>? groupOrders;

  const OrderDetailsPageWithBloc({
    super.key,
    required this.orderId,
    this.from = false,
    this.sourceTab,
    this.arrivalConfirmed,
    this.groupOrders,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ItemsCollectedBloc()),
        BlocProvider(create: (context) => OrderDetailsBloc(OrderDetailsRepo())),
        BlocProvider(
          create: (context) => SystemSettingsBloc(SystemSettingsRepo()),
        ),
      ],
      child: OrderDetailsPage(
        orderId: orderId,
        from: from,
        sourceTab: sourceTab,
        arrivalConfirmed: arrivalConfirmed,
        groupOrders: groupOrders,
      ),
    );
  }
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with TickerProviderStateMixin {
  Orders? _fetchedOrder;

  // Local state sets for tracking item status

  // UI state variables
  bool _isItemsExpanded = true;
  bool _isDeliveryExpanded = false;
  bool _isStoreDetailsExpanded = false;
  bool _isPaymentExpanded = false;
  bool _isEarningsExpanded = false;
  bool _isPricingExpanded = false;
  bool _codPopupShown = false;
  Set<String> _processingItemIds = {};
  bool _isCollectingAll = false;
  int _bulkSuccessCount = 0;
  int _bulkTotalCount = 0;

  // Confetti controller for celebration animation
  late ConfettiController _confettiController;

  // Track if confetti has been shown for this order
  bool _hasShownConfetti = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'out_for_delivery':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getDisplayStatus(String status) {
    // Check if all items are delivered with verified OTP

    // If status is delivered and OTP is verified, don't show pending
    if (status.toLowerCase() == 'delivered') {
      return 'delivered';
    }

    return status;
  }

  bool _areAllItemsDeliveredWithOtp() {
    final order = _fetchedOrder;
    if (order?.items == null || order!.items!.isEmpty) return false;

    for (var item in order.items!) {
      if (item.status?.toLowerCase() != 'delivered' || item.otpVerified != 1) {
        return false;
      }
    }
    return true;
  }

  bool _areAllItemsDelivered() {
    return OrderService.areAllItemsDelivered(_fetchedOrder);
  }

  List<int>? _getGroupOrderIds() {
    if (widget.groupOrders == null || widget.groupOrders!.isEmpty) return null;
    return widget.groupOrders!
        .map((o) {
          if (o is Orders) return o.id;
          if (o is Map) return o['id'] as int?;
          return null;
        })
        .whereType<int>()
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Reset confetti flag for new order
    _hasShownConfetti = false;

    // Initialize arrival confirmation status from widget parameter

    // Fetch system system_settings for currency symbol

    context.read<SystemSettingsBloc>().add(FetchSystemSettings());

    // Fetch order details from API
    context.read<OrderDetailsBloc>().add(
      FetchOrderDetails(widget.orderId, groupOrderIds: _getGroupOrderIds()),
    );

    // Remove the post-frame callback that was causing state conflicts
    // WidgetsBinding.instance.addPostFrameCallback((_) {

    //   _initializeLocalStateFromApi();
    // });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This method is called when the widget's dependencies change
    // It's a good place to refresh data when navigating back to this page

    // Only refresh if we don't have order data
    // Don't refresh if we already have the latest state to preserve bloc updates
    if (_fetchedOrder == null) {
      _refreshOrderDataIfNeeded();
    } else {}
  }

  // Method to refresh order data when needed (e.g., when navigating back)
  void _refreshOrderDataIfNeeded() {
    // Only refresh if we have an order and it's been a while since last refresh
    if (_fetchedOrder != null) {
      context.read<OrderDetailsBloc>().add(
        FetchOrderDetails(widget.orderId, groupOrderIds: _getGroupOrderIds()),
      );
    }
  }

  // Method to manually refresh order data
  void _refreshOrderData() {
    // Check if current bloc state has reachedDestination items that we need to preserve
    final currentState = context.read<OrderDetailsBloc>().state;
    Map<String, bool> reachedDestinationItems = {};

    if (currentState is OrderDetailsSuccess) {
      // Preserve reachedDestination status from current bloc state
      for (var item in currentState.order.items ?? []) {
        if (item.reachedDestination == true) {
          reachedDestinationItems[item.id.toString()] = true;
        }
      }
    }

    // Clear local state first

    // Fetch fresh data from API
    context.read<OrderDetailsBloc>().add(
      FetchOrderDetails(widget.orderId, groupOrderIds: _getGroupOrderIds()),
    );

    // After API response, restore reachedDestination status
    if (reachedDestinationItems.isNotEmpty) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SystemSettingsBloc, SystemSettingsState>(
      listener: (context, state) {
        if (state is SystemSettingsLoaded) {
          // Trigger a rebuild to update currency symbols
          setState(() {});
        }
      },
      child: BlocConsumer<ItemsCollectedBloc, ItemsCollectedState>(
        listener: (context, state) {
          if (state is ItemsCollectedSuccess) {
            if (_isCollectingAll) {
              _bulkSuccessCount++;

              // Only show final toast when all items are done
              if (_bulkSuccessCount >= _bulkTotalCount) {
                setState(() {
                  _isCollectingAll = false;
                  if (_fetchedOrder?.items != null) {
                    List<Items> updatedItems =
                        _fetchedOrder!.items!.map((item) {
                          return item.status?.toLowerCase() != 'delivered'
                              ? item.copyWith(status: 'collected')
                              : item;
                        }).toList();
                    _fetchedOrder = _fetchedOrder!.copyWith(
                      items: updatedItems,
                    );
                  }
                });

                ToastManager.show(
                  context: context,
                  message:
                      AppLocalizations.of(
                        context,
                      )!.allItemsCollectedSuccessfully,
                  type: ToastType.success,
                );

                context.read<OrderDetailsBloc>().add(
                  FetchOrderDetails(
                    widget.orderId,
                    groupOrderIds: _getGroupOrderIds(),
                  ),
                );
              }
            } else {
              // Individual item success
              setState(() {
                if (_fetchedOrder?.items != null && state.itemId != null) {
                  List<Items> updatedItems = _fetchedOrder!.items!.map((item) {
                    if (item.id.toString() == state.itemId) {
                      // Determine if it was a collection or delivery based on the explicit action
                      String newStatus = state.action ?? 'collected';
                      return item.copyWith(status: newStatus);
                    }
                    return item;
                  }).toList();
                  _fetchedOrder = _fetchedOrder!.copyWith(items: updatedItems);
                  
                  _processingItemIds.remove(state.itemId);
                } else if (_fetchedOrder?.items != null) {
                  _processingItemIds.clear();
                }
              });

              String action = state.action ?? 'collected';
              ToastManager.show(
                context: context,
                message: action == 'delivered'
                        ? AppLocalizations.of(context)!.itemDeliveredSuccessfully
                        : AppLocalizations.of(context)!.itemCollectedSuccessfully,
                type: ToastType.success,
              );
            }
          } else if (state is ItemsCollectedError) {
            setState(() {
              _processingItemIds.clear();
              _isCollectingAll = false;
            });

            ToastManager.show(
              context: context,
              message: state.errorMessage,
              type: ToastType.error,
            );
          }
        },
        builder: (context, itemsCollectedState) {
          return BlocConsumer<OrderDetailsBloc, OrderDetailsState>(
            listener: (context, state) {
              if (state is OrderDetailsSuccess) {
                // Check if we need to restore reachedDestination status from previous state
                setState(() {
                  Orders newOrder = state.order;
                  // Preserve item statuses locally in case backend is slow to update
                  if (_fetchedOrder != null && _fetchedOrder!.items != null && newOrder.items != null) {
                    List<Items> mergedItems = newOrder.items!.map((newItem) {
                      Items? oldItem;
                      try {
                        oldItem = _fetchedOrder!.items!.firstWhere((i) => i.id == newItem.id);
                      } catch (e) {
                        oldItem = null;
                      }
                      
                      if (oldItem != null) {
                        // If it was collected locally, keep it collected unless backend says it's delivered
                        if (oldItem.status?.toLowerCase() == 'collected' && newItem.status?.toLowerCase() != 'delivered') {
                          return newItem.copyWith(status: 'collected');
                        }
                        // If it was delivered locally, keep it delivered
                        if (oldItem.status?.toLowerCase() == 'delivered') {
                          return newItem.copyWith(status: 'delivered');
                        }
                      }
                      return newItem;
                    }).toList();
                    newOrder = newOrder.copyWith(items: mergedItems);
                  }
                  
                  _fetchedOrder = newOrder;

                  // Reset confetti flag for new order data
                  if (_fetchedOrder?.id != widget.orderId) {
                    _hasShownConfetti = false;
                  }
                });
              } else if (state is OrderDetailsError) {
                setState(() {});
              }
            },
            builder: (context, state) {
              // Use fetched order data with restored reachedDestination values
              final order = _fetchedOrder;

              if (order == null) {
                return CustomScaffold(
                  appBar: CustomAppBarWithoutNavbar(
                    title: AppLocalizations.of(context)!.orderDetails,
                    showRefreshButton: true,
                    showThemeToggle: false,
                    onRefreshPressed: () {
                      // Only refresh if we don't have order data or if it's stale
                      // Don't refresh if we already have the latest state to preserve bloc updates
                      if (_fetchedOrder == null) {
                        _refreshOrderData();
                      } else {
                        // Show a message that data is already up to date
                        ToastManager.show(
                          context: context,
                          message: 'Order data is already up to date',
                          type: ToastType.info,
                        );
                      }
                    },
                    additionalActions: [
                      IconButton(
                        icon: Icon(
                          Icons.map,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          context.push(
                            AppRoutes.pickupRouteMap,
                            extra: {'order': order},
                          );
                        },
                        tooltip: AppLocalizations.of(context)!.goToMap,
                      ),
                      order?.status == "out_for_delivery"
                          ? IconButton(
                            icon: Icon(
                              Icons.call,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed:
                                () => _makePhoneCall(
                                  '${order?.shippingPhonecode ?? ''}${order?.shippingPhone ?? ''}',
                                ),
                            tooltip: AppLocalizations.of(context)!.call,
                          )
                          : SizedBox.shrink(),
                    ],
                  ),
                  body: const Center(child: LoadingWidget()),
                );
              }

              return CustomScaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                appBar: CustomAppBarWithoutNavbar(
                  title: AppLocalizations.of(context)!.orderDetails,
                  showRefreshButton: true,
                  showThemeToggle: false,
                  onRefreshPressed: () {
                    // Only refresh if we don't have order data or if it's stale
                    // Don't refresh if we already have the latest state to preserve bloc updates
                    if (_fetchedOrder == null) {
                      _refreshOrderData();
                    } else {
                      // Show a message that data is already up to date
                      ToastManager.show(
                        context: context,
                        message: 'Order data is already up to date',
                        type: ToastType.info,
                      );
                    }
                  },
                  additionalActions: [
                    IconButton(
                      icon: Icon(
                        Icons.map,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () {
                        order.status != "out_for_delivery"
                            ? context.push(
                              AppRoutes.mapDelivery,
                              extra: {'order': order},
                            )
                            : context.push(
                              AppRoutes.pickupRouteMap,
                              extra: {'order': order},
                            );
                      },
                      tooltip: AppLocalizations.of(context)!.goToMap,
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Status Banner
                      new_widgets.OrderStatusBanner(
                        orderStatus: order.status,
                        getStatusColor: _getStatusColor,
                        getDisplayStatus: _getDisplayStatus,
                      ),
                      SizedBox(height: 24.h),
                      Column(
                        children: [
                          StatisticsRow(order: order),
                          SizedBox(height: 12.h),

                          // Payment Method Card
                          new_widgets.PaymentMethodCard(order: order),
                          SizedBox(height: 12.h),

                          // Delivery Time Slot Card
                          if (order.deliveryTimeSlot != null) ...[
                            new_widgets.DeliveryTimeSlotCard(order: order),
                            SizedBox(height: 12.h),
                          ],

                          // Order Note Card
                          if (order.orderNote != null && order.orderNote != "")
                            new_widgets.OrderNoteCard(order: order),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      new_widgets.OrderItemsSection(
                        order: order,
                        isExpanded: _isItemsExpanded,
                        onToggle: () {
                          setState(() {
                            _isItemsExpanded = !_isItemsExpanded;
                          });
                        },
                        itemCards: _buildGroupedItemCards(),
                        onCollectAll:
                            (order.status?.toLowerCase() == 'assigned' &&
                                    !_areAllItemsCollected())
                                ? _collectAllItems
                                : null,
                      ),
                      SizedBox(height: 16.h),
                      // Earnings Details Section
                      new_widgets.EarningsDetailsSection(
                        order: order,
                        isExpanded: _isEarningsExpanded,
                        onToggle: () {
                          setState(() {
                            _isEarningsExpanded = !_isEarningsExpanded;
                          });
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Payment Method Section
                      new_widgets.PaymentInformationSection(
                        order: order,
                        isExpanded: _isPaymentExpanded,
                        onToggle: () {
                          setState(() {
                            _isPaymentExpanded = !_isPaymentExpanded;
                          });
                        },
                      ),
                      SizedBox(height: 16.h),

                      // Pricing Details Section
                      new_widgets.PricingDetailsSection(
                        order: order,
                        isExpanded: _isPricingExpanded,
                        onToggle: () {
                          setState(() {
                            _isPricingExpanded = !_isPricingExpanded;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      new_widgets.StoreDetailsSection(
                        order: order,
                        isExpanded: _isDeliveryExpanded,
                        onToggle: () {
                          setState(() {
                            _isDeliveryExpanded = !_isDeliveryExpanded;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Shipping Details Section
                      new_widgets.ShippingDetailsSection(
                        order: order,
                        isExpanded: _isStoreDetailsExpanded,
                        onToggle: () {
                          setState(() {
                            _isStoreDetailsExpanded = !_isStoreDetailsExpanded;
                          });
                        },
                      ),

                      SizedBox(
                        height: 100.h,
                      ), // Bottom padding for swipe button
                    ],
                  ),
                ),
                bottomSheet: _buildBottomSheet(),
                // Add confetti widget for celebration
                floatingActionButton: Stack(
                  children: [
                    // Confetti widget positioned to cover the entire screen
                    Positioned.fill(
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality:
                            BlastDirectionality
                                .explosive, // Explode from center
                        emissionFrequency: 0.05,
                        numberOfParticles: 20,
                        maxBlastForce: 5,
                        minBlastForce: 2,
                        gravity: 0.1,
                        colors: [
                          Colors.green,
                          Colors.blue,
                          Colors.purple,
                          Colors.orange,
                          Colors.red,
                          Colors.yellow,
                          Colors.pink,
                          Colors.teal,
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to build the bottom sheet using the reusable widget
  Widget? _buildBottomSheet() {
    if (_fetchedOrder?.items == null) {
      return null;
    }

    // Check if order status is delivered first - this should take priority
    if (_fetchedOrder?.status?.toLowerCase() == 'delivered') {
      return ActionBottomSheet(
        buttonText: AppLocalizations.of(context)!.allDone,
        onPressed: () => _showEarningsPopup(),
        buttonColor: AppColors.primaryColor,
        textColor: Colors.white,
      );
    }

    // Simplified and stricter logic for flow control
    bool allItemsCollected = _fetchedOrder!.items!.every((item) {
      return item.status?.toLowerCase() == 'collected' ||
          item.status?.toLowerCase() == 'delivered';
    });

    bool allItemsDelivered = _fetchedOrder!.items!.every((item) {
      return item.status?.toLowerCase() == 'delivered';
    });

    // Check if any items have reached destination according to verified state
    bool anyItemsReachedDestination = _fetchedOrder!.items!.any(
      (item) =>
          item.reachedDestination == true ||
          item.status?.toLowerCase() == 'delivered',
    );

    // Case 1: All items collected but not yet reached destination -> View Pickup Route
    // This only appears after ALL items are definitively collected from the server
    if (allItemsCollected &&
        !anyItemsReachedDestination &&
        !allItemsDelivered) {
      return ActionBottomSheet(
        buttonText: AppLocalizations.of(context)!.viewPickupRoute,
        onPressed: () {
          context.push(
            AppRoutes.pickupRouteMap,
            extra: {
              'order': _fetchedOrder!,
              'bloc': context.read<OrderDetailsBloc>(),
            },
          );
        },
        buttonColor: AppColors.primaryColor,
        textColor: Colors.white,
      );
    }

    // Case 2: All items delivered -> All Done
    if (allItemsDelivered) {
      return ActionBottomSheet(
        buttonText: AppLocalizations.of(context)!.allDone,
        onPressed: _showEarningsPopup,
        buttonColor: AppColors.primaryColor,
        textColor: Colors.white,
      );
    }

    return null;
  }

  bool _areAllItemsCollected() {
    return OrderService.areAllItemsCollected(_fetchedOrder);
  }

  int _getTotalItems() {
    return OrderService.getTotalItems(_fetchedOrder);
  }

  bool _hasItemsRequiringOtp() {
    return OrderService.hasItemsRequiringOtp(_fetchedOrder);
  }

  bool _areAllOtpItemsVerified() {
    return OrderService.areAllOtpItemsVerified(_fetchedOrder);
  }

  bool _hasCodItems() {
    return OrderService.hasCodItems(_fetchedOrder);
  }

  void _showCodPopup() {
    DialogService.showCodPopup(context, _fetchedOrder);
    setState(() {
      _codPopupShown = true;
    });
  }

  void _showCongratulationsGif() {
    // Use the same earnings popup logic since it's similar
    _showEarningsPopup();
  }

  void _collectItem(Items item) {
    // Collect the item directly (no OTP required)
    if (item.id != null) {
      setState(() {
        _processingItemIds.add(item.id.toString());
      });

      // Dispatch the API call - UI updates will be handled in BlocConsumer
      context.read<ItemsCollectedBloc>().add(
        ItemsCollected(item.id.toString()),
      );
    }
  }

  void _deliverItemWithoutOtp(Items item, int? quantity, String? reason) async {
    if (item.id != null) {
      setState(() {
        _processingItemIds.add(item.id.toString());
      });

      // Dispatch the API call to mark item as delivered
      context.read<ItemsCollectedBloc>().add(
        ItemsDelivered(
          orderItemId: item.id.toString(),
          quantity: quantity,
          reason: reason,
        ),
      );
    }
  }

  void _deliverItem(Items item) async {
    if (item.id != null) {
      // Show OTP dialog for delivery
      final String? otp = await _showDeliveryOtpDialog();

      if (otp != null && otp.isNotEmpty) {
        setState(() {
          _processingItemIds.add(item.id.toString());
        });

        // Dispatch the API call - UI updates will be handled in BlocConsumer
        context.read<ItemsCollectedBloc>().add(
          ItemsCollectedWithOtp(orderItemId: item.id.toString(), otp: otp),
        );
      }
    }
  }

  Future<String?> _showDeliveryOtpDialog() async {
    return await DialogService.showDeliveryOtpDialog(context);
  }

  void _showCustomerOtpDialog() async {
    await DialogService.showCustomerOtpDialog(context, _fetchedOrder);
  }

  Widget _buildItemCard(Items item) {
    return ItemCardService.buildItemCard(
      context: context,
      item: item,
      from: widget.from,
      processingItemIds: _processingItemIds,
      isCollectingAll: _isCollectingAll,
      fetchedOrder: _fetchedOrder,
      onCollect: () => _collectItem(item),
      onDelivered: (quantity, reason) => _deliverItemWithoutOtp(item, quantity, reason),
      onReachedDestination: () => _markItemReachedDestination(item),
      onItemOtpTap: (item, quantity, reason) => _showItemOtpDialog(item, quantity, reason),
    );
  }

  void _showItemOtpDialog(Items item, int? quantity, String? reason) async {
    bool requiresOtp = item.product?.requiresOtp == 1;

    if (!requiresOtp) {
      _deliverItemWithoutOtp(item, quantity, reason);
      return;
    }

    // Show simplified OTP dialog
    final String? otp = await DialogService.showDeliveryOtpDialog(context);

    if (otp != null && otp.isNotEmpty) {
      setState(() {
        _processingItemIds.add(item.id.toString());
      });

      // Show COD popup if payment method is COD and popup hasn't been shown yet
      if (widget.from && _hasCodItems() && !_codPopupShown) {
        _showCodPopup();
      }

      context.read<ItemsCollectedBloc>().add(
        ItemsCollectedWithOtp(
          orderItemId: item.id.toString(),
          otp: otp,
          quantity: quantity,
          reason: reason,
        ),
      );
    }
  }

  void _collectAllItems() async {
    final uncollectedItems =
        _fetchedOrder?.items?.where((item) {
          return item.status?.toLowerCase() != 'collected' &&
              item.status?.toLowerCase() != 'delivered';
        }).toList();

    if (uncollectedItems == null || uncollectedItems.isEmpty) return;

    setState(() {
      _isCollectingAll = true;
      _bulkSuccessCount = 0;
      _bulkTotalCount = uncollectedItems.length;
    });

    for (var item in uncollectedItems) {
      if (item.id != null) {
        context.read<ItemsCollectedBloc>().add(
          ItemsCollected(item.id.toString()),
        );
      }
    }
  }

  void _showEarningsPopup() {
    // Show confetti only if it hasn't been shown for this order yet
    if (!_hasShownConfetti) {
      _hasShownConfetti = true;
      _confettiController.play();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64.sp),
              SizedBox(height: 16.h),
              CustomText(
                text: AppLocalizations.of(context)!.orderCompleted,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text:
                    AppLocalizations.of(context)!.allItemsDeliveredSuccessfully,
                textAlign: TextAlign.center,
                fontSize: 16,
                color: Colors.grey,
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    CustomText(
                      text: AppLocalizations.of(context)!.yourEarningsBreakdown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 12.h),
                    // Breakdown details
                    if (_fetchedOrder?.earnings?.breakdown != null) ...[
                      _buildBreakdownRow(
                        AppLocalizations.of(context)!.baseFee,
                        _fetchedOrder?.earnings?.breakdown?.baseFee,
                      ),
                      _buildBreakdownRow(
                        AppLocalizations.of(context)!.storePickupFee,
                        _fetchedOrder?.earnings?.breakdown?.perStorePickupFee,
                      ),
                      _buildBreakdownRow(
                        AppLocalizations.of(context)!.distanceFee,
                        _fetchedOrder?.earnings?.breakdown?.distanceBasedFee,
                      ),
                      _buildBreakdownRow(
                        AppLocalizations.of(context)!.orderIncentive,
                        _fetchedOrder?.earnings?.breakdown?.perOrderIncentive,
                      ),
                      const Divider(height: 16, thickness: 1),
                    ],
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: AppLocalizations.of(context)!.totalEarnings,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        CustomText(
                          text: CurrencyFormatter.formatAmount(
                            context,
                            _fetchedOrder?.earnings?.total ?? 0,
                          ),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      textSize: 15.sp,
                      text: AppLocalizations.of(context)!.ok,
                      onPressed: () {
                        context.pop();
                      },
                      backgroundColor: AppColors.primaryColor,
                      textColor: Colors.white,
                      borderRadius: 8.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      textSize: 15.sp,
                      text: AppLocalizations.of(context)!.goToHome,
                      onPressed: () async {
                        // Close the dialog first
                        context.pop();

                        // Determine the correct tab based on where user came from
                        int targetTab = _getTargetTabForNavigation();

                        // Refresh the appropriate list based on target tab
                        if (targetTab == 0) {
                          // Available Orders tab - refresh available orders list
                          context.read<AvailableOrdersBloc>().add(
                            AllAvailableOrdersList(forceRefresh: true),
                          );
                        } else if (targetTab == 1) {
                          // My Orders tab - refresh my orders list
                          context.read<MyOrdersBloc>().add(
                            AllMyOrdersList(forceRefresh: true),
                          );
                        }

                        // Navigate to feed with the appropriate tab
                        context.go('${AppRoutes.feed}?tab=$targetTab');
                      },
                      textColor: Colors.black87,
                      borderRadius: 8.r,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(String label, double? amount) {
    return UIHelperService.buildBreakdownRow(context, label, amount);
  }

  String _getStatusText() {
    return OrderService.getStatusText(context, _fetchedOrder, widget.from);
  }

  Widget _buildGroupHeader(int orderId) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 12.h, left: 4.w),
      child: Row(
        children: [
          Icon(Icons.receipt_long, size: 18.sp, color: AppColors.primaryColor),
          SizedBox(width: 8.w),
          CustomText(
            text: 'Order #$orderId',
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedItemCards() {
    if (widget.groupOrders == null || widget.groupOrders!.length <= 1) {
      return _fetchedOrder?.items?.map((item) => _buildItemCard(item)).toList() ?? [];
    }

    List<Widget> cards = [];
    for (var gOrder in widget.groupOrders!) {
      int orderId = gOrder is Orders ? gOrder.id ?? 0 : gOrder['id'] ?? 0;
      
      cards.add(_buildGroupHeader(orderId));

      List<Items> orderItems = [];
      
      // ALWAYS use the live _fetchedOrder state as the source of truth if available
      if (_fetchedOrder?.items != null && _fetchedOrder!.items!.isNotEmpty) {
        orderItems = _fetchedOrder!.items!.where((item) => item.orderId == orderId).toList();
      }
      
      // Fallback to widget properties if live data isn't available yet
      if (orderItems.isEmpty) {
        if (gOrder is Orders && gOrder.items != null && gOrder.items!.isNotEmpty) {
          orderItems = gOrder.items!;
        } else if (gOrder is Map && gOrder['items'] != null) {
          try {
            orderItems = (gOrder['items'] as List).map((e) => Items.fromJson(e)).toList();
          } catch (_) {}
        }
      }

      if (orderItems.isNotEmpty) {
        cards.addAll(orderItems.map((item) => _buildItemCard(item)));
      } else {
        cards.add(
          Padding(
            padding: EdgeInsets.only(bottom: 16.h, left: 24.w),
            child: CustomText(
              text: 'Loading items...',
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          )
        );
      }
    }
    return cards;
  }

  int _getCollectedItemsCount() {
    return OrderService.getCollectedItemsCount(_fetchedOrder);
  }

  void _handleButtonPress() {
    OrderService.handleButtonPress(
      context: context,
      order: _fetchedOrder,
      from: widget.from,
      onCollectAllItems: _collectAllItems,
      onShowEarningsPopup: _showEarningsPopup,
      onNavigateToPickupRoute: () {
        context.push(
          AppRoutes.pickupRouteMap,
          extra: {
            'order': _fetchedOrder!,
            'bloc': context.read<OrderDetailsBloc>(),
          },
        );
      },
      onNavigateToMap: () {},
    );
  }

  void _markItemReachedDestination(Items item) {
    if (item.id != null) {
      OrderService.markItemReachedDestination(
        orderId: widget.orderId,
        itemId: item.id!,
        onMarkItemReachedDestination: (orderId, itemId) {
          context.read<OrderDetailsBloc>().add(
            MarkItemReachedDestination(orderId, itemId),
          );
        },
      );
    }
  }

  int _getTargetTabForNavigation() {
    return OrderService.getTargetTabForNavigation(
      widget.sourceTab,
      widget.from,
    );
  }
}

Future<void> _makePhoneCall(String phoneNumber) async {
  await PhoneService.makePhoneCall(phoneNumber);
}
