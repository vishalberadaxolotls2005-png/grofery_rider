import 'package:flutter/material.dart';
import 'package:grofery_rider/screens/feed_page/widgets/my_pickups/my_pickups_section.dart';
import 'package:grofery_rider/screens/feed_page/widgets/return_order/return_order_page.dart';
import '../available_orders/available_orders_section.dart';
import '../my_orders/my_orders_section.dart';

class HomeTabContentSection extends StatelessWidget {
  final TabController tabController;
  final bool isDeliveryBoyActive;
  final bool isDarkTheme;

  const HomeTabContentSection({
    super.key,
    required this.tabController,
    required this.isDeliveryBoyActive,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TabBarView(
          controller: tabController,
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            AvailableOrdersSection(isDeliveryBoyActive: isDeliveryBoyActive),
            MyOrdersSection(
              isDarkTheme: isDarkTheme,
              isDeliveryBoyActive: isDeliveryBoyActive,
            ),
            ReturnOrdersSection(isDeliveryBoyActive: isDeliveryBoyActive),
            MyPickupsSection(
              isDeliveryBoyActive: isDeliveryBoyActive,
            ), // ← 4th Tab
          ],
        ),
      ),
    );
  }
}
