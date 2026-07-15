// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/screens/system_settings/bloc/system_settings_bloc.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';
import 'package:grofery_rider/utils/widgets/toast_message.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../config/colors.dart';
import '../../../../utils/widgets/custom_card.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_event.dart';
import '../../bloc/profile_bloc/profile_state.dart';
import '../../model/profile_model.dart';
import '../../../../utils/widgets/custom_textfield.dart';
import 'document_viewer_page.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class VehicleInfoPage extends StatefulWidget {
  const VehicleInfoPage({super.key});

  @override
  State<VehicleInfoPage> createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleTypeController = TextEditingController();
  final _driverLicenseNumberController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  // Store selected files for upload
  List<String> _selectedDriverLicenseFiles = [];
  List<String> _selectedVehicleRegistrationFiles = [];

  // Temporary lists that combine API images and newly selected files
  List<String> _tempDriverLicenseImages = [];
  List<String> _tempVehicleRegistrationImages = [];

  @override
  void initState() {
    super.initState();
    // Load profile data
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _driverLicenseNumberController.dispose();
    super.dispose();
  }

  void _populateFields(ProfileModel profile) {
    if (profile.deliveryBoy != null) {
      _vehicleTypeController.text = profile.deliveryBoy!.vehicleType ?? '';
      _driverLicenseNumberController.text =
          profile.deliveryBoy!.driverLicenseNumber ?? '';

      // Populate temporary lists with API images
      _tempDriverLicenseImages =
          profile.deliveryBoy!.driverLicense?.toList() ?? [];
      _tempVehicleRegistrationImages =
          profile.deliveryBoy!.vehicleRegistration?.toList() ?? [];
    }
  }

  void _toggleEdit() {
    final bool isDemo = context.read<SystemSettingsBloc>().isDemo;
    if (isDemo) {
      ToastManager.show(
        context: context,
        message: context.read<SystemSettingsBloc>().demoMessage,
        type: ToastType.info,
      );
      return;
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      context.read<ProfileBloc>().add(
        UpdateProfile(
          // Only pass the vehicle info fields we're updating
          driverLicenseNumber: _driverLicenseNumberController.text.trim(),
          vehicleType: _vehicleTypeController.text.trim(),
          // Include all documents from temporary lists (API + newly selected)
          driverLicenseFiles:
              _tempDriverLicenseImages.isNotEmpty
                  ? _tempDriverLicenseImages
                  : null,
          vehicleRegistrationFiles:
              _tempVehicleRegistrationImages.isNotEmpty
                  ? _tempVehicleRegistrationImages
                  : null,
        ),
      );
    }
  }

  void _cancelEdit() {
    // Reload profile data to reset fields
    context.read<ProfileBloc>().add(const LoadProfile());
    setState(() {
      _isEditing = false;
      // Clear selected files
      _selectedDriverLicenseFiles = [];
      _selectedVehicleRegistrationFiles = [];
      // Clear temporary lists
      _tempDriverLicenseImages = [];
      _tempVehicleRegistrationImages = [];
    });
  }

  /// Gets combined document URLs from temporary lists
  List<String> _getCombinedDocumentUrls(
    String title,
    List<String>? existingUrls,
  ) {
    // Use temporary lists that combine API images and newly selected files
    if (title.toLowerCase().contains('license')) {
      return _tempDriverLicenseImages.where((url) => url.isNotEmpty).toList();
    } else if (title.toLowerCase().contains('registration')) {
      return _tempVehicleRegistrationImages
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Checks if the given path is a local file path
  bool _isLocalFile(String path) {
    return path.startsWith('/') ||
        path.contains('\\') ||
        (!path.startsWith('http://') && !path.startsWith('https://'));
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

  Future<void> _pickAndUploadDocument(String documentType) async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: true, // Allow multiple files for arrays
      );

      if (result != null && result.files.isNotEmpty) {
        final filePaths =
            result.files
                .map((file) => file.path)
                .where((path) => path != null)
                .cast<String>()
                .toList();

        // Check file sizes (max 10MB each)
        for (final file in result.files) {
          if (file.size > 10 * 1024 * 1024) {
            // 10MB in bytes
            ToastManager.show(
              context: context,
              message: AppLocalizations.of(context)!.fileSizeLimit,
              type: ToastType.error,
            );
            return;
          }
        }

        // Store selected files based on document type
        if (documentType == 'driver_license') {
          setState(() {
            _selectedDriverLicenseFiles = filePaths;
            // Add to temporary list for display and deletion
            _tempDriverLicenseImages.addAll(filePaths);
          });
        } else if (documentType == 'vehicle_registration') {
          setState(() {
            _selectedVehicleRegistrationFiles = filePaths;
            // Add to temporary list for display and deletion
            _tempVehicleRegistrationImages.addAll(filePaths);
          });
        }

        // Show success message
        ToastManager.show(
          context: context,
          message:
              '${filePaths.length} file(s) selected. Click "Save Changes" to upload.',
          type: ToastType.success,
        );
      }
    } catch (e) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.errorPickingFile(e.toString()),
        type: ToastType.error,
      );
    }
  }







  void _removeSpecificImage(String imageUrl, int imageIndex) {
    // Show confirmation dialog for removing specific image
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: 'Remove Image',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          content: CustomText(
            text:
                'Are you sure you want to remove this image? This action cannot be undone.',
            fontSize: 14.sp,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: CustomText(
                text: 'Cancel',
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performSpecificImageRemoval(imageUrl, imageIndex);
              },
              child: CustomText(
                text: 'Remove',
                fontSize: 14.sp,
                color: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _performSpecificImageRemoval(String imageUrl, int imageIndex) {
    // Remove from temporary lists (works for both API images and newly selected files)
    if (_tempDriverLicenseImages.contains(imageUrl)) {
      setState(() {
        _tempDriverLicenseImages.remove(imageUrl);
        // Also remove from selected files if it was there
        _selectedDriverLicenseFiles.remove(imageUrl);
      });
      ToastManager.show(
        context: context,
        message: 'Document removed',
        type: ToastType.success,
      );
    } else if (_tempVehicleRegistrationImages.contains(imageUrl)) {
      setState(() {
        _tempVehicleRegistrationImages.remove(imageUrl);
        // Also remove from selected files if it was there
        _selectedVehicleRegistrationFiles.remove(imageUrl);
      });
      ToastManager.show(
        context: context,
        message: 'Document removed',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.vehicleInformation,
        showRefreshButton: false,
        showThemeToggle: false,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateFields(state.profile);
          } else if (state is ProfileUpdated) {
            _populateFields(state.profile);
            setState(() {
              _isEditing = false;
              _isLoading = false;
              _selectedDriverLicenseFiles = [];
              _selectedVehicleRegistrationFiles = [];
            });
            ToastManager.show(
              context: context,
              message: state.message,
              type: ToastType.success,
            );
          } else if (state is DocumentUploading) {
            setState(() {
              _isLoading = true;
            });
            ToastManager.show(
              context: context,
              message:
                  'Uploading ${state.documentType.replaceAll('_', ' ')}...',
              type: ToastType.info,
            );
          } else if (state is DocumentUploaded) {
            setState(() {
              _isLoading = false;
            });
            ToastManager.show(
              context: context,
              message:
                  '${state.documentType.replaceAll('_', ' ')} uploaded successfully!',
              type: ToastType.success,
            );
            // Reload profile to get updated document URLs
            context.read<ProfileBloc>().add(const LoadProfile());
          } else if (state is ProfileError) {
            setState(() {
              _isLoading = false;
            });
            ToastManager.show(
              context: context,
              message: state.message,
              type: ToastType.error,
            );
          }
        },
        builder: (context, state) {


          // Show content directly, handle loading states gracefully
          if (state is ProfileLoaded || state is ProfileUpdated) {
            final profile =
                state is ProfileLoaded
                    ? state.profile
                    : (state as ProfileUpdated).profile;

            return _buildVehicleInfoContent(profile);
          }

          if (state is ProfileError) {
            return ErrorStateWidget(
              onRetry: (){
                context.read<ProfileBloc>().add(const LoadProfile());
              }
            );
            // return _buildErrorState(state.message);
          }

          // For ProfileLoading or any other state, show content with loading state
          return _buildVehicleInfoContent(
            ProfileModel(),
          ); // Empty profile for initial state
        },
      ),
    );
  }

  Widget _buildVehicleInfoContent(ProfileModel profile) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Header
          _buildVehicleHeader(profile, isDarkTheme),
          SizedBox(height: 24.h),

          // Vehicle Information Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Vehicle Details'),
                SizedBox(height: 16.h),

                // Vehicle Type
                _buildInfoField(
                  label: 'Vehicle Type',
                  controller: _vehicleTypeController,
                  icon: Icons.directions_car_outlined,
                  isEditing: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vehicle type is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Driver License Number
                _buildInfoField(
                  label: 'Driver License Number',
                  controller: _driverLicenseNumberController,
                  icon: Icons.drive_file_rename_outline,
                  isEditing: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Driver license number is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Documents
                _buildSectionTitle('Vehicle Documents'),
                SizedBox(height: 16.h),

                _buildDocumentField(
                  title: 'Driver License',
                  documentUrl:
                      profile.deliveryBoy?.driverLicense?.isNotEmpty == true
                          ? profile.deliveryBoy!.driverLicense!.first
                          : null,
                  icon: Icons.credit_card,
                  color: AppColors.secondaryColor,
                  allUrls:
                      _tempDriverLicenseImages.isNotEmpty
                          ? _tempDriverLicenseImages
                          : profile.deliveryBoy?.driverLicense,
                  isLoading:
                      profile.deliveryBoy ==
                      null, // Show loading when no delivery boy data
                ),
                SizedBox(height: 16.h),

                _buildDocumentField(
                  title: 'Vehicle Registration',
                  documentUrl:
                      profile.deliveryBoy?.vehicleRegistration?.isNotEmpty ==
                              true
                          ? profile.deliveryBoy!.vehicleRegistration!.first
                          : null,
                  icon: Icons.description_outlined,
                  color: AppColors.secondaryColor,
                  allUrls:
                      _tempVehicleRegistrationImages.isNotEmpty
                          ? _tempVehicleRegistrationImages
                          : profile.deliveryBoy?.vehicleRegistration,
                  isLoading:
                      profile.deliveryBoy ==
                      null, // Show loading when no delivery boy data
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                if (_isEditing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          textSize: 15.sp,
                          text: AppLocalizations.of(context)!.cancel,
                          onPressed: _cancelEdit,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomButton(
                          textSize: 15.sp,
                          text:
                              _isLoading
                                  ? 'Saving...'
                                  : AppLocalizations.of(context)!.saveChanges,
                          onPressed: _isLoading ? null : _saveChanges,
                          backgroundColor: AppColors.primaryColor,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      textSize: 15.sp,
                      text: AppLocalizations.of(context)!.editInformation,
                      onPressed: _toggleEdit,
                      backgroundColor: AppColors.primaryColor,
                      textColor: Colors.white,
                    ),
                  ),
                ],
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleHeader(ProfileModel profile, bool isDarkTheme) {
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
          // Bike Icon Avatar (Left)
          CircleAvatar(
            radius: 40.r,
            backgroundColor:
                isDarkTheme
                    ? Theme.of(context).colorScheme.surface
                    : AppColors.primaryColor.withValues(alpha: 0.15),
            child: Icon(
              Icons.directions_bike,
              size: 30.sp,
              color: AppColors.primaryColor,
            ),
          ),

          SizedBox(width: 16.w),

          // Vehicle Type + Verification Status (Right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Vehicle Type / Title
                CustomText(
                  text:
                      profile.deliveryBoy?.vehicleType ?? 'Vehicle Information',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                // Verification Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: (profile.deliveryBoy?.verificationStatus ==
                                'verified'
                            ? Colors.green
                            : Colors.orange)
                        .withValues(alpha: isDarkTheme ? 0.3 : 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: CustomText(
                    text:
                        profile.deliveryBoy?.verificationStatus
                            ?.toUpperCase() ??
                        'PENDING',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        profile.deliveryBoy?.verificationStatus == 'verified'
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
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditing,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        SizedBox(height: 8.h),
        if (isEditing) ...[
          CustomTextFormField(
            controller: controller,
            validator: validator,
            prefixIcon: icon,
            borderRadius: 12.0.r,
            borderColor: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.3),
            focusedBorderColor: AppColors.primaryColor,
          ),
        ] else ...[
          CustomCard(
            padding: EdgeInsets.all(10.w),
            height:
                48.h, // Match CustomTextFormField height (12+12+20+2+2 = 48)
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryColor, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomText(
                    text:
                        controller.text.isEmpty
                            ? 'Not provided'
                            : controller.text,
                    fontSize: 16.sp,
                    color:
                        controller.text.isEmpty
                            ? Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5)
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDocumentField({
    required String title,
    String? documentUrl,
    required IconData icon,
    required Color color,
    List<String>? allUrls,
    bool isLoading = false,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    // Check if there are actual documents from API (not temporary lists)
    final hasDocument = (documentUrl != null && documentUrl.isNotEmpty);
    return CustomCard(
      padding: EdgeInsets.all(10),

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
                    CustomText(
                      text: title,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    if (!isLoading) ...[
                      CustomText(
                        text:
                            hasDocument
                                ? 'Document uploaded'
                                : 'No document uploaded',
                        fontSize: 14,
                        color: hasDocument ? Colors.green : Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Show document details below the "Document uploaded" text
          if (hasDocument) ...[
            const SizedBox(height: 12),
            CustomCard(
              padding: EdgeInsets.all(10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomText(
                          text: 'Document Images:',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Handle multiple images from array
                  SizedBox(
                    height:
                        150.h, // Fixed height for horizontal ListView (150 + 20 for margins)
                    child: _buildMultipleImages(
                      _getCombinedDocumentUrls(title, allUrls),
                      isDarkTheme,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              // Only show upload option when editing
              if (_isEditing) ...[
                CustomButton(
                  textSize: 15.sp,
                  text:
                      hasDocument
                          ? 'Upload New'
                          : AppLocalizations.of(context)!.uploadDocument,
                  onPressed: () {
                    final documentType =
                        title.toLowerCase().contains('license')
                            ? 'driver_license'
                            : 'vehicle_registration';
                    _pickAndUploadDocument(documentType);
                  },
                  backgroundColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleImages(List<String> imageUrls, bool isDarkTheme) {
    // Filter out any empty or null URLs
    final List<String> validUrls =
        imageUrls.where((url) => url.isNotEmpty).toList();

    if (validUrls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: CustomText(
          text: AppLocalizations.of(context)!.noImagesAvailable,
          fontSize: 14,
          color: Colors.red,
          textAlign: TextAlign.center,
        ),
      );
    }

    // Show all images in a horizontally scrollable ListView
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      itemCount: validUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = validUrls[index];
        return Container(
          margin: EdgeInsets.only(right: 12),
          width: 100.h,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _viewDocument(imageUrl, 'Document Image ${index + 1}');
                },
                child: Container(
                  width: 100.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        _isLocalFile(imageUrl)
                            ? Image.file(
                              File(imageUrl),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                );
                              },
                            )
                            : Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ),
              // Delete button positioned at top-right, overlaid on the image (only visible when editing)
              if (_isEditing) ...[
                Positioned(
                  top: 8.h,
                  right: 10.w,
                  child: GestureDetector(
                    onTap: () {
                      _removeSpecificImage(imageUrl, index);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],

              // Image number indicator at bottom-right
            ],
          ),
        );
      },
    );
  }

}
