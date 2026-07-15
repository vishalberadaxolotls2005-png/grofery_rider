import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';
import 'package:grofery_rider/utils/widgets/loading_widget.dart';
import 'package:grofery_rider/utils/currency_formatter.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/bloc/cash_collection_bloc.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/bloc/cash_collection_event.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/bloc/cash_collection_state.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/repo/cash_collection_repo.dart';
import 'package:grofery_rider/screens/pockets/cash_collection/model/cash_collection_model.dart';

import '../../../../config/colors.dart';

class AllCashCollectionPage extends StatefulWidget {
  const AllCashCollectionPage({super.key});

  @override
  State<AllCashCollectionPage> createState() => _AllCashCollectionPageState();
}

class _AllCashCollectionPageState extends State<AllCashCollectionPage> {
  CashCollectionResponse? _currentResponse;
  String? _selectedSubmissionStatus;
  String? _selectedDateRange;
  final ScrollController _scrollController = ScrollController();

  final List<String> _submissionStatusOptions = [
    'pending',
    'partially_submitted',
    'submitted',
  ];

  final List<String> _dateRangeOptions = [
    'last_30_minutes',
    'last_1_hour',
    'last_5_hours',
    'last_1_day',
    'last_7_days',
    'last_30_days',
    'last_365_days',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch yearly cash collection by default
    context.read<CashCollectionBloc>().add(
      FetchCashCollectionByDateRange('last_365_days'),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<CashCollectionBloc>().add(LoadMoreCashCollection());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Store current filter values to restore if cancel is pressed
    final String? originalSubmissionStatus = _selectedSubmissionStatus;
    final String? originalDateRange = _selectedDateRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildFilterBottomSheet(
            originalSubmissionStatus,
            originalDateRange,
            (submissionStatus, dateRange) {
              setState(() {
                _selectedSubmissionStatus = submissionStatus;
                _selectedDateRange = dateRange;
              });
            },
          ),
    );
  }

  Widget _buildFilterBottomSheet(
    String? originalSubmissionStatus,
    String? originalDateRange,
    Function(String?, String?) onFilterChanged,
  ) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        // Create local state variables for the bottom sheet
        String? localSubmissionStatus = _selectedSubmissionStatus;
        String? localDateRange = _selectedDateRange;

        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: CustomText(
                  text: AppLocalizations.of(context)!.filterCashCollections,

                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // SizedBox(height: 20.h,),
              Divider(color: AppColors.secondaryColor.withValues(alpha: 0.2)),

              // Submission Status Section
              _buildFilterSection(
                AppLocalizations.of(context)!.submissionStatus,
                _submissionStatusOptions,
                localSubmissionStatus,
                (value) {
                  setLocalState(() {
                    localSubmissionStatus = value;
                  });
                  onFilterChanged(value, localDateRange);
                },
                _getStatusDisplayText,
                isDarkTheme,
              ),

              SizedBox(height: 20.h),

              // Date Range Section
              _buildFilterSection(
                AppLocalizations.of(context)!.dateRangeLast,
                _dateRangeOptions,
                localDateRange,
                (value) {
                  setLocalState(() {
                    localDateRange = value;
                  });
                  onFilterChanged(localSubmissionStatus, value);
                },
                _getDateRangeDisplayText,
                isDarkTheme,
              ),

              const Spacer(),

              // Action Buttons
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        textSize: 15.sp,
                        text: AppLocalizations.of(context)!.cancel,
                        onPressed: () {
                          // Restore original filter values
                          setState(() {
                            _selectedSubmissionStatus =
                                originalSubmissionStatus;
                            _selectedDateRange = originalDateRange;
                          });

                          // Fetch unfiltered list
                          context.read<CashCollectionBloc>().add(
                            FetchCashCollection(),
                          );

                          Navigator.pop(context);
                        },
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                        // height: 36.h,height
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomButton(
                        textSize: 15.sp,
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        text: AppLocalizations.of(context)!.apply,
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                        // height: 36.h,
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
    String Function(String) displayText,
    bool isDarkTheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,

            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = selectedValue == option;
                return Container(
                  margin: EdgeInsets.only(
                    right: index < options.length - 1 ? 12.w : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onChanged(isSelected ? null : option),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppColors.primaryColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.primaryColor
                                  : Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            text: displayText(option),

                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                          ),
                          if (isSelected) ...[
                            SizedBox(width: 6.w),
                            Icon(Icons.check, color: Colors.white, size: 14.sp),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    // Fetch data with selected filters
    context.read<CashCollectionBloc>().add(
      FetchCashCollectionByDateRange(
        _selectedDateRange ?? '',
        submissionStatus: _selectedSubmissionStatus,
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

  String _getDateRangeDisplayText(String dateRange) {
    switch (dateRange) {
      case 'last_30_minutes':
        return AppLocalizations.of(context)!.last30Minutes;
      case 'last_1_hour':
        return AppLocalizations.of(context)!.last1Hour;
      case 'last_5_hours':
        return AppLocalizations.of(context)!.last5Hours;
      case 'last_1_day':
        return AppLocalizations.of(context)!.last1Day;
      case 'last_7_days':
        return AppLocalizations.of(context)!.last7Days;
      case 'last_30_days':
        return AppLocalizations.of(context)!.last30Days;
      case 'last_365_days':
        return AppLocalizations.of(context)!.last365Days;
      case 'all':
        return AppLocalizations.of(context)!.all;
      default:
        return AppLocalizations.of(context)!.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return CustomScaffold(
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.allCashCollection,

        additionalActions: [
          IconButton(
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            icon: Icon(Icons.filter_list, color: AppColors.textSecondaryColor),
          ),
        ],
      ),
      body: BlocConsumer<CashCollectionBloc, CashCollectionState>(
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
            return Center(child: const LoadingWidget());
          } else if (state is CashCollectionError) {
            return ErrorStateWidget(
              onRetry: () {
                context.read<CashCollectionBloc>().add(
                  FetchCashCollectionByDateRange('last_365_days'),
                );
              },
            );
            // return _buildErrorState(state.message);
          } else if (state is CashCollectionLoaded ||
              state is CashCollectionDateRangeLoaded) {
            final response = _currentResponse!;
            final cashCollections = response.data?.cashCollections ?? [];

            // ADD THIS CHECK
            if (cashCollections.isEmpty) {
              return _buildEmptyState(isDarkTheme);
            }

            final bool isFetchingMore =
                state is CashCollectionLoaded
                    ? state.isFetchingMore
                    : (state as CashCollectionDateRangeLoaded).isFetchingMore;

            return _buildAllCashCollectionList(
              response,
              isDarkTheme,
              isFetchingMore,
            );
          }
          return _buildEmptyState(isDarkTheme);
        },
      ),
    );
  }

  Widget _buildAllCashCollectionList(
    CashCollectionResponse response,
    bool isDarkTheme,
    bool isFetchingMore,
  ) {
    final cashCollections = response.data?.cashCollections ?? [];

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: cashCollections.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == cashCollections.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const Center(child: LoadingWidget()),
          );
        }
        final collection = cashCollections[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildCashCollectionCard(collection, isDarkTheme),
        );
      },
    );
  }

  Widget _buildCashCollectionCard(
    CashCollectionModel collection,
    bool isDarkTheme,
  ) {
    return CustomCard(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
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
            _buildCashCollectionDetails(collection, isDarkTheme),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text:
                  '${AppLocalizations.of(context)!.date}: ${collection.orderDate}',

              fontSize: 14.sp,
              color: AppColors.textSecondaryColor,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.cashCollected,

              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            CustomText(
              text: CurrencyFormatter.formatAmount(
                context,
                collection.cashCollected ?? '0',
              ),

              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.cashSubmitted,

              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            CustomText(
              text: CurrencyFormatter.formatAmount(
                context,
                collection.cashSubmitted ?? '0',
              ),

              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.remainingAmount,

              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            CustomText(
              text: CurrencyFormatter.formatAmount(
                context,
                collection.remainingAmount ?? '0',
              ),

              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDarkTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: AppLocalizations.of(context)!.noCashCollectionYet,

            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text:
                AppLocalizations.of(
                  context,
                )!.completeDeliveriesToSeeCashCollection,

            fontSize: 14.sp,
            color: AppColors.textSecondaryColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'partially_submitted':
        return Colors.blue;
      case 'submitted':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class AllCashCollectionPageWithBloc extends StatelessWidget {
  const AllCashCollectionPageWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CashCollectionBloc(CashCollectionRepo()),
      child: const AllCashCollectionPage(),
    );
  }
}
