import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import 'package:grofery_rider/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import '../../config/colors.dart';
import 'loading_widget.dart';
import 'toast_message.dart';
import '../../screens/settings/bloc/profile_bloc/profile_bloc.dart';
import '../../screens/settings/bloc/profile_bloc/profile_event.dart';
import '../../screens/settings/bloc/profile_bloc/profile_state.dart';
import '../../screens/settings/repo/profile_repo.dart';
import '../currency_formatter.dart';

class InactivePage extends StatelessWidget {
  const InactivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(ProfileRepo())..add(const LoadProfile()),
      child: const InactivePageContent(),
    );
  }
}

class InactivePageContent extends StatefulWidget {
  const InactivePageContent({super.key});

  @override
  State<InactivePageContent> createState() => _InactivePageContentState();
}

class _InactivePageContentState extends State<InactivePageContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: CustomText(
          text: AppLocalizations.of(context)!.offlineMode,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ToastManager.show(
              context: context,
              message: state.message,
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: LoadingWidget());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),

                // Offline Icon
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.offline_bolt,
                    size: 50.sp,
                    color: Colors.red,
                  ),
                ),

                SizedBox(height: 20.h),

                // Offline Status
                CustomText(
                  text: AppLocalizations.of(context)!.youAreCurrentlyOffline,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8.h),

                CustomText(
                  text:
                      AppLocalizations.of(
                        context,
                      )!.goOnlineToStartReceivingOrders,
                  fontSize: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                // Go Online Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: AppLocalizations.of(context)!.goOnline,
                    onPressed: () {
                      context.read<DeliveryBoyStatusBloc>().add(
                        ToggleStatus(true),
                      );
                      context.pop();
                    },
                    icon: const Icon(Icons.power_settings_new),
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    borderRadius: 12.r,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),

                SizedBox(height: 32.h),

                // Earnings Charts Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: AppColors.primaryColor,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            CustomText(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.earningsAnalytics,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),

                      // Period Selector
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children:
                              ['Week', 'Month', 'Year'].map((period) {
                                final isSelected = _selectedPeriod == period;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPeriod = period;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppColors.primaryColor
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppColors.primaryColor
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .outline
                                                      .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: CustomText(
                                        text: _getPeriodLabel(period),
                                        textAlign: TextAlign.center,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Chart Container
                      Container(
                        height: 300.h,
                        color: Colors.red,
                        padding: EdgeInsets.all(20.w),
                        child: _buildEarningsChart(),
                      ),

                      SizedBox(height: 20.h),

                      // Summary Cards
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title:
                                    AppLocalizations.of(context)!.totalEarnings,
                                value: _getTotalEarnings(),
                                icon: Icons.account_balance_wallet,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildSummaryCard(
                                title: AppLocalizations.of(context)!.average,
                                value: _getAverageEarnings(),
                                icon: Icons.trending_up,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Profile Information (if loaded)
                if (state is ProfileLoaded) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: AppColors.primaryColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              text:
                                  AppLocalizations.of(
                                    context,
                                  )!.profileInformation,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.name,
                          state.profile.deliveryBoy?.fullName ??
                              AppLocalizations.of(context)!.notSet,
                        ),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.address,
                          state.profile.deliveryBoy?.address ??
                              AppLocalizations.of(context)!.notSet,
                        ),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.vehicleType,
                          state.profile.deliveryBoy?.vehicleType ??
                              AppLocalizations.of(context)!.notSet,
                        ),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.licenseNumber,
                          state.profile.deliveryBoy?.driverLicenseNumber ??
                              AppLocalizations.of(context)!.notSet,
                        ),
                        _buildInfoRow(
                          AppLocalizations.of(context)!.status,
                          state.profile.deliveryBoy?.status ??
                              AppLocalizations.of(context)!.notSet,
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEarningsChart() {
    switch (_selectedPeriod) {
      case 'Week':
        return _buildWeeklyChart();
      case 'Month':
        return _buildMonthlyChart();
      case 'Year':
        return _buildYearlyChart();
      default:
        return _buildWeeklyChart();
    }
  }

  Widget _buildWeeklyChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 500,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1.w,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1.w,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                CustomText text;
                switch (value.toInt()) {
                  case 0:
                    text = CustomText(
                      text: AppLocalizations.of(context)!.monday,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                  case 1:
                    text = CustomText(
                      text: AppLocalizations.of(context)!.tuesday,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                  case 2:
                    text = CustomText(
                      text: AppLocalizations.of(context)!.wednesday,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                  case 3:
                    text = CustomText(
                      text: AppLocalizations.of(context)!.thursday,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                  case 4:
                    text = CustomText(
                      text: AppLocalizations.of(context)!.friday,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                  case 5:
                    text = CustomText(
                      text: AppLocalizations.of(context)!.saturday,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                  case 6:
                    text = CustomText(
                      text: AppLocalizations.of(context)!.sunday,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                  default:
                    text = CustomText(
                      text: '',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff68737d),
                    );
                    break;
                }
                return SideTitleWidget(axisSide: meta.axisSide, child: text);
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 500,
              getTitlesWidget: (double value, TitleMeta meta) {
                return CustomText(
                  text: CurrencyFormatter.formatAmount(context, value.toInt()),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff67727d),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d)),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 2000,
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 800),
              const FlSpot(1, 1200),
              const FlSpot(2, 900),
              const FlSpot(3, 1500),
              const FlSpot(4, 1800),
              const FlSpot(5, 1400),
              const FlSpot(6, 1600),
            ],
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.8),
                AppColors.primaryColor.withValues(alpha: 0.3),
              ],
            ),
            barWidth: 3.w,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4.r,
                  color: AppColors.primaryColor,
                  strokeWidth: 2.w,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.3),
                  AppColors.primaryColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5000,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return CustomText(
                  text: 'W${value.toInt() + 1}',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff68737d),
                );
              },
              reservedSize: 38.h,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28.h,
              interval: 1000,
              getTitlesWidget: (double value, TitleMeta meta) {
                return CustomText(
                  text: CurrencyFormatter.formatAmount(context, value.toInt()),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff67727d),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: 3200, color: AppColors.primaryColor),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: 2800, color: AppColors.primaryColor),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(toY: 4200, color: AppColors.primaryColor),
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(toY: 3800, color: AppColors.primaryColor),
            ],
          ),
        ],
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1.w,
            );
          },
        ),
      ),
    );
  }

  Widget _buildYearlyChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40.r,
        sections: [
          PieChartSectionData(
            color: AppColors.primaryColor,
            value: 35,
            title: '35%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: 25,
            title: '25%',
            radius: 45.r,
            titleStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: 20,
            title: '20%',
            radius: 40.r,
            titleStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: 20,
            title: '20%',
            radius: 35.r,
            titleStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: CustomText(
              text: label,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Expanded(
            child: CustomText(
              text: value,
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              CustomText(
                text: title,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: value,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  String _getTotalEarnings() {
    switch (_selectedPeriod) {
      case 'Week':
        return CurrencyFormatter.formatAmount(context, '9200');
      case 'Month':
        return CurrencyFormatter.formatAmount(context, '14000');
      case 'Year':
        return CurrencyFormatter.formatAmount(context, '168000');
      default:
        return CurrencyFormatter.formatAmount(context, '9200');
    }
  }

  String _getAverageEarnings() {
    switch (_selectedPeriod) {
      case 'Week':
        return CurrencyFormatter.formatAmount(context, '1314');
      case 'Month':
        return CurrencyFormatter.formatAmount(context, '3500');
      case 'Year':
        return CurrencyFormatter.formatAmount(context, '14000');
      default:
        return CurrencyFormatter.formatAmount(context, '1314');
    }
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'Week':
        return AppLocalizations.of(context)!.periodWeek;
      case 'Month':
        return AppLocalizations.of(context)!.periodMonth;
      case 'Year':
        return AppLocalizations.of(context)!.periodYear;
      default:
        return period;
    }
  }
}
