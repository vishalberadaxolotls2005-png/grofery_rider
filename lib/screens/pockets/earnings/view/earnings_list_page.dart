import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/colors.dart';
import '../../../../utils/widgets/custom_appbar_without_navbar.dart';
import '../../../../utils/widgets/custom_card.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../../../utils/widgets/inactive_account_widget.dart';
import '../../../../utils/currency_formatter.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import '../model/earnings_model.dart';
import '../repo/earnings_repo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/widgets/toast_message.dart';

class EarningsListPage extends StatefulWidget {
  const EarningsListPage({super.key});

  @override
  State<EarningsListPage> createState() => _EarningsListPageState();
}

class EarningsListPageWithBloc extends StatelessWidget {
  const EarningsListPageWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EarningsBloc(EarningsRepo(), context: context),
      child: const EarningsListPage(),
    );
  }
}

class _EarningsListPageState extends State<EarningsListPage> {
  String _selectedDateRange = 'last_1_day'; // Default to Day view

  @override
  void initState() {
    super.initState();

    // Fetch day earnings by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsBloc>().add(FetchEarnings(dateRange: 'last_1_day'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.myEarnings;

    return Scaffold(
      appBar: CustomAppBarWithoutNavbar(
        title: title,
        additionalActions: [
          Container(
            margin: EdgeInsets.only(right: 8.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TextButton(
              onPressed: () {
                // Navigate to all earnings page
                context.push('/all-earnings');
              },
              child: CustomText(
                text: AppLocalizations.of(context)!.all,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<EarningsBloc, EarningsState>(
        listener: (context, state) {
          if (state is EarningsLoaded) {
            setState(() {});
          } else if (state is EarningsError) {
            ToastManager.show(
              context: context,
              message: state.message,
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is EarningsLoading) {
            return const Center(child: LoadingWidget());
          } else if (state is EarningsLoaded) {
            return _buildEarningsList(state.response);
          } else if (state is EarningsInactive) {
            return InactiveAccountWidget(
              message: state.message,
              onRetry: () {
                context.read<EarningsBloc>().add(
                  FetchEarnings(dateRange: _selectedDateRange),
                );
              },
            );
          } else if (state is EarningsError) {
            return _buildErrorState(state.message);
          }

          // Show loading for initial state
          return const Center(child: LoadingWidget());
        },
      ),
    );
  }

  // Replace the following methods in your earnings_list_page.dart

  Widget _buildEarningsList(EarningsResponse response) {
    if (response.data == null) {
      return _buildEmptyState();
    }

    // Get current state to check pagination status
    final state = context.watch<EarningsBloc>().state;
    final bool isFetchingMore =
        state is EarningsLoaded ? state.isFetchingMore : false;
    final bool hasReachedMax =
        state is EarningsLoaded ? state.hasReachedMax : true;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !isFetchingMore &&
            !hasReachedMax) {
          context.read<EarningsBloc>().add(
            LoadMoreEarnings(dateRange: _selectedDateRange),
          );
        }
        return true;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Date Range Filter Tabs
            _buildDateRangeTabs(),

            // Main Earnings Summary Card
            _buildSummaryCard(response),

            // Main Earnings Card
            _buildMainEarningsCard(response),

            // Earnings Statistics Card (only show for Week and Month views)
            if (_selectedDateRange != 'last_1_day') ...[
              _buildEarningsStatisticsCard(response),
            ],

            // Earnings Categories Breakdown
            _buildEarningsCategories(response),

            // Detailed Earnings List (Pagination UI)
            _buildRecentEarningsSection(response, isFetchingMore),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(EarningsResponse response) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.08),
                AppColors.primaryColor.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primaryColor,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: AppLocalizations.of(context)!.totalEarnings,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        SizedBox(height: 2.h),
                        CustomText(
                          text: _getDateRangeDisplayText(_selectedDateRange),
                          fontSize: 11.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(
                            alpha: 0.002,
                          ),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: CustomText(
                      text: '${response.data?.total ?? 0}',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black,
        //     blurRadius: 4.r,
        //     offset: Offset(0, 2.h),
        //   ),
        // ],
      ),
      padding: EdgeInsets.all(6.w),
      child: Row(
        children: [
          Expanded(
            child: _buildDateRangeTab(
              AppLocalizations.of(context)!.day,
              _selectedDateRange == 'last_1_day',
              () {
                setState(() {
                  _selectedDateRange = 'last_1_day';
                });
                context.read<EarningsBloc>().add(
                  FetchEarnings(dateRange: 'last_1_day'),
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _buildDateRangeTab(
              AppLocalizations.of(context)!.week,
              _selectedDateRange == 'last_7_days',
              () {
                setState(() {
                  _selectedDateRange = 'last_7_days';
                });
                context.read<EarningsBloc>().add(FetchWeeklyEarnings());
              },
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _buildDateRangeTab(
              AppLocalizations.of(context)!.month,
              _selectedDateRange == 'last_30_days',
              () {
                setState(() {
                  _selectedDateRange = 'last_30_days';
                });
                context.read<EarningsBloc>().add(FetchMonthlyEarnings());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.85),
                    ],
                  )
                  : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.h),
                    ),
                  ]
                  : [],
        ),
        child: Center(
          child: CustomText(
            text: title,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color:
                isSelected
                    ? Colors.white
                    : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildMainEarningsCard(EarningsResponse response) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: CustomCard(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            // Icon with animated background
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.15),
                    AppColors.primaryColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primaryColor,
                size: 28.sp,
              ),
            ),

            SizedBox(height: 16.h),

            CustomText(
              text: _getDateRangeDisplayText(_selectedDateRange),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),

            SizedBox(height: 8.h),

            // Subtle divider
            Container(
              width: 40.w,
              height: 2.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.3),
                    AppColors.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),

            SizedBox(height: 12.h),

            CustomText(
              text: AppLocalizations.of(context)!.periodEarnings,
              fontSize: 12.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),

            SizedBox(height: 8.h),

            // Main Earnings Amount
            CustomText(
              text: CurrencyFormatter.formatAmount(
                context,
                _getTotalEarnings(response),
              ),
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCategories(EarningsResponse response) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                CustomText(
                  text: AppLocalizations.of(context)!.earningsBreakdown,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),

          _buildEarningsCategoryCard(
            AppLocalizations.of(context)!.orderEarnings,
            _getOrderEarnings(response),
            Icons.shopping_cart_rounded,
            AppColors.primaryColor,
            AppLocalizations.of(context)!.baseAndDistanceFees,
          ),
          SizedBox(height: 10.h),

          _buildEarningsCategoryCard(
            AppLocalizations.of(context)!.storePickupFee,
            _getOtherEarnings(response),
            Icons.storefront_rounded,
            Colors.orange,
            AppLocalizations.of(context)!.perStoreCharges,
          ),
          SizedBox(height: 10.h),

          _buildEarningsCategoryCard(
            AppLocalizations.of(context)!.incentives,
            _getIncentiveEarnings(response),
            Icons.stars_rounded,
            Colors.green,
            AppLocalizations.of(context)!.bonusAndRewards,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCategoryCard(
    String title,
    String amount,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final earnings = double.tryParse(amount) ?? 0;
    final hasEarnings = earnings > 0;

    return CustomCard(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Icon container with gradient
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
              boxShadow:
                  hasEarnings
                      ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.15),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ]
                      : [],
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),

          SizedBox(width: 14.w),

          // Title and amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 3.h),
                CustomText(
                  text: subtitle,
                  fontSize: 11.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Amount with background
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color:
                  hasEarnings
                      ? color.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color:
                    hasEarnings
                        ? color.withValues(alpha: 0.2)
                        : Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: CustomText(
              text: CurrencyFormatter.formatAmount(context, amount),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color:
                  hasEarnings
                      ? color
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsStatisticsCard(EarningsResponse response) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: CustomCard(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: AppLocalizations.of(context)!.dailyBreakdown,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 2.h),
                      CustomText(
                        text: _getDateRangeDisplayText(_selectedDateRange),
                        fontSize: 12.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Daily/Weekly breakdown with improved visualization
            _buildDailyBreakdownGrid(response),

            SizedBox(height: 16.h),

            // Summary stats row
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: _buildQuickStat(
                  AppLocalizations.of(context)!.daysActive,
                  _getActiveDaysCount(response),
                  Icons.calendar_today_rounded,
                  isCount: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBreakdownGrid(EarningsResponse response) {
    final days = _getDaysForRange(_selectedDateRange);

    if (_selectedDateRange == 'last_7_days') {
      // Week view - show 7 days in a scrollable row
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              days.asMap().entries.map((entry) {
                final index = entry.key;
                final day = entry.value;
                final amount = _getEarningsForDay(response, day);
                final isToday = _isToday(day);

                return Container(
                  margin: EdgeInsets.only(
                    right: index < days.length - 1 ? 12.w : 0,
                  ),
                  child: _buildDayCard(day, amount, isToday),
                );
              }).toList(),
        ),
      );
    } else if (_selectedDateRange == 'last_30_days') {
      // Month view - show weeks in a grid
      return Column(
        children:
            days.asMap().entries.map((entry) {
              final index = entry.key;
              final weekRange = entry.value;
              final amount = _getEarningsForDay(response, weekRange);

              return Container(
                margin: EdgeInsets.only(
                  bottom: index < days.length - 1 ? 8.h : 0,
                ),
                child: _buildWeekCard(response, weekRange, amount, index + 1),
              );
            }).toList(),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildDayCard(String day, String amount, bool isToday) {
    final dayNumber = int.tryParse(day) ?? 0;
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month, dayNumber);
    final dayName = _getDayName(targetDate.weekday);
    final earnings = double.tryParse(amount) ?? 0;
    final hasEarnings = earnings > 0;

    return IntrinsicWidth(
      child: Container(
        constraints: BoxConstraints(
          minWidth: 85.w,
          maxWidth: 140.w, // cap it so huge values don’t explode the UI
        ),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color:
              isToday
                  ? AppColors.primaryColor.withValues(alpha: 0.1)
                  : Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isToday
                    ? AppColors.primaryColor.withValues(alpha: 0.3)
                    : Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Day name
            CustomText(
              text: dayName,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color:
                  isToday
                      ? AppColors.primaryColor
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            SizedBox(height: 4.h),

            // Day number
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color:
                    hasEarnings
                        ? AppColors.primaryColor.withValues(alpha: 0.15)
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      hasEarnings
                          ? AppColors.primaryColor.withValues(alpha: 0.3)
                          : Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomText(
                  text: day,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      hasEarnings
                          ? AppColors.primaryColor
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),

            SizedBox(height: 8.h),

            // Earnings amount
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              decoration: BoxDecoration(
                color:
                    hasEarnings
                        ? AppColors.primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: CustomText(
                text: CurrencyFormatter.formatAmount(context, amount),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color:
                    hasEarnings
                        ? AppColors.primaryColor
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekCard(
    EarningsResponse response,
    String weekRange,
    String amount,
    int weekNumber,
  ) {
    final earnings = double.tryParse(amount) ?? 0;
    final hasEarnings = earnings > 0;
    final maxEarnings = _getMaxWeeklyEarnings(response);
    final percentage = maxEarnings > 0 ? (earnings / maxEarnings) : 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Week indicator
          SizedBox(
            width: 50.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: '${AppLocalizations.of(context)!.week} $weekNumber',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: weekRange.replaceAll('-', ' - '),
                  fontSize: 10.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: CurrencyFormatter.formatAmount(context, amount),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          hasEarnings
                              ? AppColors.primaryColor
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    if (hasEarnings)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: CustomText(
                          text: '${(percentage * 100).toInt()}%',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: percentage.toDouble(),
                    minHeight: 6.h,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon, {
    bool isCount = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: AppColors.primaryColor.withValues(alpha: 0.7),
        ),
        SizedBox(height: 6.h),
        CustomText(
          text:
              isCount ? value : CurrencyFormatter.formatAmount(context, value),
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        SizedBox(height: 2.h),
        CustomText(
          text: label,
          fontSize: 10.sp,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper methods
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  bool _isToday(String day) {
    final dayNumber = int.tryParse(day);
    if (dayNumber == null) return false;
    return dayNumber == DateTime.now().day;
  }



  String _getActiveDaysCount(EarningsResponse response) {
    if (response.data?.earnings == null || response.data!.earnings!.isEmpty) {
      return '0';
    }
    final days = _getDaysForRange(_selectedDateRange);
    int activeDays = 0;

    for (final day in days) {
      final earnings = double.tryParse(_getEarningsForDay(response, day)) ?? 0;
      if (earnings > 0) {
        activeDays++;
      }
    }

    return activeDays.toString();
  }

  double _getMaxWeeklyEarnings(EarningsResponse response) {
    if (response.data?.earnings == null) return 0;

    final days = _getDaysForRange(_selectedDateRange);
    double maxEarnings = 0;

    for (final day in days) {
      final earnings = double.tryParse(_getEarningsForDay(response, day)) ?? 0;
      if (earnings > maxEarnings) {
        maxEarnings = earnings;
      }
    }

    return maxEarnings;
  }

  String _getDateRangeDisplayText(String dateRange) {
    switch (dateRange) {
      case 'last_1_day':
        return '${AppLocalizations.of(context)!.today} ${_getCurrentDate()}';
      case 'last_7_days':
        return _getDateRangeText(7);
      case 'last_30_days':
        return _getCurrentMonthText();
      case 'last_365_days':
        return 'All Time';
      default:
        return 'Today: ${_getCurrentDate()}';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day} ${_getMonthName(now.month)}';
  }

  String _getCurrentMonthText() {
    final now = DateTime.now();
    return '${_getMonthName(now.month)} ${now.year}';
  }

  String _getDateRangeText(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    final endDate = now;

    final startDay = startDate.day;
    final endDay = endDate.day;
    final startMonth = _getMonthName(startDate.month);
    final endMonth = _getMonthName(endDate.month);

    // If start and end are in different months, show both months
    if (startDate.month != endDate.month) {
      return '$startDay $startMonth - $endDay $endMonth';
    } else {
      return '$startDay $startMonth - $endDay $startMonth';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    // Ensure month is within valid range (1-12)
    if (month < 1 || month > 12) {
      return 'Unknown';
    }

    return months[month - 1];
  }

  String _getEarningsForDay(EarningsResponse response, String day) {
    if (response.data?.earnings == null) return '0';

    // Check if this is a week range (e.g., "13-19")
    if (day.contains('-')) {
      final parts = day.split('-');
      if (parts.length == 2) {
        final startDay = int.tryParse(parts[0]);
        final endDay = int.tryParse(parts[1]);
        if (startDay != null && endDay != null) {
          return _getEarningsForWeekRange(response, startDay, endDay);
        }
      }
      return '0';
    }

    // Parse the day to get the date
    final dayNumber = int.tryParse(day);
    if (dayNumber == null) return '0';

    // Get the current date and calculate the target date
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month, dayNumber);

    double total = 0;
    for (var earning in response.data!.earnings!) {
      if (earning.createdAt != null) {
        try {
          final orderDate = DateTime.parse(earning.createdAt!);
          // Check if the order date matches the target date
          if (orderDate.year == targetDate.year &&
              orderDate.month == targetDate.month &&
              orderDate.day == targetDate.day) {
            if (earning.earnings?.total != null) {
              total += double.tryParse(earning.earnings!.total!) ?? 0;
            }
          }
        } catch (e) {
          // ignore parsing errors
        }
      }
    }
    return total.toString();
  }

  String _getEarningsForWeekRange(
    EarningsResponse response,
    int startDay,
    int endDay,
  ) {
    if (response.data?.earnings == null) return '0';

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, startDay);
    final endDate = DateTime(now.year, now.month, endDay);

    double total = 0;
    for (var earning in response.data!.earnings!) {
      if (earning.createdAt != null) {
        try {
          final orderDate = DateTime.parse(earning.createdAt!);
          // Check if the order date falls within the week range
          if (orderDate.year == startDate.year &&
              orderDate.month == startDate.month &&
              orderDate.day >= startDate.day &&
              orderDate.day <= endDate.day) {
            if (earning.earnings?.total != null) {
              total += double.tryParse(earning.earnings!.total!) ?? 0;
            }
          }
        } catch (e) {
          // ignore parsing errors
        }
      }
    }
    return total.toString();
  }

  Widget _buildRecentEarningsSection(
    EarningsResponse response,
    bool isFetchingMore,
  ) {
    final earnings = response.data?.earnings ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 8.w),
              CustomText(
                text: 'Recent Earnings',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
              const Spacer(),
              CustomText(
                text:
                    '${earnings.length} ${AppLocalizations.of(context)!.orders.toLowerCase()}',
                fontSize: 12.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: earnings.length + (isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < earnings.length) {
              return _buildEarningCard(earnings[index]);
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(child: LoadingWidget()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildEarningCard(EarningsModel earning) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: CustomCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: AppLocalizations.of(
                        context,
                      )!.orderNumber(earning.orderId.toString()),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 2.h),
                    CustomText(
                      text: earning.createdAt ?? earning.orderDate ?? '',
                      fontSize: 11.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      earning.paymentStatus,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: _getStatusColor(
                        earning.paymentStatus,
                      ).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: CustomText(
                    text:
                        earning.paymentStatus?.toLowerCase() == 'paid'
                            ? AppLocalizations.of(context)!.paid
                            : AppLocalizations.of(context)!.pending,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(earning.paymentStatus),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                height: 1,
              ),
            ),

            if (earning.earnings != null) ...[
              _buildEarningsBreakdownEntry(earning.earnings!),
              SizedBox(height: 12.h),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.total,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: CurrencyFormatter.formatAmount(
                    context,
                    earning.earnings?.total ?? '0',
                  ),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdownEntry(EarningsDetailModel earnings) {
    return Column(
      children: [
        _buildBreakdownRowEntry(
          AppLocalizations.of(context)!.baseFee,
          earnings.baseFee ?? '0',
        ),
        _buildBreakdownRowEntry(
          AppLocalizations.of(context)!.storePickupFee,
          earnings.perStorePickupFee ?? '0',
        ),
        _buildBreakdownRowEntry(
          AppLocalizations.of(context)!.distanceFee,
          earnings.distanceBasedFee ?? '0',
        ),
        _buildBreakdownRowEntry(
          AppLocalizations.of(context)!.incentives,
          earnings.perOrderIncentive ?? '0',
        ),
      ],
    );
  }

  Widget _buildBreakdownRowEntry(String label, String amount) {
    final double val = double.tryParse(amount) ?? 0;
    if (val == 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: 12.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          CustomText(
            text: CurrencyFormatter.formatAmount(context, amount),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTotalEarnings(EarningsResponse response) {
    if (response.data?.earnings == null || response.data!.earnings!.isEmpty) {
      return '0';
    }

    double total = 0;
    for (var earning in response.data!.earnings!) {
      if (earning.earnings?.total != null) {
        total += double.tryParse(earning.earnings!.total!) ?? 0;
      }
    }

    return total.toString();
  }

  String _getOrderEarnings(EarningsResponse response) {
    if (response.data?.earnings == null || response.data!.earnings!.isEmpty) {
      return '0';
    }

    double total = 0;
    for (var earning in response.data!.earnings!) {
      if (earning.earnings?.baseFee != null) {
        total += double.tryParse(earning.earnings!.baseFee!) ?? 0;
      }
      if (earning.earnings?.distanceBasedFee != null) {
        total += double.tryParse(earning.earnings!.distanceBasedFee!) ?? 0;
      }
    }

    return total.toString();
  }

  String _getIncentiveEarnings(EarningsResponse response) {
    if (response.data?.earnings == null || response.data!.earnings!.isEmpty) {
      return '0';
    }

    double total = 0;
    for (var earning in response.data!.earnings!) {
      if (earning.earnings?.perOrderIncentive != null) {
        total += double.tryParse(earning.earnings!.perOrderIncentive!) ?? 0;
      }
    }

    return total.toString();
  }

  String _getOtherEarnings(EarningsResponse response) {
    if (response.data?.earnings == null || response.data!.earnings!.isEmpty) {
      return '0';
    }

    double total = 0;
    for (var earning in response.data!.earnings!) {
      if (earning.earnings?.perStorePickupFee != null) {
        total += double.tryParse(earning.earnings!.perStorePickupFee!) ?? 0;
      }
    }

    return total.toString();
  }

  List<String> _getDaysForRange(String dateRange) {
    switch (dateRange) {
      case 'last_1_day':
        return ['${DateTime.now().day}'];
      case 'last_7_days':
        final now = DateTime.now();
        return List.generate(7, (index) {
          final date = now.subtract(Duration(days: 6 - index));
          return '${date.day}';
        });
      case 'last_30_days':
        // For month view, show current month starting from day 1
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(
          now.year,
          now.month + 1,
          0,
        ); // Last day of current month

        List<String> weeks = [];
        for (int i = 0; i < 5; i++) {
          final weekStart = monthStart.add(Duration(days: i * 7));
          final weekEnd = weekStart.add(Duration(days: 6));

          // Ensure we don't go beyond the month end
          if (weekStart.month != now.month) break;
          if (weekEnd.day > monthEnd.day) {
            weeks.add('${weekStart.day}-${monthEnd.day}');
          } else {
            weeks.add('${weekStart.day}-${weekEnd.day}');
          }
        }
        return weeks;
      case 'last_365_days':
        // For All/Year view, show months
        final now = DateTime.now();
        return List.generate(12, (index) {
          // Calculate month ensuring it's always between 1 and 12
          int monthNumber = ((now.month - 1 - index + 12) % 12);
          if (monthNumber == 0) monthNumber = 12;
          final month = _getMonthName(monthNumber);
          return month;
        });
      default:
        return ['${DateTime.now().day}'];
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 48.sp,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 20.h),
          CustomText(
            text: AppLocalizations.of(context)!.noEarningsYet,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: AppLocalizations.of(context)!.completeDeliveriesMessage,
            fontSize: 14.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 20.h),
          CustomText(
            text: AppLocalizations.of(context)!.errorLoadingEarnings,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomText(
              text: message,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.error,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<EarningsBloc>().add(FetchEarnings());
            },
            icon: Icon(Icons.refresh_rounded, size: 18.sp),
            label: CustomText(
              text: AppLocalizations.of(context)!.retry,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
