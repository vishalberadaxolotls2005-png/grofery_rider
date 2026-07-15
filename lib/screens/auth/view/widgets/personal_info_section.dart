import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../../utils/widgets/custom_textfield.dart';
import '../../../../utils/widgets/custom_text.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController addressController;

  const PersonalInfoSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.personalInformation,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
         SizedBox(height: 16.h),
        // Name
        CustomTextFormField(
          controller: nameController,
          labelText: AppLocalizations.of(context)!.fullName,
          hintText: AppLocalizations.of(context)!.enterYourFullName,
          prefixIcon: Icons.person,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterYourFullName;
            }
            if (value.length < 2) {
              return AppLocalizations.of(context)!.nameMustBeAtLeast2Characters;
            }
            return null;
          },
        ),
         SizedBox(height: 16.h),
        // Email
        CustomTextFormField(
          controller: emailController,
          labelText: AppLocalizations.of(context)!.email,
          hintText: AppLocalizations.of(context)!.enterYourEmail,
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterYourEmail;
            }
            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return AppLocalizations.of(context)!.pleaseEnterAValidEmail;
            }
            return null;
          },
        ),
         SizedBox(height: 16.h),
        // Address
        CustomTextFormField(
          controller: addressController,
          labelText: AppLocalizations.of(context)!.address,
          hintText: AppLocalizations.of(context)!.enterYourAddress,
          prefixIcon: Icons.home,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterYourAddress;
            }
            return null;
          },
        ),
      ],
    );
  }
} 
