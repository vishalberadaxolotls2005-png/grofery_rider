import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';
import 'package:grofery_rider/utils/widgets/loading_widget.dart';
import 'package:grofery_rider/utils/currency_formatter.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/bloc/cash_collection_bloc.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/bloc/cash_collection_event.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/bloc/cash_collection_state.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/model/cash_collection_model.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/repo/cash_collection_repo.dart';

import '../../../../config/colors.dart';

class CashCollectionPage extends StatefulWidget {
  const CashCollectionPage({super.key});

  @override
  State<CashCollectionPage> createState() => _CashCollectionPageState();
}

class _CashCollectionPageState extends State<CashCollectionPage> {
  int _selectedTabIndex = 0;
  CashCollectionResponse? _currentResponse;

  final List<String> _submissionStatusOptions = [
    'pending',
    'partially_submitted',
    'submitted',
  ];

  @override
  void initState() {
    super.initState();

    // Fetch initial data for pending status
    context.read<CashCollectionBloc>().add(
      FetchCashCollectionByDateRange('', submissionStatus: 'pending'),
    );
  }

  void _fetchCashCollectionForStatus(String status) {
    // Fetch cash collection with specific submission status only
    context.read<CashCollectionBloc>().add(
      FetchCashCollectionByDateRange('', submissionStatus: status),
    );
  }

  @override
  Widget build(BuildContext context) {

    return CustomScaffold(
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.cashCollection,

        additionalActions: [
          TextButton(
            onPressed: () {
              context.push('/all-cash-collection');
            },
            child: CustomText(
              text: AppLocalizations.of(context)!.all,

              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryColor,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Range Tabs
          // _buildDateRangeTabs(),

          // Submission Status Tabs
          Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _submissionStatusOptions.length,
              itemBuilder: (context, index) {
                final status = _submissionStatusOptions[index];
                final isSelected = _selectedTabIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                    // Fetch data for the specific submission status
                    final status = _submissionStatusOptions[index];
                    _fetchCashCollectionForStatus(status);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 0.h,
                    ),
                    alignment: Alignment.center, // Add this line
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.transparent
                                : Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: CustomText(
                      text: _getStatusDisplayText(status),

                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: _buildTabContent(
              _submissionStatusOptions[_selectedTabIndex],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDateRangeTabs() {
  //   final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
  //
  //   return Container(
  //     height: 60.h,
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).colorScheme.surface,
  //       border: Border(
  //         bottom: BorderSide(
  //           color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: _dateRangeOptions.length,
  //       itemBuilder: (context, index) {
  //         final dateRange = _dateRangeOptions[index];
  //         final isSelected = _selectedDateRange == dateRange;
  //
  //         return GestureDetector(
  //           onTap: () => _onDateRangeChanged(dateRange),
  //           child: Container(
  //             margin: EdgeInsets.only(right: 12.w),
  //             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
  //             decoration: BoxDecoration(
  //               color: isSelected
  //                   ? AppColors.primaryColor
  //                   : Theme.of(context).colorScheme.surface,
  //               borderRadius: BorderRadius.circular(25.r),
  //               border: Border.all(
  //                 color: isSelected
  //                     ? AppColors.primaryColor
  //                     : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
  //                 width: 1.5,
  //               ),
  //               boxShadow: isSelected ? [
  //                 BoxShadow(
  //                   color: AppColors.primaryColor.withValues(alpha: 0.3),
  //                   blurRadius: 8.r,
  //                   offset: Offset(0, 2.h),
  //                 ),
  //               ] : null,
  //             ),
  //             child: CustomText(
  //               text: _getDateRangeDisplayText(dateRange),
  //
  //               fontSize: 13.sp,
  //               fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
  //               color: isSelected
  //                   ? Colors.white
  //                   : Theme.of(context).colorScheme.onSurface,
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildTabContent(String status) {
    return BlocConsumer<CashCollectionBloc, CashCollectionState>(
      listener: (context, state) {
        if (state is CashCollectionLoaded ||
            state is CashCollectionDateRangeLoaded) {
          if (state is CashCollectionLoaded) {
            _currentResponse = state.response;
          } else if (state is CashCollectionDateRangeLoaded) {
            _currentResponse = state.response;
          }
        }
      },
      builder: (context, state) {
        if (state is CashCollectionLoading) {
          return const LoadingWidget();
        } else if (state is CashCollectionError) {
          return ErrorStateWidget(
              onRetry: (){
                context.read<CashCollectionBloc>().add(
                  FetchCashCollectionByDateRange('last_1_day'),
                );
              }
          );
          // return _buildErrorState(state.message);
        } else if (state is CashCollectionLoaded ||
            state is CashCollectionDateRangeLoaded) {
          final response = _currentResponse;
          if (response?.data?.cashCollections == null ||
              response!.data!.cashCollections!.isEmpty) {
            return _buildEmptyState();
          }

          // Filter by submission status
          final filteredCollections =
              response.data!.cashCollections!
                  .where((collection) => collection.submissionStatus == status)
                  .toList();

          if (filteredCollections.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCashCollectionList(filteredCollections);
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildCashCollectionList(List<CashCollectionModel> earnings) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: earnings.length,
      itemBuilder: (context, index) {
        final collection = earnings[index];
        return _buildCashCollectionCard(collection);
      },
    );
  }

  Widget _buildCashCollectionCard(CashCollectionModel collection) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
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
                  text:
                      '${AppLocalizations.of(context)!.order} #${collection.orderId}',

                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(collection.submissionStatus ?? ''),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: CustomText(
                    text: _getStatusDisplayText(
                      collection.submissionStatus ?? '',
                    ),

                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Date
            CustomText(
              text:
                  '${AppLocalizations.of(context)!.date}: ${collection.orderDate ?? AppLocalizations.of(context)!.na}',

              fontSize: 12.sp,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),

            SizedBox(height: 16.h),

            SizedBox(height: 16.h),

            // Cash Collection Details
            _buildCashCollectionDetails(collection, isDarkTheme),

            SizedBox(height: 16.h),

            // Remaining Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)!.remainingAmount,

                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  text: CurrencyFormatter.formatAmount(
                    context,
                    collection.remainingAmount?.toString() ?? '0',
                  ),

                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashCollectionDetails(
    CashCollectionModel collection,
    bool isDarkTheme,
  ) {
    return Column(
      children: [
        _buildBreakdownRow(
          AppLocalizations.of(context)!.cashCollected,
          collection.cashCollected ?? '0',
          isDarkTheme,
        ),
        _buildBreakdownRow(
          AppLocalizations.of(context)!.cashSubmitted,
          collection.cashSubmitted ?? '0',
          isDarkTheme,
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String amount, bool isDarkTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,

            fontSize: 12.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: AppLocalizations.of(context)!.noCashCollectionYet,

            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text:
                AppLocalizations.of(
                  context,
                )!.completeDeliveriesToSeeYourCashCollection,

            fontSize: 14.sp,
            textAlign: TextAlign.center,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }


  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'pending':
        return AppLocalizations.of(context)!.pending;
      case 'partially_submitted':
        return AppLocalizations.of(context)!.partiallySubmitted;
      case 'submitted':
        return AppLocalizations.of(context)!.submitted;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'partially_submitted':
        return Colors.blue;
      case 'submitted':
        return AppColors.primaryColor;
      default:
        return Colors.grey;
    }
  }
}

class CashCollectionPageWithBloc extends StatelessWidget {
  const CashCollectionPageWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CashCollectionBloc(CashCollectionRepo()),
      child: const CashCollectionPage(),
    );
  }
}
