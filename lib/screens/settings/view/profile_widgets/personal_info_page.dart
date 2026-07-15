import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/screens/system_settings/bloc/system_settings_bloc.dart';
import 'package:grofery_rider/screens/system_settings/bloc/system_settings_event.dart';
import 'package:grofery_rider/screens/system_settings/bloc/system_settings_state.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/custom_textfield.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';
import 'package:grofery_rider/utils/widgets/toast_message.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../../config/colors.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_event.dart';
import '../../bloc/profile_bloc/profile_state.dart';
import '../../model/profile_model.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _driverLicenseNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load profile data
    context.read<ProfileBloc>().add(const LoadProfile());
    context.read<SystemSettingsBloc>().add(FetchSystemSettings());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _driverLicenseNumberController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  void _populateFields(ProfileModel profile) {
    if (profile.deliveryBoy != null) {
      _fullNameController.text = profile.deliveryBoy!.fullName ?? '';
      _addressController.text = profile.deliveryBoy!.address ?? '';
      _driverLicenseNumberController.text =
          profile.deliveryBoy!.driverLicenseNumber ?? '';
      _vehicleTypeController.text = profile.deliveryBoy!.vehicleType ?? '';
    }

    // Don't call setState here - let the parent handle it
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
      context.read<ProfileBloc>().add(
        UpdateProfile(
          fullName: _fullNameController.text.trim(),
          address: _addressController.text.trim(),
          driverLicenseNumber: _driverLicenseNumberController.text.trim(),
          vehicleType: _vehicleTypeController.text.trim(),
          // Contact info fields are not needed for personal info updates
        ),
      );
    }
  }

  void _cancelEdit() {
    // Reload profile data to reset fields
    context.read<ProfileBloc>().add(const LoadProfile());
    setState(() {
      _isEditing = false;
    });
  }

  void _editProfilePicture() async {
    try {
      final bool isDemo = context.read<SystemSettingsBloc>().isDemo;
      if (isDemo) {
        ToastManager.show(
          context: context,
          message: context.read<SystemSettingsBloc>().demoMessage,
          type: ToastType.info,
        );
        return;
      }
      // Pick image from gallery or camera
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;

        // Show image preview dialog
        _showImagePreviewDialog(file, fileName);
      }
    } catch (e) {
      if (!mounted) return;
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.failedToPickImage(e.toString()),
        type: ToastType.error,
      );
    }
  }

  void _showImagePreviewDialog(File imageFile, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: CustomText(
            text: AppLocalizations.of(context)!.profilePicturePreview,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image preview
              Container(
                width: 200.w,
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    width: 2.w,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.r),
                  child: Image.file(imageFile, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: AppLocalizations.of(context)!.file(fileName),
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: AppLocalizations.of(context)!.useImageAsProfilePicture,
                fontSize: 14.sp,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: CustomText(
                text: AppLocalizations.of(context)!.cancel,
                color: Colors.grey[600],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _uploadProfilePicture(imageFile);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: CustomText(
                text: AppLocalizations.of(context)!.useThisImage,

                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  void _uploadProfilePicture(File imageFile) async {
    context.read<ProfileBloc>().add(
      UpdateProfile(profileImageFile: imageFile.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.personalInformation,
        showRefreshButton: false,
        showThemeToggle: false,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _populateFields(state.profile);
          } else if (state is ProfileUpdating) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is ProfileUpdated) {
            _populateFields(state.profile);
            setState(() {
              _isEditing = false;
              _isLoading = false;
            });
            ToastManager.show(
              context: context,
              message: state.message,
              type: ToastType.success,
            );
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
          return BlocBuilder<SystemSettingsBloc, SystemSettingsState>(
            builder: (context, settingState) {
              // Show content directly, handle loading states gracefully
              if (state is ProfileLoaded || state is ProfileUpdated) {
                final profile =
                    state is ProfileLoaded
                        ? state.profile
                        : (state as ProfileUpdated).profile;

                return _buildPersonalInfoContent(profile);
              }

              if (state is ProfileError) {
                return ErrorStateWidget(
                  onRetry: () {
                    context.read<ProfileBloc>().add(const LoadProfile());
                  },
                );
              }

              // For ProfileLoading or ProfileUpdating, show content with loading indicator on buttons
              if (state is ProfileLoading) {
                // Show content but with loading state
                return _buildPersonalInfoContent(
                  ProfileModel(),
                ); // Empty profile for initial state
              }

              // Default case - show content
              return _buildPersonalInfoContent(ProfileModel());
            },
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoContent(ProfileModel profile) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final bool isDemo = context.read<SystemSettingsBloc>().isDemo;
    // Check if profile data is available
    final hasProfileData = profile.deliveryBoy != null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(profile, isDarkTheme),
          SizedBox(height: 24.h),

          // Personal Information Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  AppLocalizations.of(context)!.personalDetails,
                ),
                SizedBox(height: 16.h),

                // Full Name
                _buildInfoField(
                  label: AppLocalizations.of(context)!.fullName,
                  controller: _fullNameController,
                  icon: Icons.person_outline,
                  isEditing: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.fullNameRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Address
                _buildInfoField(
                  label: AppLocalizations.of(context)!.address,
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  isEditing: _isEditing,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.addressRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                _buildSectionTitle(
                  AppLocalizations.of(context)!.vehicleInformation,
                ),
                SizedBox(height: 16.h),

                // Driver License Number
                _buildInfoField(
                  label: AppLocalizations.of(context)!.driverLicenseNumber,
                  controller: _driverLicenseNumberController,
                  icon: Icons.drive_file_rename_outline,
                  isEditing: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(
                        context,
                      )!.driverLicenseRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Vehicle Type
                _buildInfoField(
                  label: AppLocalizations.of(context)!.vehicleType,
                  controller: _vehicleTypeController,
                  icon: Icons.directions_car_outlined,
                  isEditing: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.vehicleTypeRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                if (_isEditing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppLocalizations.of(context)!.cancel,
                          onPressed: _cancelEdit,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomButton(
                          text:
                              _isLoading
                                  ? AppLocalizations.of(context)!.saving
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
                      text:
                          hasProfileData
                              ? AppLocalizations.of(context)!.editInformation
                              : AppLocalizations.of(context)!.loading,
                      onPressed: !isDemo && hasProfileData ? _toggleEdit : null,
                      backgroundColor: AppColors.primaryColor,
                      textColor: Colors.white,
                    ),
                  ),
                ],
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileModel profile, bool isDarkTheme) {
    final hasProfileData = profile.deliveryBoy != null;
    final profilePictureUrl = profile.user?.profileImage;
    final bool isDemo = context.read<SystemSettingsBloc>().isDemo;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Picture with Edit Button (Left)
          Stack(
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor:
                    isDarkTheme
                        ? Theme.of(context).colorScheme.surface
                        : AppColors.primaryColor.withValues(alpha: 0.15),
                backgroundImage:
                    profilePictureUrl != null && profilePictureUrl.isNotEmpty
                        ? NetworkImage(profilePictureUrl)
                        : null,
                child:
                    profilePictureUrl != null && profilePictureUrl.isNotEmpty
                        ? null
                        : Icon(
                          Icons.person,
                          size: 30.sp,
                          color: AppColors.primaryColor,
                        ),
              ),
              // Edit Button Overlay
              if (_isEditing && !isDemo)
                Positioned(
                  bottom: 4.h,
                  right: 4.w,
                  child: GestureDetector(
                    onTap: _editProfilePicture,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isDarkTheme
                                  ? AppColors.cardDarkColor
                                  : Colors.white,
                          width: 3.w,
                        ),
                      ),
                      child: Icon(Icons.edit, size: 10.sp, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 20.w),
          // Name + Verification Badge (Right side)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Full Name
                CustomText(
                  text:
                      hasProfileData
                          ? (profile.deliveryBoy!.fullName ??
                              AppLocalizations.of(context)!.deliveryPartner)
                          : AppLocalizations.of(context)!.loading,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  maxLines: 1,
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
                    color:
                        hasProfileData
                            ? (profile.deliveryBoy!.verificationStatus ==
                                        'verified'
                                    ? Colors.green
                                    : Colors.orange)
                                .withValues(alpha: isDarkTheme ? 0.3 : 0.15)
                            : Colors.grey.withValues(
                              alpha: isDarkTheme ? 0.3 : 0.15,
                            ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: CustomText(
                    text:
                        hasProfileData
                            ? (profile.deliveryBoy!.verificationStatus
                                    ?.toUpperCase() ??
                                AppLocalizations.of(
                                  context,
                                )!.pending.toUpperCase())
                            : AppLocalizations.of(
                              context,
                            )!.loading.toUpperCase(),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        hasProfileData
                            ? (profile.deliveryBoy!.verificationStatus ==
                                    'verified'
                                ? (isDarkTheme
                                    ? Colors.green[300]
                                    : Colors.green[700])
                                : (isDarkTheme
                                    ? Colors.orange[300]
                                    : Colors.orange[700]))
                            : (isDarkTheme
                                ? Colors.grey[400]
                                : Colors.grey[700]),
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
    int maxLines = 1,
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
            maxLines: maxLines,
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
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center content vertically
              children: [
                Icon(icon, color: AppColors.primaryColor, size: 20.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomText(
                    text:
                        controller.text.isEmpty
                            ? AppLocalizations.of(context)!.notProvided
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
}
