import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/colors.dart';
import '../../../../utils/widgets/custom_scaffold.dart';
import '../../../../utils/widgets/custom_appbar_without_navbar.dart';
import '../../../../utils/widgets/custom_card.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/custom_button.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../../../utils/currency_formatter.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import '../model/earnings_model.dart';
import '../repo/earnings_repo.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';


class AllEarningsPage extends StatefulWidget {
  const AllEarningsPage({super.key});

  @override
  State<AllEarningsPage> createState() => _AllEarningsPageState();
}

class AllEarningsPageWithBloc extends StatelessWidget {
  const AllEarningsPageWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EarningsBloc(EarningsRepo()),
      child: const AllEarningsPage(),
    );
  }
}

class _AllEarningsPageState extends State<AllEarningsPage> {

  @override
  void initState() {
    super.initState();
    
    // Fetch all earnings by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsBloc>().add(FetchYearlyEarnings());
    });
  }
  


  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.expectedEarning;
    
    return CustomScaffold(
      appBar: CustomAppBarWithoutNavbar(
        title: title,
      ),
      body: BlocConsumer<EarningsBloc, EarningsState>(
        listener: (context, state) {
          /*if (state is EarningsError) {
            ToastManager.show(
              context: context,
              message: state.message,
              type: ToastType.error,
            );
          }*/
        },
        builder: (context, state) {
          if (state is EarningsLoading) {
            return const Center(child: LoadingWidget());
          } else if (state is EarningsLoaded) {
            return _buildAllEarningsList(state);
          } else if (state is EarningsError) {
            return _buildErrorState(state.message);
          }
          
          return const Center(child: LoadingWidget());
        },
      ),
    );
  }

  Widget _buildAllEarningsList(EarningsState state) {
    if (state is! EarningsLoaded) return const SizedBox.shrink();
    
    final response = state.response;
    if (response.data?.earnings == null || response.data!.earnings!.isEmpty) {
      return _buildEmptyState();
    }

    final earnings = response.data!.earnings!;
    final totalEarningsCount = response.data?.total ?? earnings.length;

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !state.isFetchingMore &&
            !state.hasReachedMax) {
          context.read<EarningsBloc>().add(LoadMoreEarnings(dateRange: 'last_365_days'));
        }
        return true;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: earnings.length + (state.hasReachedMax ? 1 : 2),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text:
                      '${AppLocalizations.of(context)!.totalEarnings}: $totalEarningsCount',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 20.h),
              ],
            );
          }
          
          if (index <= earnings.length) {
            final earning = earnings[index - 1];
            return _buildEarningCard(earning);
          }
          
          if (!state.hasReachedMax) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(child: LoadingWidget()),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEarningCard(EarningsModel earning) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: CustomCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.orderNumber(earning.orderId.toString()),
                  
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(earning.paymentStatus).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: CustomText(
                    text: earning.paymentStatus?.toLowerCase() == 'paid' 
                        ? AppLocalizations.of(context)!.paid
                        : AppLocalizations.of(context)!.pending,
                    
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(earning.paymentStatus),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Earnings Breakdown
            if (earning.earnings != null) ...[
              _buildEarningsBreakdown(earning.earnings!, isDarkTheme),
              SizedBox(height: 12.h),
            ],

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.total,
                  
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: CurrencyFormatter.formatAmount(context, earning.earnings?.total ?? '0'),
                  
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            // Date
            CustomText(
              text: '${AppLocalizations.of(context)!.date} ${earning.orderDate ?? earning.createdAt ?? ''}',
              
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBreakdown(EarningsDetailModel earnings, bool isDarkTheme) {
    return Column(
      children: [
        _buildBreakdownRow('Base Fee', earnings.baseFee ?? '0', isDarkTheme),
        _buildBreakdownRow('Store Pickup', earnings.perStorePickupFee ?? '0', isDarkTheme),
        _buildBreakdownRow('Distance Fee', earnings.distanceBasedFee ?? '0', isDarkTheme),
        _buildBreakdownRow('Incentive', earnings.perOrderIncentive ?? '0', isDarkTheme),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String amount, bool isDarkTheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money_outlined,
            size: 64.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: AppLocalizations.of(context)!.noEarningsYet,
            
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: AppLocalizations.of(context)!.completeDeliveriesMessage,
            
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: AppLocalizations.of(context)!.errorLoadingEarnings,

            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: message,

            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          CustomButton(
            onPressed: () {
              context.read<EarningsBloc>().add(FetchYearlyEarnings());
            },
            text: AppLocalizations.of(context)!.retry,
            backgroundColor: AppColors.primaryColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
} 
