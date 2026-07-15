// home_tab_bar_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/colors.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class HomeTabBarSection extends StatelessWidget {
  final TabController tabController;

  const HomeTabBarSection({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      isScrollable: true,
      physics: const BouncingScrollPhysics(),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 3.0.w, color: AppColors.primaryColor),
        insets: EdgeInsets.symmetric(
          horizontal: 20.w,
        ), // Makes indicator shorter than tab
      ),
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: Colors.grey.shade600,
      labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
      ), // Space between tabs
      dividerColor: Colors.transparent,
      tabs: [
        Tab(text: AppLocalizations.of(context)?.availableOrders ?? "Available"),
        Tab(text: AppLocalizations.of(context)?.myOrders ?? "My Orders"),
        Tab(
          text:
              AppLocalizations.of(context)?.availPickupOrders ??
              "Return Orders",
        ),
        Tab(
          text: AppLocalizations.of(context)?.pickupOrders ?? "Pickup Orders",
        ),
      ],
    );
  }
}
