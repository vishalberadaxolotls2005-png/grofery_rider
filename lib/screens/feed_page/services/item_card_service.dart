import 'package:flutter/material.dart';
import '../model/available_orders.dart';
import '../widgets/orderdetails_widgets/item_card.dart';

class ItemCardService {
  static Widget buildItemCard({
    required BuildContext context,
    required Items item,
    required bool from,
    required Set<String> processingItemIds,
    required bool isCollectingAll,
    required Orders? fetchedOrder,
    required VoidCallback onCollect,
    required Function(int?, String?) onDelivered,
    required VoidCallback onReachedDestination,
    required Function(Items, int?, String?) onItemOtpTap,
  }) {
    // Check if item is collected/delivered based strictly on API status
    final bool isCollected = item.status?.toLowerCase() == 'collected' ||
                            item.status?.toLowerCase() == 'delivered';
    final bool isDelivered = item.status?.toLowerCase() == 'delivered';

    final bool requiresOtp = item.product?.requiresOtp == 1;
    final bool isLoading = isCollectingAll || processingItemIds.contains(item.id.toString());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ItemCard(
        item: item,
        from: from,
        isCollected: isCollected,
        isDelivered: isDelivered,
        isLoading: isLoading,
        orderStatus: fetchedOrder?.status,
        isOtpVerified: item.otpVerified == 1,
        onTap: (isCollected && requiresOtp && !isDelivered) ? (quantity, reason) => onItemOtpTap(item, quantity, reason) : null,
        onCollect: onCollect,
        onDelivered: onDelivered,
        onReachedDestination: onReachedDestination,
      ),
    );
  }
}
