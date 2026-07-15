import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';
import '../../../utils/widgets/custom_appbar_without_navbar.dart';
import '../../../utils/widgets/custom_scaffold.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../config/colors.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/ratings_bloc.dart';
import '../bloc/ratings_event.dart';
import '../bloc/ratings_state.dart';
import '../repo/ratings_repo.dart';
import '../model/ratings_model.dart';

class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final Map<int, bool> _expandedReviews = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RatingsBloc(RatingsRepo())..add(FetchRatings()),
      child: Builder(
        builder: (context) {
          // Now this context has access to RatingsBloc
          return CustomScaffold(
            appBar: CustomAppBarWithoutNavbar(
              title: AppLocalizations.of(context)!.feedback,
            ),
            body: BlocBuilder<RatingsBloc, RatingsState>(
              builder: (context, state) {
                if (state is RatingsLoading) {
                  return const Center(child: LoadingWidget());
                } else if (state is RatingsError) {
                  return EmptyStateWidget.noData(
                    onRetry: () {
                      context.read<RatingsBloc>().add(FetchRatings());
                    },
                  );
                } else if (state is RatingsLoaded) {
                  return _buildRatingsContent(context, state);
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: AppLocalizations.of(context)!.noReviewsYet,
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text:
                              AppLocalizations.of(
                                context,
                              )!.beFirstToLeaveReview,
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingsContent(BuildContext context, RatingsLoaded state) {
    final feedback = state.feedback;
    final overallRatings = state.overallRatings;

    if (feedback.data.feedbackItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            CustomText(
              text: AppLocalizations.of(context)!.noReviewsYet,
              fontSize: 18.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: AppLocalizations.of(context)!.beFirstToLeaveReview,
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ],
        ),
      );
    }

    // Calculate ratings statistics from feedback data if ratings API returns empty data
    final calculatedRatings = _calculateRatingsFromFeedback(
      feedback.data.feedbackItems,
    );
    final ratingsData =
        overallRatings.data.totalReviews > 0
            ? overallRatings.data
            : calculatedRatings;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<RatingsBloc>().add(RefreshRatings());
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.isFetchingMore &&
              !state.hasReachedMax &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            context.read<RatingsBloc>().add(LoadMoreRatings());
          }
          return false;
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Overall Rating + Rating Breakdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Overall Rating Section (Left)
                  _buildOverallRatingSection(ratingsData),
                  SizedBox(height: 16.w),
                  // Rating Breakdown Section (Right)
                  _buildRatingBreakdownSection(ratingsData.ratingsBreakdown),
                ],
              ),
              SizedBox(height: 24.h),

              // User Reviews Section
              _buildUserReviewsSection(feedback.data.feedbackItems),

              // Pagination Loading Indicator
              if (state.isFetchingMore)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),

              // End of List placeholder padding
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate ratings statistics from feedback data when ratings API is empty
  RatingsData _calculateRatingsFromFeedback(
    List<DeliveryFeedback> feedbackList,
  ) {
    if (feedbackList.isEmpty) {
      return RatingsData(
        totalReviews: 0,
        averageRating: 0.0,
        ratingsBreakdown: RatingsBreakdown(
          oneStar: 0,
          twoStar: 0,
          threeStar: 0,
          fourStar: 0,
          fiveStar: 0,
        ),
      );
    }

    final totalReviews = feedbackList.length;
    final totalRating = feedbackList.fold<int>(
      0,
      (sum, feedback) => sum + feedback.rating,
    );
    final averageRating = totalRating / totalReviews;

    // Count ratings by star
    int oneStar = 0, twoStar = 0, threeStar = 0, fourStar = 0, fiveStar = 0;
    for (final feedback in feedbackList) {
      switch (feedback.rating) {
        case 1:
          oneStar++;
          break;
        case 2:
          twoStar++;
          break;
        case 3:
          threeStar++;
          break;
        case 4:
          fourStar++;
          break;
        case 5:
          fiveStar++;
          break;
      }
    }

    return RatingsData(
      totalReviews: totalReviews,
      averageRating: averageRating,
      ratingsBreakdown: RatingsBreakdown(
        oneStar: oneStar,
        twoStar: twoStar,
        threeStar: threeStar,
        fourStar: fourStar,
        fiveStar: fiveStar,
      ),
    );
  }

  Widget _buildOverallRatingSection(RatingsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title: Overall Rating
        CustomText(
          text: AppLocalizations.of(context)!.overallRating,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(
            context,
          ).colorScheme.oppColorChange.withValues(alpha: 0.7),
        ),

        // Large Numerical Rating
        CustomText(
          text: data.averageRating.toStringAsFixed(1),
          fontSize: 36.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(
            context,
          ).colorScheme.oppColorChange.withValues(alpha: 0.7),
        ),

        // Star Rating Display
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(5, (index) {
              if (index < data.averageRating.floor()) {
                return Icon(Icons.star, color: Colors.yellow, size: 28.sp);
              } else if (index == data.averageRating.floor() &&
                  data.averageRating % 1 > 0) {
                return Icon(Icons.star_half, color: Colors.yellow, size: 28.sp);
              } else {
                return Icon(
                  Icons.star_border,
                  color: Colors.grey[400],
                  size: 28.sp,
                );
              }
            }),
          ],
        ),
        SizedBox(height: 20.h),

        // Review Count
        CustomText(
          text: AppLocalizations.of(context)!.basedOnReviews(data.totalReviews),
          fontSize: 14.sp,
          color: Theme.of(
            context,
          ).colorScheme.oppColorChange.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _buildRatingBreakdownSection(RatingsBreakdown breakdown) {
    final totalReviews =
        breakdown.oneStar +
        breakdown.twoStar +
        breakdown.threeStar +
        breakdown.fourStar +
        breakdown.fiveStar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingBar(
          AppLocalizations.of(context)!.star5,
          breakdown.fiveStar,
          totalReviews,
          AppColors.primaryColor,
        ),
        SizedBox(height: 8.h),
        _buildRatingBar(
          AppLocalizations.of(context)!.star4,
          breakdown.fourStar,
          totalReviews,
          AppColors.primaryColor,
        ),
        SizedBox(height: 8.h),
        _buildRatingBar(
          AppLocalizations.of(context)!.star3,
          breakdown.threeStar,
          totalReviews,
          AppColors.primaryColor,
        ),
        SizedBox(height: 8.h),
        _buildRatingBar(
          AppLocalizations.of(context)!.star2,
          breakdown.twoStar,
          totalReviews,
          AppColors.primaryColor,
        ),
        SizedBox(height: 8.h),
        _buildRatingBar(
          AppLocalizations.of(context)!.star1,
          breakdown.oneStar,
          totalReviews,
          AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget _buildRatingBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        SizedBox(
          // width: 30.w,
          child: CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Theme.of(context).colorScheme.ratingColorChange,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8.h,

            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 50.w,
          child: CustomText(
            text: count.toString(),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildUserReviewsSection(List<DeliveryFeedback> feedbackList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),

        // Actual Reviews from API
        ...feedbackList.map(
          (feedback) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildReviewCard(feedback),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(DeliveryFeedback feedback) {
    final isExpanded = _expandedReviews[feedback.id] ?? false;
    final description = feedback.description;
    final shouldShowSeeMore = description.length > 100;
    final displayText =
        isExpanded
            ? description
            : (description.length > 100
                ? '${description.substring(0, 100)}...'
                : description);

    return CustomCard(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.oppColorChange.withValues(alpha: 0.2),
                child:
                    feedback.user.profileImage.isNotEmpty
                        ? ClipOval(
                          child: Image.network(
                            feedback.user.profileImage,
                            width: 44.r,
                            height: 44.r,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CustomText(text: feedback.user.name);
                            },
                          )
                          ,
                        )
                        : CustomText(text: feedback.user.name),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: feedback.user.name,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < feedback.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.primaryColor,
                            size: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        CustomText(
                          text: '${feedback.rating}.0',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CustomText(
                text: _formatDate(feedback.createdAt),
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (feedback.title.isNotEmpty) ...[
            CustomText(
              text: feedback.title,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 8.h),
          ],
          CustomText(
            text: displayText,
            fontSize: 14.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.9),
          ),
          if (shouldShowSeeMore)
            GestureDetector(
              onTap:
                  () => setState(
                    () => _expandedReviews[feedback.id] = !isExpanded,
                  ),
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: CustomText(
                  text:
                      isExpanded
                          ? AppLocalizations.of(context)!.seeLess
                          : AppLocalizations.of(context)!.seeMore,
                  fontSize: 14.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppLocalizations.of(context)!.today;
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return AppLocalizations.of(context)!.weeksAgo(weeks);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
