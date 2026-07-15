import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';
import 'package:grofery_rider/utils/widgets/loading_widget.dart';
import 'package:grofery_rider/utils/widgets/toast_message.dart';
import '../../../../config/colors.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_event.dart';
import '../../bloc/profile_bloc/profile_state.dart';
import '../../repo/profile_repo.dart';
import '../../model/profile_model.dart';
import 'document_viewer_page.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class VerificationStatusPage extends StatefulWidget {
  const VerificationStatusPage({super.key});

  @override
  State<VerificationStatusPage> createState() => _VerificationStatusPageState();
}

class _VerificationStatusPageState extends State<VerificationStatusPage> {
  @override
  void initState() {
    super.initState();
    // Load profile data
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.verificationStatus,
        showRefreshButton: false,
        showThemeToggle: false,
      ),
      body: BlocProvider(
        create:
            (context) => ProfileBloc(ProfileRepo())..add(const LoadProfile()),
        child: BlocConsumer<ProfileBloc, ProfileState>(
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

            if (state is ProfileLoaded) {
              return _buildVerificationContent(state.profile);
            }

            if (state is ProfileError) {
              return ErrorStateWidget(
                onRetry: (){
                  context.read<ProfileBloc>().add(const LoadProfile());
                }
              );
              // return _buildErrorState(state.message);
            }

            return const Center(child: LoadingWidget());
          },
        ),
      ),
    );
  }

  Widget _buildVerificationContent(ProfileModel profile) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final deliveryBoy = profile.deliveryBoy;

    if (deliveryBoy == null) {
      return _buildNoProfileState();
    }

    final verificationStatus = deliveryBoy.verificationStatus ?? 'pending';
    final statusColor = _getStatusColor(verificationStatus);
    final statusIcon = _getStatusIcon(verificationStatus);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification Header
          _buildVerificationHeader(
            deliveryBoy,
            isDarkTheme,
            statusColor,
            statusIcon,
          ),
          SizedBox(height: 24.h),

          // Current Status
          _buildSectionTitle(AppLocalizations.of(context)!.currentStatus),
          SizedBox(height: 16.h),

          _buildStatusCard(
            status: verificationStatus,
            color: statusColor,
            icon: statusIcon,
          ),
          SizedBox(height: 24.h),

          // Verification Details
          _buildSectionTitle(AppLocalizations.of(context)!.verificationDetails),
          SizedBox(height: 16.h),

          _buildInfoCard(
            title: AppLocalizations.of(context)!.verificationStatus,
            value: verificationStatus.toUpperCase(),
            icon: Icons.verified_user_outlined,
            color: statusColor,
          ),
          SizedBox(height: 16.h),

          if (deliveryBoy.verificationRemark != null &&
              deliveryBoy.verificationRemark!.isNotEmpty) ...[
            _buildInfoCard(
              title: AppLocalizations.of(context)!.verificationRemarks,
              value: deliveryBoy.verificationRemark!,
              icon: Icons.comment_outlined,
              color: Colors.blue,
            ),
            SizedBox(height: 16.h),
          ],

          _buildInfoCard(
            title: AppLocalizations.of(context)!.accountStatus,
            value: deliveryBoy.status ?? AppLocalizations.of(context)!.unknown,
            icon: Icons.account_circle_outlined,
            color:
                (deliveryBoy.status == 'active' ? Colors.green : Colors.orange),
          ),
          SizedBox(height: 24.h),

          // Required Documents
          _buildSectionTitle(AppLocalizations.of(context)!.requiredDocuments),
          SizedBox(height: 16.h),

          _buildDocumentStatusCard(
            title: AppLocalizations.of(context)!.driverLicense,
            status:
                profile.deliveryBoy?.driverLicense != null &&
                        profile.deliveryBoy!.driverLicense!.isNotEmpty
                    ? AppLocalizations.of(context)!.uploaded
                    : AppLocalizations.of(context)!.notUploaded,
            icon: Icons.drive_file_rename_outline,
            color:
                profile.deliveryBoy?.driverLicense != null &&
                        profile.deliveryBoy!.driverLicense!.isNotEmpty
                    ? Colors.green
                    : Colors.red,
            url:
                profile.deliveryBoy?.driverLicense?.isNotEmpty == true
                    ? profile.deliveryBoy!.driverLicense!.first
                    : null,
            allUrls: profile.deliveryBoy?.driverLicense?.toList(),
            documentType: 'driver_license',
          ),
          SizedBox(height: 16.h),

          _buildDocumentStatusCard(
            title: AppLocalizations.of(context)!.vehicleRegistration,
            status:
                profile.deliveryBoy?.vehicleRegistration != null &&
                        profile.deliveryBoy!.vehicleRegistration!.isNotEmpty
                    ? AppLocalizations.of(context)!.uploaded
                    : AppLocalizations.of(context)!.notUploaded,
            icon: Icons.description_outlined,
            color:
                profile.deliveryBoy?.vehicleRegistration != null &&
                        profile.deliveryBoy!.vehicleRegistration!.isNotEmpty
                    ? Colors.green
                    : Colors.red,
            url:
                profile.deliveryBoy?.vehicleRegistration?.isNotEmpty == true
                    ? profile.deliveryBoy!.vehicleRegistration!.first
                    : null,
            allUrls: profile.deliveryBoy?.vehicleRegistration?.toList(),
            documentType: 'vehicle_registration',
          ),
          SizedBox(height: 24.h),

          // // Verification Steps
          // _buildSectionTitle(AppLocalizations.of(context)!.verificationProcess),
          // SizedBox(height: 16.h),
          //
          // _buildVerificationStep(
          //   step: 1,
          //   title: AppLocalizations.of(context)!.documentUpload,
          //   description: AppLocalizations.of(context)!.documentUploadDescription,
          //   isCompleted: profile.deliveryBoy?.driverLicense != null && profile.deliveryBoy?.vehicleRegistration != null,
          //   icon: Icons.upload_file_outlined,
          // ),
          // SizedBox(height: 16.h),
          //
          // _buildVerificationStep(
          //   step: 2,
          //   title: AppLocalizations.of(context)!.documentReview,
          //   description: AppLocalizations.of(context)!.documentReviewDescription,
          //   isCompleted: verificationStatus == 'verified' || verificationStatus == 'rejected',
          //   icon: Icons.rate_review_outlined,
          // ),
          // SizedBox(height: 16.h),
          //
          // _buildVerificationStep(
          //   step: 3,
          //   title: AppLocalizations.of(context)!.verificationCompleteStep,
          //   description: AppLocalizations.of(context)!.verificationCompleteStepDescription,
          //   isCompleted: verificationStatus == 'verified',
          //   icon: Icons.check_circle_outlined,
          // ),
          // SizedBox(height: 24.h),

          // Next Steps
          if (verificationStatus == 'pending') ...[
            _buildSectionTitle(AppLocalizations.of(context)!.nextSteps),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 24.sp),
                      SizedBox(width: 12.w),
                      CustomText(
                        text: AppLocalizations.of(context)!.actionRequired,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CustomText(
                    text: AppLocalizations.of(context)!.uploadDocumentsMessage,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ] else if (verificationStatus == 'rejected') ...[
            _buildSectionTitle(
              AppLocalizations.of(context)!.verificationRejected,
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      CustomText(
                        text: AppLocalizations.of(context)!.verificationFailed,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomText(
                    text:
                        AppLocalizations.of(
                          context,
                        )!.verificationRejectedMessage,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationHeader(
    dynamic deliveryBoy,
    bool isDarkTheme,
    Color statusColor,
    IconData statusIcon,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color:
            isDarkTheme
                ? AppColors.cardDarkColor
                : AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Status Icon Avatar (Left)
          CircleAvatar(
            radius: 40.r,
            backgroundColor:
                isDarkTheme
                    ? Theme.of(context).colorScheme.surface
                    : AppColors.primaryColor.withValues(alpha: 0.15),
            child: Icon(statusIcon, size: 30.sp, color: AppColors.primaryColor),
          ),

          SizedBox(width: 16.w),

          // Name + Verification Badge (Right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delivery Boy Name
                CustomText(
                  text:
                      deliveryBoy.fullName ??
                      AppLocalizations.of(context)!.verificationStatus,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: (deliveryBoy?.verificationStatus == 'verified'
                            ? Colors.green
                            : Colors.orange)
                        .withValues(alpha: isDarkTheme ? 0.3 : 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: CustomText(
                    text:
                        deliveryBoy?.verificationStatus?.toUpperCase() ??
                        'PENDING',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        deliveryBoy?.verificationStatus == 'verified'
                            ? (isDarkTheme
                                ? Colors.green[300]
                                : Colors.green[700])
                            : (isDarkTheme
                                ? Colors.orange[300]
                                : Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return CustomText(
      text: title,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildStatusCard({
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return CustomCard(
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: _getStatusTitle(status),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: _getStatusDescription(status),
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: value.toUpperCase(),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatusCard({
    required String title,
    required String status,
    required IconData icon,
    required Color color,
    String? url,
    List<String>? allUrls,
    String? documentType,
  }) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 4),
                CustomText(
                  text: status,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ],
            ),
          ),
          if (url != null) ...[
            IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                color: AppColors.primaryColor,
              ),
              onPressed: () {
                if (documentType == 'driver_license') {
                  _showDriverLicensePopup(context, allUrls);
                } else if (documentType == 'vehicle_registration') {
                  _showVehicleRegistrationPopup(context, allUrls);
                } else {
                  _viewDocument(url, title);
                }
              },
              tooltip: 'View Documents',
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Icons.verified_user;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Verification Complete';
      case 'rejected':
        return 'Verification Rejected';
      case 'pending':
        return 'Verification Pending';
      default:
        return 'Unknown Status';
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return 'Your account has been successfully verified';
      case 'rejected':
        return 'Your verification was not approved';
      case 'pending':
        return 'Your verification is currently under review';
      default:
        return 'Verification status is unknown';
    }
  }

  void _viewDocument(String? documentUrl, String documentTitle) {
    if (documentUrl == null || documentUrl.isEmpty) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.documentUrlNotAvailable,
        type: ToastType.error,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DocumentViewerPage(
              documentUrl: documentUrl,
              documentTitle: documentTitle,
            ),
      ),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          CustomText(
            text: AppLocalizations.of(context)!.noProfileFound,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: AppLocalizations.of(context)!.unableToLoadVerificationStatus,
            fontSize: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  void _showDriverLicensePopup(BuildContext context, List<String>? urls) {
    if (urls == null || urls.isEmpty) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.noDriverLicenseDocuments,
        type: ToastType.info,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.drive_file_rename_outline,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                // Important: prevents title overflow
                child: CustomText(
                  text: AppLocalizations.of(context)!.driverLicenseDocuments,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite, // Takes max available width
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document count
                CustomText(
                  text:
                      '${urls.length} ${urls.length > 1 ? AppLocalizations.of(context)!.documents : AppLocalizations.of(context)!.documentLbl} found',

                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 16.h),

                // Horizontal scrollable thumbnails – this is the key fix
                SizedBox(
                  height: 100.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(), // Nice feel
                    itemCount: urls.length,
                    itemBuilder: (context, index) {
                      final url = urls[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _viewDocument(
                              url,
                              '${AppLocalizations.of(context)!.driverLicense} ${index + 1}',
                            );
                          },
                          child: Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              color: Colors.grey.withValues(alpha: 0.1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: url.isNotEmpty
                                ? Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 32.sp,
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                    size: 32.sp,
                                  ),
                                ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: CustomText(
                text: AppLocalizations.of(context)!.close,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showVehicleRegistrationPopup(BuildContext context, List<String>? urls) {
    if (urls == null || urls.isEmpty) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.noVehicleRegistrationDocuments,
        type: ToastType.info,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.primaryColor),
              SizedBox(width: 8.w),
              Expanded(
                child: CustomText(
                  text:
                      AppLocalizations.of(
                        context,
                      )!.vehicleRegistrationDocuments,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Document count
                CustomText(
                  text:
                      '${urls.length} ${urls.length > 1 ? AppLocalizations.of(context)!.documents : AppLocalizations.of(context)!.documentLbl} found',
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 16.h),
                // Horizontal scrollable images
                SizedBox(
                  height: 120.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length,
                    itemBuilder: (context, index) {
                      final url = urls[index];
                      return Container(
                        margin: EdgeInsets.only(right: 12.w),
                        child: Column(
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  url,
                                  width: 80.w,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.grey,
                                        size: 24.sp,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: CustomText(
                text: AppLocalizations.of(context)!.close,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
