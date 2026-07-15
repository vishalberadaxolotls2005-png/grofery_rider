import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:grofery_rider/screens/system_settings/bloc/system_settings_bloc.dart';
import 'package:grofery_rider/screens/system_settings/bloc/system_settings_event.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/custom_textfield.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';
import 'package:grofery_rider/utils/widgets/toast_message.dart';
import '../../../../config/colors.dart';
import '../../../../utils/widgets/custom_card.dart';
import '../../bloc/profile_bloc/profile_bloc.dart';
import '../../bloc/profile_bloc/profile_event.dart';
import '../../bloc/profile_bloc/profile_state.dart';

import '../../model/profile_model.dart';

import 'package:grofery_rider/l10n/app_localizations.dart';

class ContactInfoPage extends StatefulWidget {
  const ContactInfoPage({super.key});

  @override
  State<ContactInfoPage> createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  // Country field data
  String _countryName = '';

  @override
  void initState() {
    super.initState();
    // Load profile data
    context.read<ProfileBloc>().add(const LoadProfile());
    context.read<SystemSettingsBloc>().add(FetchSystemSettings());
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _populateFields(ProfileModel profile) {
    if (profile.user != null) {
      _mobileController.text = profile.user!.mobile ?? '';
      _emailController.text = profile.user!.email ?? '';
      _countryController.text = profile.user!.country ?? '';
      _countryName = profile.user!.country ?? '';
      // Set default country if none is set
      if (_countryName.isEmpty) {
        _countryName = 'India';
      }
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
      // UpdateProfile now only needs the contact info fields we're updating
      context.read<ProfileBloc>().add(
        UpdateProfile(
          // Personal info fields are not needed for contact info updates
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          country: _countryName.trim(),
        ),
      );

      // The ProfileBloc will emit ProfileUpdating -> ProfileUpdated states
      // We'll handle these in the BlocConsumer listener
    }
  }

  void _cancelEdit() {
    // Reload profile data to reset fields
    context.read<ProfileBloc>().add(const LoadProfile());
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.contactInformation,
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
            // Contact info has been updated successfully
            setState(() {
              _isLoading = false;
              _isEditing = false;
            });

            // Populate fields with updated data
            _populateFields(state.profile);

            ToastManager.show(
              context: context,
              message: AppLocalizations.of(context)!.contactInformationUpdated,
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
          // Show content directly, handle loading states gracefully
          if (state is ProfileLoaded) {
            return _buildContactInfoContent(state.profile);
          }

          if (state is ProfileUpdated) {
            // Show the updated profile content
            return _buildContactInfoContent(state.profile);
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
          return _buildContactInfoContent(
            ProfileModel(),
          ); // Empty profile for initial state
        },
      ),
    );
  }

  Widget _buildContactInfoContent(ProfileModel profile) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Check if profile data is available
    final hasProfileData = profile.user != null || profile.deliveryBoy != null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Header
          _buildContactHeader(profile, isDarkTheme),
          SizedBox(height: 24.h),

          // Contact Information Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(AppLocalizations.of(context)!.phoneAndEmail),
                SizedBox(height: 16.h),

                // Mobile Number
                _buildInfoField(
                  label: AppLocalizations.of(context)!.mobileNumber,
                  controller: _mobileController,
                  icon: Icons.phone_outlined,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.mobileNumberRequired;
                    }
                    if (value.length < 10) {
                      return AppLocalizations.of(
                        context,
                      )!.mobileNumberMinLength;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Email
                _buildInfoField(
                  label: AppLocalizations.of(context)!.emailAddress,
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.emailRequired;
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return AppLocalizations.of(context)!.validEmailRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                _buildSectionTitle(
                  AppLocalizations.of(context)!.locationInformation,
                ),
                SizedBox(height: 16.h),

                // Country
                _buildInfoField(
                  label: AppLocalizations.of(context)!.country,
                  controller: _countryController,
                  icon: Icons.public_outlined,
                  isEditing: _isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.countryRequired;
                    }
                    return null;
                  },
                  isCountryField: true,
                  onCountryTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      countryListTheme: CountryListThemeData(
                        flagSize: 25,
                        backgroundColor:
                            Theme.of(context).colorScheme.sameColorChange,
                        textStyle: TextStyle(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.oppColorChange,
                        ),
                        bottomSheetHeight: 500,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.w),
                          topRight: Radius.circular(20.w),
                        ),
                        inputDecoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.search,
                          hintText: AppLocalizations.of(context)!.search,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(
                                0xFF8C98A8,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                      onSelect: (Country country) {
                        setState(() {
                          _countryController.text = country.name;
                          _countryName = country.name;
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 24.h),

                // Additional Contact Info
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
                      onPressed: hasProfileData ? _toggleEdit : null,
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

  Widget _buildContactHeader(ProfileModel profile, bool isDarkTheme) {
    final hasProfileData = profile.user != null;

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
          // Icon Avatar (Left)
          CircleAvatar(
            radius: 40.r,
            backgroundColor:
                isDarkTheme
                    ? Theme.of(context).colorScheme.surface
                    : AppColors.primaryColor.withValues(alpha: 0.15),
            child: Icon(
              Icons.contact_phone,
              size: 30.sp,
              color: AppColors.primaryColor,
            ),
          ),

          SizedBox(width: 16.w), // Horizontal spacing
          // Name + Status Badge (Right – takes remaining space)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Full Name / Title
                CustomText(
                  text:
                      hasProfileData
                          ? (profile.deliveryBoy?.fullName ??
                              profile.user!.name ??
                              AppLocalizations.of(context)!.contactInformation)
                          : AppLocalizations.of(context)!.loading,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        hasProfileData
                            ? (profile.deliveryBoy?.status == 'active'
                                    ? Colors.green
                                    : (profile.deliveryBoy?.status != null
                                        ? Colors.orange
                                        : Colors.grey))
                                .withValues(alpha: isDarkTheme ? 0.3 : 0.15)
                            : Colors.grey.withValues(
                              alpha: isDarkTheme ? 0.3 : 0.15,
                            ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: CustomText(
                    text:
                        hasProfileData
                            ? (profile.deliveryBoy?.status == 'active'
                                ? 'ACTIVE'
                                : profile.deliveryBoy?.status != null
                                ? 'INACTIVE'
                                : 'UNKNOWN')
                            : 'LOADING',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        hasProfileData
                            ? (profile.deliveryBoy?.status == 'active'
                                ? Colors.green[700]
                                : (profile.deliveryBoy?.status != null
                                    ? Colors.orange[700]
                                    : Colors.grey[700]))
                            : Colors.grey[700],
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isCountryField = false,
    VoidCallback? onCountryTap,
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
          if (isCountryField)
            CustomTextFormField(
              controller: controller,
              keyboardType: keyboardType ?? TextInputType.text,
              validator: validator,
              prefixIcon: icon,
              borderRadius: 12.0.r,
              borderColor: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              focusedBorderColor: AppColors.primaryColor,
              onTap: onCountryTap,
              readOnly: true,
              hintText: AppLocalizations.of(context)!.pleaseSelectACountry,
            )
          else
            CustomTextFormField(
              controller: controller,
              keyboardType: keyboardType ?? TextInputType.text,
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
}
