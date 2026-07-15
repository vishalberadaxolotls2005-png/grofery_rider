import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_rider/config/app_images.dart';
import 'package:grofery_rider/utils/widgets/custom_dropdown.dart';
import 'package:grofery_rider/utils/widgets/toast_message.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../config/colors.dart';
import '../../../router/app_routes.dart';
import '../../../utils/widgets/custom_textfield.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_text.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_event.dart';
import '../bloc/auth_bloc/auth_state.dart';
import '../bloc/delivery_zone_bloc/delivery_zone_bloc.dart';
import '../bloc/delivery_zone_bloc/delivery_zone_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _addressController = TextEditingController();
  final _delievryZoneController = TextEditingController();
  final _deliveryLicenseNumberController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Phone field data
  String _countryIso2 = 'IN';
  String _countryCode = '+91';
  String _countryName = 'India';

  // File picker variables
  List<File> _driverLicenseFiles = [];
  List<File> _vehicleRegistrationFiles = [];
  List<String> _driverLicenseFileNames = [];
  List<String> _vehicleRegistrationFileNames = [];
  int? _selectedDeliveryZoneId;

  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _countryIso2 = 'IN';
    _countryCode = '+91';
    _countryName = 'India';
    _countryController.text = ' ';
  }

  // File picker method
  Future<void> _pickFile({required String type}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        ToastManager.show(
          context: context,
          message: AppLocalizations.of(context)!.noFilesSelected,
        );
        return;
      }

      setState(() {
        if (type == 'driver_license') {
          _driverLicenseFiles = result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!))
              .toList();
          _driverLicenseFileNames = result.files
              .where((file) => file.path != null)
              .map((file) => file.name)
              .toList();
        } else if (type == 'vehicle_registration') {
          _vehicleRegistrationFiles = result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!))
              .toList();
          _vehicleRegistrationFileNames = result.files
              .where((file) => file.path != null)
              .map((file) => file.name)
              .toList();
        }
      });
    } catch (e) {
      ToastManager.show(context: context, message: 'Error picking file: $e');
    }
  }

  // Remove file method
  void _removeFile(String type, int index) {
    setState(() {
      if (type == 'driver_license') {
        _driverLicenseFiles.removeAt(index);
        _driverLicenseFileNames.removeAt(index);
      } else if (type == 'vehicle_registration') {
        _vehicleRegistrationFiles.removeAt(index);
        _vehicleRegistrationFileNames.removeAt(index);
      }
    });
  }

  String countryFlag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
  }

  String get _fullPhoneNumber {
    final phone = _phoneNumberController.text.trim();
    if (phone.isEmpty || _countryCode.isEmpty) return '';
    return '$_countryCode$phone'; // e.g., +919876543210
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow resizing when keyboard appears
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthSuccess) {
            context.pop();
            ToastManager.show(context: context, message: state.message);
          } else if (state is AuthFailure) {
            ToastManager.show(context: context, message: state.error);
          }
        },
        child: BlocListener<DeliveryZoneBloc, DeliveryZoneState>(
          listener: (context, state) {
            if (state is DeliveryZoneLoaded && state.selectedZone != null) {
              setState(() {
                _delievryZoneController.text = state.selectedZone!.name ?? "";
                _selectedDeliveryZoneId = state.selectedZone!.id;
              });
            }
          },
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.borderColor, AppColors.borderColor],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 60.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.splashLogo,
                          width: 250.w,
                          height: 200.h,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(22.r),
                          topRight: Radius.circular(22.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 10.h),
                            // Welcome text
                            Row(
                              children: [
                                CustomText(
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )!.createAccount,
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            // Name
                            CustomTextFormField(
                              controller: _nameController,
                              labelText: AppLocalizations.of(context)!.fullName,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.enterYourFullName,
                              prefixIcon: Icons.person,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseEnterYourFullName;
                                }
                                if (value.length < 2) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.nameMustBeAtLeast2Characters;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Email
                            CustomTextFormField(
                              controller: _emailController,
                              labelText: AppLocalizations.of(context)!.email,
                              hintText:
                                  AppLocalizations.of(context)!.enterYourEmail,
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseEnterYourEmail;
                                }
                                if (!RegExp(
                                  r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseEnterAValidEmail;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Phone Number with Country Selection
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CustomTextFormField(
                                    controller: _countryController,
                                    labelText:
                                        AppLocalizations.of(context)!.country,
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )!.pleaseSelectACountry,
                                    prefixIcon: Icons.location_on,
                                    readOnly: true,
                                    onTap: () {
                                      showCountryPicker(
                                        context: context,
                                        showPhoneCode: true,
                                        countryListTheme: CountryListThemeData(
                                          flagSize: 25,
                                          backgroundColor: Colors.white,
                                          textStyle: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black,
                                          ),
                                          bottomSheetHeight: 500,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20.w),
                                            topRight: Radius.circular(20.w),
                                          ),
                                          inputDecoration: InputDecoration(
                                            labelText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.search,
                                            hintText:
                                                AppLocalizations.of(
                                                  context,
                                                )!.search,
                                            prefixIcon: const Icon(
                                              Icons.search,
                                            ),
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
                                            _countryController.text =
                                                country.name;
                                            _countryIso2 = country.countryCode;
                                            _countryCode = country.phoneCode;
                                            _countryName = country.name;
                                          });
                                        },
                                      );
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value.trim() == ' ') {
                                        return AppLocalizations.of(
                                          context,
                                        )!.pleaseSelectACountry;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  flex: 3,
                                  child: CustomTextFormField(
                                    controller: _phoneNumberController,
                                    labelText:
                                        AppLocalizations.of(
                                          context,
                                        )!.phoneNumber,
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )!.enterYourPhoneNumber,
                                    prefixIcon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(
                                          context,
                                        )!.pleaseEnterYourPhoneNumber;
                                      }
                                      if (value.length < 10) {
                                        return AppLocalizations.of(
                                          context,
                                        )!.phoneNumberMustBeAtLeast10Digits;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            // Password
                            CustomTextFormField(
                              controller: _passwordController,
                              labelText: AppLocalizations.of(context)!.password,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.enterYourPassword,
                              prefixIcon: Icons.lock,
                              suffixIcon:
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                              onSuffixIconTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              obscureText: !_isPasswordVisible,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseEnterYourPassword;
                                }
                                if (value.length < 8) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.passwordMustBeAtLeast8Characters;
                                }
                                if (!RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                                ).hasMatch(value)) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.passwordMustContainUppercaseLowercaseAndNumber;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Confirm Password
                            CustomTextFormField(
                              controller: _confirmPasswordController,
                              labelText:
                                  AppLocalizations.of(context)!.confirmPassword,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.confirmYourPassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon:
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                              onSuffixIconTap: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              obscureText: !_isConfirmPasswordVisible,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseConfirmYourPassword;
                                }
                                if (value != _passwordController.text) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Address
                            CustomTextFormField(
                              controller: _addressController,
                              labelText: AppLocalizations.of(context)!.address,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.enterYourAddress,
                              prefixIcon: Icons.home,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseEnterYourAddress;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Vehicle Type
                            // CustomTextFormField(
                            //   controller: _vehicleTypeController,
                            //   labelText:
                            //       AppLocalizations.of(context)!.vehicleType,
                            //   hintText:
                            //       AppLocalizations.of(
                            //         context,
                            //       )!.enterYourVehicleType,
                            //   prefixIcon: Icons.directions_car,
                            //   keyboardType: TextInputType.name,
                            //   textInputAction: TextInputAction.next,
                            //   validator: (value) {
                            //     if (value == null || value.isEmpty) {
                            //       return AppLocalizations.of(
                            //         context,
                            //       )!.pleaseEnterYourVehicleType;
                            //     }
                            //     return null;
                            //   },
                            // ),

                            CustomDropdownFormField<String>(
                              labelText: AppLocalizations.of(context)!.vehicleType,
                              hintText: AppLocalizations.of(context)!.selectVehicleType,
                              prefixIcon: Icons.directions_car,
                              value: _selectedVehicleType,
                              items: const [
                                DropdownMenuItem(
                                  value: 'car',
                                  child: Text('Car'),
                                ),
                                DropdownMenuItem(
                                  value: 'bike',
                                  child: Text('Bike'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedVehicleType = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)!.pleaseSelectVehicleType;
                                }
                                return null;
                              },
                            ),


                            SizedBox(height: 16.h),
                            // Driver License Number
                            CustomTextFormField(
                              controller: _deliveryLicenseNumberController,
                              labelText:
                                  AppLocalizations.of(
                                    context,
                                  )!.driverLicenseNumber,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.enterYourLicenseNumber,
                              prefixIcon: Icons.credit_card,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseEnterYourLicenseNumber;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            CustomTextFormField(
                              readOnly: true,
                              controller: _delievryZoneController,
                              labelText:
                                  AppLocalizations.of(context)!.deliveryZone,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )!.selectYourDeliveryZone,
                              prefixIcon: Icons.location_on,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              onTap: () async {
                                await GoRouter.of(
                                  context,
                                ).push(AppRoutes.deliveryZone);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                    context,
                                  )!.pleaseSelectYourDeliveryZone;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )!.driverLicense,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                CustomButton(
                                  textSize: 15.sp,
                                  width: 250.w,
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )!.uploadDriverLicense,
                                  onPressed:
                                      () => _pickFile(type: 'driver_license'),
                                ),
                              ],
                            ),
                            if (_driverLicenseFiles.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      _driverLicenseFiles.length,
                                      (index) {
                                        final fileName =
                                            _driverLicenseFileNames[index]
                                                .toLowerCase();
                                        if (fileName.endsWith('.png') ||
                                            fileName.endsWith('.jpg') ||
                                            fileName.endsWith('.jpeg')) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 8.0,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: 150.w,
                                                    maxHeight: 150.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20.r,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      10.h,
                                                    ),
                                                    child: Image.file(
                                                      _driverLicenseFiles[index],
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.grey
                                                        .withValues(alpha: 0.5),
                                                    radius: 12.r,
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: 16.sp,
                                                      ),
                                                      onPressed:
                                                          () => _removeFile(
                                                            'driver_license',
                                                            index,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 16.h),
                            // Vehicle Registration File Upload
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )!.vehicleRegistration,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                CustomButton(
                                  textSize: 15.sp,
                                  width: 250.w,
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )!.uploadVehicleRegistration,
                                  onPressed:
                                      () => _pickFile(
                                        type: 'vehicle_registration',
                                      ),
                                ),
                              ],
                            ),
                            if (_vehicleRegistrationFiles.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      _vehicleRegistrationFiles.length,
                                      (index) {
                                        final fileName =
                                            _vehicleRegistrationFileNames[index]
                                                .toLowerCase();
                                        if (fileName.endsWith('.png') ||
                                            fileName.endsWith('.jpg') ||
                                            fileName.endsWith('.jpeg')) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: 8.w,
                                            ),
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: 150.w,
                                                    maxHeight: 150.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      10.h,
                                                    ),
                                                    child: Image.file(
                                                      _vehicleRegistrationFiles[index],
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  child: CircleAvatar(
                                                    backgroundColor: Colors.grey
                                                        .withValues(alpha: 0.5),
                                                    radius: 12.sp,
                                                    child: IconButton(
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                      icon: Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: 16.sp,
                                                      ),
                                                      onPressed:
                                                          () => _removeFile(
                                                            'vehicle_registration',
                                                            index,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 32.h),
                            // Submit button
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return SizedBox(
                                  width:
                                      double
                                          .infinity, // Ensure button takes full width
                                  child: CustomButton(
                                    textSize: 15.sp,
                                    text:
                                        AppLocalizations.of(
                                          context,
                                        )!.createAccount,
                                    onPressed:
                                        isLoading ? null : _handleRegister,
                                    backgroundColor: AppColors.primaryColor,
                                    textColor: Colors.white,
                                    borderRadius: 8.r,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    isLoading: isLoading,
                                    textStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text:
                                      AppLocalizations.of(
                                        context,
                                      )!.alreadyHaveAccount,
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                TextButton(
                                  onPressed: () {
                                    GoRouter.of(context).push(AppRoutes.login);
                                  },
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.login,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            // Add padding to handle keyboard overlap
                            SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final fullPhone = _fullPhoneNumber;
      log('Full phone number: $fullPhone');

      if (fullPhone.isEmpty) {
        ToastManager.show(
          context: context,
          message: AppLocalizations.of(context)!.pleaseEnterAValidPhoneNumber,
        );
        return;
      }
      if (_driverLicenseFiles.isEmpty) {
        ToastManager.show(
          context: context,
          message:
              AppLocalizations.of(
                context,
              )!.pleaseUploadAtLeastOneDriverLicenseFile,
        );
        return;
      }
      if (_vehicleRegistrationFiles.isEmpty) {
        ToastManager.show(
          context: context,
          message:
              AppLocalizations.of(
                context,
              )!.pleaseUploadAtLeastOneVehicleRegistrationFile,
        );
        return;
      }

      // --- DEBUG LOGS FOR REGISTRATION DATA ---
      debugPrint('=== REGISTRATION REQUEST DATA ===');
      debugPrint('Name: ${_nameController.text.trim()}');
      debugPrint('Email: ${_emailController.text.trim()}');
      debugPrint('Mobile: ${_phoneNumberController.text.trim()}');
      debugPrint('Full Phone Number: $_fullPhoneNumber');
      debugPrint(
        'Password: ${_passwordController.text}',
      ); // Be careful in production!
      debugPrint('Confirm Password: ${_confirmPasswordController.text}');
      debugPrint('Country: $_countryName');
      debugPrint('ISO2: $_countryIso2');
      debugPrint('Country Code: $_countryCode');
      debugPrint('Address: ${_addressController.text.trim()}');
      debugPrint('Vehicle Type: $_selectedVehicleType');
      debugPrint(
        'Driver License Number: ${_deliveryLicenseNumberController.text.trim()}',
      );
      debugPrint('Delivery Zone ID: ${_selectedDeliveryZoneId ?? 0}');

      debugPrint(
        'Driver License File: ${_driverLicenseFiles.isNotEmpty ? _driverLicenseFiles.first.path : 'null (no file selected)'}',
      );

      debugPrint(
        'Vehicle Registration File: ${_vehicleRegistrationFiles.isNotEmpty ? _vehicleRegistrationFiles.first.path : 'null (no file selected)'}',
      );

      debugPrint('Driver License Files Count: ${_driverLicenseFiles.length}');
      debugPrint(
        'Vehicle Registration Files Count: ${_vehicleRegistrationFiles.length}',
      );
      debugPrint('=====================================');

      context.read<AuthBloc>().add(
        RegisterRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          mobile: _phoneNumberController.text.trim(),
          password: _passwordController.text,
          country: _countryName,
          iso2: _countryIso2,
          countryCode: _countryCode,
          completePhoneNumber: _fullPhoneNumber,
          confirmPassword: _confirmPasswordController.text,
          driverLicenseFile:
              _driverLicenseFiles.isNotEmpty ? _driverLicenseFiles.first : null,
          vehicleRegistrationFile:
              _vehicleRegistrationFiles.isNotEmpty
                  ? _vehicleRegistrationFiles.first
                  : null,
          address: _addressController.text.trim(),
          vehicleType: _selectedVehicleType!,
          driverLicenseNumber: _deliveryLicenseNumberController.text.trim(),
          deliveryZoneId: _selectedDeliveryZoneId ?? 0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _vehicleTypeController.dispose();
    _deliveryLicenseNumberController.dispose();
    super.dispose();
  }
}
