import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/config/colors.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:swipe_to/swipe_to.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // Static notification data
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Message',
      'content':
          'You have received a new message from John Doe regarding the project timeline.',
      'status': 'read',
      'time': '10:30',
      'period': 'AM',
      'isNew': true,
    },
    {
      'title': 'Order Update',
      'content':
          'Your order #12345 has been successfully delivered to the customer.',
      'status': 'unread',
      'time': '09:15',
      'period': 'AM',
      'isNew': false,
    },
    {
      'title': 'Payment Received',
      'content': 'Payment of \$25.50 has been received for order #12340.',
      'status': 'read',
      'time': 'Yesterday',
      'period': '',
      'isNew': false,
    },
    {
      'title': 'System Maintenance',
      'content':
          'Scheduled maintenance will occur tonight from 2:00 AM to 4:00 AM.',
      'status': 'unread',
      'time': '2:00',
      'period': 'AM',
      'isNew': true,
    },
    {
      'title': 'Earnings Update',
      'content':
          'Your weekly earnings report is now available. Check your dashboard.',
      'status': 'read',
      'time': 'Yesterday',
      'period': '',
      'isNew': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScaffold(
          appBar: CustomAppBarWithoutNavbar(
            title: AppLocalizations.of(context)!.notifications,
          ),
          body: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Notifications List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: SwipeTo(
        swipeSensitivity: 6,
        onRightSwipe: (details) {
          setState(() {
            if (notification['status'] == "read") {
              notification['status'] = "unread";
            } else {
              notification['status'] = "read";
            }
          });
        },
        iconOnRightSwipe: Icons.arrow_forward_ios_sharp,
        iconColor: Theme.of(context).colorScheme.sameColorChange,
        child: Stack(
          children: [
            CustomCard(
              padding: EdgeInsets.zero,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Notification content
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 15.w,
                            decoration: BoxDecoration(
                              color:
                                  notification['status'] == "read"
                                      ? AppColors.primaryColor
                                      : AppColors.errorColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(58.r),
                                bottomLeft: Radius.circular(58.r),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header row with title and timestamp
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Expanded(
                                        child: CustomText(
                                          text: notification['title'],
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.oppColorChange,
                                        ),
                                      ),

                                      // Timestamp
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          CustomText(
                                            text: notification['time'],
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.oppColorChange,
                                          ),
                                          SizedBox(width: 2.w),
                                          if (notification['period'].isNotEmpty)
                                            CustomText(
                                              text: notification['period'],
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.oppColorChange,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8.h),

                                  // Content
                                  CustomText(
                                    text: notification['content'],
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .oppColorChange
                                        .withValues(alpha: 0.5),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned(
            //   left: 0,
            //   top: 0,
            //   bottom: 0,
            //   child: Container(
            //     width: 5.w,
            //     decoration: BoxDecoration(
            //       color: notification['status'] == "read"
            //           ? AppColors.primaryColor
            //           : AppColors.errorColor,
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(58.r),
            //         bottomLeft: Radius.circular(58.r),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
