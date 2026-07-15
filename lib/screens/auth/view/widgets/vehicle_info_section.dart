import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../../router/app_routes.dart';
import '../../../../utils/widgets/custom_textfield.dart';
import '../../../../utils/widgets/custom_text.dart';

class VehicleInfoSection extends StatelessWidget {
  final TextEditingController vehicleTypeController;
  final TextEditingController deliveryLicenseNumberController;
  final TextEditingController deliveryZoneController;
  final int? selectedDeliveryZoneId;

  const VehicleInfoSection({
    super.key,
    required this.vehicleTypeController,
    required this.deliveryLicenseNumberController,
    required this.deliveryZoneController,
    this.selectedDeliveryZoneId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.vehicleInformation,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
         SizedBox(height: 16.h),
        // Vehicle Type
        CustomTextFormField(
          controller: vehicleTypeController,
          labelText: AppLocalizations.of(context)!.vehicleType,
          hintText: AppLocalizations.of(context)!.enterYourVehicleType,
          prefixIcon: Icons.electric_bike,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterYourVehicleType;
            }
            return null;
          },
        ),
         SizedBox(height: 16.h),
        // Driver License Number
        CustomTextFormField(
          controller: deliveryLicenseNumberController,
          labelText: AppLocalizations.of(context)!.driverLicenseNumber,
          hintText: AppLocalizations.of(context)!.enterYourLicenseNumber,
          prefixIcon: Icons.card_membership,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterYourLicenseNumber;
            }
            return null;
          },
        ),
         SizedBox(height: 16.h),
        // Delivery Zone
        CustomTextFormField(
          readOnly: true,
          controller: deliveryZoneController,
          labelText: AppLocalizations.of(context)!.deliveryZone,
          hintText: AppLocalizations.of(context)!.selectYourDeliveryZone,
          prefixIcon: Icons.location_on,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onTap: () async {
            await GoRouter.of(context).push(AppRoutes.deliveryZone);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseSelectYourDeliveryZone;
            }
            return null;
          },
        ),
      ],
    );
  }
} 
