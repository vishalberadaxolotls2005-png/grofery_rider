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
import '../../../../utils/widgets/custom_scaffold.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_event.dart';
import '../../bloc/profile_bloc/profile_state.dart';
import '../../repo/profile_repo.dart';
import '../../model/profile_model.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  @override
  void initState() {
    super.initState();
    // Load profile data
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.documents,
        showRefreshButton: false,
        showThemeToggle: false,
      ),
      body: BlocProvider(
        create:
            (context) => ProfileBloc(ProfileRepo())..add(const LoadProfile()),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is DocumentUploaded) {
              ToastManager.show(
                context: context,
                message: state.message,
                type: ToastType.success,
              );
            } else if (state is ProfileError) {
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
              return _buildDocumentsContent(state.profile);
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

  Widget _buildDocumentsContent(ProfileModel profile) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Documents Header
          _buildDocumentsHeader(profile, isDarkTheme),
          SizedBox(height: 24.h),

          // Required Documents
          _buildSectionTitle(AppLocalizations.of(context)!.requiredDocuments),
          SizedBox(height: 16.h),

          _buildDocumentCard(
            title: AppLocalizations.of(context)!.driverLicense,
            description: AppLocalizations.of(context)!.driverLicenseDescription,
            icon: Icons.credit_card,
            status:
                profile.deliveryBoy?.driverLicense != null &&
                        profile.deliveryBoy!.driverLicense!.isNotEmpty
                    ? AppLocalizations.of(context)!.uploaded
                    : AppLocalizations.of(context)!.notUploaded,
            color:
                profile.deliveryBoy?.driverLicense != null &&
                        profile.deliveryBoy!.driverLicense!.isNotEmpty
                    ? Colors.green
                    : Colors.red,
            url:
                profile.deliveryBoy?.driverLicense?.isNotEmpty == true
                    ? profile.deliveryBoy!.driverLicense!.first
                    : null,
            documentType: 'driver_license',
            isUploaded:
                profile.deliveryBoy?.driverLicense != null &&
                profile.deliveryBoy!.driverLicense!.isNotEmpty,
            allUrls: profile.deliveryBoy?.driverLicense,
          ),
          const SizedBox(height: 16),

          _buildDocumentCard(
            title: AppLocalizations.of(context)!.vehicleRegistration,
            description:
                AppLocalizations.of(context)!.vehicleRegistrationDescription,
            icon: Icons.description_outlined,
            status:
                profile.deliveryBoy?.vehicleRegistration != null &&
                        profile.deliveryBoy!.vehicleRegistration!.isNotEmpty
                    ? AppLocalizations.of(context)!.uploaded
                    : AppLocalizations.of(context)!.notUploaded,
            color:
                profile.deliveryBoy?.vehicleRegistration != null &&
                        profile.deliveryBoy!.vehicleRegistration!.isNotEmpty
                    ? Colors.green
                    : Colors.red,
            url:
                profile.deliveryBoy?.vehicleRegistration?.isNotEmpty == true
                    ? profile.deliveryBoy!.vehicleRegistration!.first
                    : null,
            documentType: 'vehicle_registration',
            isUploaded:
                profile.deliveryBoy?.vehicleRegistration != null &&
                profile.deliveryBoy!.vehicleRegistration!.isNotEmpty,
            allUrls: profile.deliveryBoy?.vehicleRegistration,
          ),
          const SizedBox(height: 24),

          // Document Guidelines

          // Upload Progress
          if (profile.deliveryBoy?.driverLicense != null &&
              profile.deliveryBoy?.vehicleRegistration != null) ...[
            _buildSectionTitle(AppLocalizations.of(context)!.uploadProgress),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32.sp,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomText(
                          text:
                              AppLocalizations.of(
                                context,
                              )!.allDocumentsUploaded,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CustomText(
                    text:
                        AppLocalizations.of(
                          context,
                        )!.allDocumentsUploadedDescription,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildSectionTitle(AppLocalizations.of(context)!.nextSteps),
            SizedBox(height: 16.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 32.sp),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomText(
                          text: 'Action Required',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  CustomText(
                    text:
                        'Please upload the required documents to complete your profile verification and start accepting orders.',
                    fontSize: 14.sp,
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

  Widget _buildDocumentsHeader(ProfileModel profile, bool isDarkTheme) {
    final uploadedCount =
        [
          profile.deliveryBoy?.driverLicense,
          profile.deliveryBoy?.vehicleRegistration,
        ].where((url) => url != null).length;

    final totalCount = 2;
    final progress = uploadedCount / totalCount;

    return CustomCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(
              Icons.folder_open,
              size: 40.sp,
              color:
                  isDarkTheme
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'Document Management',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                isDarkTheme
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (progress == 1.0 ? Colors.green : Colors.orange)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              text: '$uploadedCount of $totalCount Documents',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  isDarkTheme
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : Colors.white,
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

  Widget _buildDocumentCard({
    required String title,
    required String description,
    required IconData icon,
    required String status,
    required Color color,
    String? url,
    required String documentType,
    required bool isUploaded,
    List<String>? allUrls,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: title,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomText(
                            text: status,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      text: description,
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Show document images if uploaded
          if (isUploaded && url != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.image, color: color, size: 16),
                      const SizedBox(width: 8),
                      CustomText(
                        text: 'Document Images:',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Display the document image(s)
                  if (allUrls != null && allUrls.length > 1) ...[
                    // Show multiple images in a grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: allUrls.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: allUrls[index].isNotEmpty
                              ? Image.network(
                                allUrls[index],
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildErrorPlaceholder();
                                },
                              )
                              : _buildErrorPlaceholder(),
                        );
                      },
                    ),
                  ] else ...[
                    // Show single image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: url.isNotEmpty
                          ? Image.network(
                            url,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildErrorPlaceholder(height: 200);
                            },
                          )
                          : _buildErrorPlaceholder(height: 200),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(children: [const Spacer()]),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder({double height = double.infinity}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.grey, size: height > 100 ? 32 : 24),
          const SizedBox(height: 4),
          CustomText(
            text: 'Failed to load',
            fontSize: height > 100 ? 12 : 10,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }


}
