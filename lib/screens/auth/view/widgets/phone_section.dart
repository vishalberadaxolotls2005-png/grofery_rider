import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../../utils/widgets/custom_text.dart';
import '../../../../utils/widgets/custom_textfield.dart';

class PhoneSection extends StatelessWidget {
  final TextEditingController countryController;
  final TextEditingController phoneNumberController;
  final String countryIso2;
  final String countryCode;
  final Function(Country) onCountrySelected;
  final Function(String) onPhoneChanged;

  const PhoneSection({
    super.key,
    required this.countryController,
    required this.phoneNumberController,
    required this.countryIso2,
    required this.countryCode,
    required this.onCountrySelected,
    required this.onPhoneChanged,
  });

  String countryFlag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.contactInformation,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
         SizedBox(height: 16.h),
        // Phone Number with Country Selection
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomTextFormField(
                controller: countryController,
                labelText: AppLocalizations.of(context)!.country,
                hintText: '',
                readOnly: true,
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: onCountrySelected,
                  );
                },
                validator: (value) {
                  if (countryCode.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseSelectACountry;
                  }
                  return null;
                },
                prefix: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 12.h),
                  child: CustomText(
                    text: '${countryFlag(countryIso2)} $countryCode',
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: CustomTextFormField(
                controller: phoneNumberController,
                labelText: AppLocalizations.of(context)!.phoneNumber,
                hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onChanged: onPhoneChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber;
                  }
                  if (value.length < 10) {
                    return AppLocalizations.of(context)!.phoneNumberMustBeAtLeast10Digits;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
