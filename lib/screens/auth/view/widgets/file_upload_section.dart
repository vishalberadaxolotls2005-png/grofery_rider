import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import '../../../../utils/widgets/toast_message.dart';
import '../../../../utils/widgets/custom_button.dart';
import '../../../../utils/widgets/custom_text.dart';

class FileUploadSection extends StatefulWidget {
  final List<File> driverLicenseFiles;
  final List<File> vehicleRegistrationFiles;
  final List<String> driverLicenseFileNames;
  final List<String> vehicleRegistrationFileNames;
  final Function(List<File>, List<String>, String) onFilesSelected;
  final Function(String, int) onFileRemoved;

  const FileUploadSection({
    super.key,
    required this.driverLicenseFiles,
    required this.vehicleRegistrationFiles,
    required this.driverLicenseFileNames,
    required this.vehicleRegistrationFileNames,
    required this.onFilesSelected,
    required this.onFileRemoved,
  });

  @override
  State<FileUploadSection> createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  Future<void> _pickFile({required String type}) async {
    try {
      // Request storage or media permissions based on platform
      bool permissionGranted = false;
      if (Platform.isAndroid) {
        if (await Permission.storage.request().isGranted) {
          permissionGranted = true;
        } else if (await Permission.photos.request().isGranted) {
          permissionGranted = true;
        }
      } else {
        permissionGranted = true; // iOS handles permissions differently
      }

      if (!permissionGranted) {
        if (!mounted) return;
        ToastManager.show(
          context: context,
          message: AppLocalizations.of(context)!.storagePermissionDenied,
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      if (!mounted) return;

      if (result != null && result.files.isNotEmpty) {
        List<File> files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
        List<String> fileNames = result.files
            .where((file) => file.path != null)
            .map((file) => file.name)
            .toList();
        
        widget.onFilesSelected(files, fileNames, type);
      } else {

        ToastManager.show(
          context: context,
          message: AppLocalizations.of(context)!.noFilesSelected,
        );
      }
    } catch (e) {
      ToastManager.show(
        context: context,
        message: AppLocalizations.of(context)!.errorPickingFile(e),
      );
    }
  }

  Widget _buildFilePreview(List<File> files, List<String> fileNames, String type) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding:  EdgeInsets.only(top: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            files.length,
            (index) {
              final fileName = fileNames[index].toLowerCase();
              if (fileName.endsWith('.png') ||
                  fileName.endsWith('.jpg') ||
                  fileName.endsWith('.jpeg')) {
                return Padding(
                  padding:  EdgeInsets.only(right: 8.h),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        constraints:  BoxConstraints(
                          maxWidth: 150.w,
                          maxHeight: 150.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22.r),
                        ),
                        child: Padding(
                          padding:  EdgeInsets.all(10.h),
                          child: Image.file(
                            files[index],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.withValues(alpha:0.5),
                          radius: 12.r,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon:  Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 16.sp,
                            ),
                            onPressed: () => widget.onFileRemoved(type, index),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.documentUpload,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
         SizedBox(height: 16.h),
        
        // Driver License Upload
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.driverLicense,
              fontSize: 14.sp,
            ),
            CustomButton(
              text: AppLocalizations.of(context)!.uploadDriverLicense,
              onPressed: () => _pickFile(type: 'driver_license'),
            ),
            _buildFilePreview(
              widget.driverLicenseFiles,
              widget.driverLicenseFileNames,
              'driver_license',
            ),
          ],
        ),
        
         SizedBox(height: 16.h),
        
        // Vehicle Registration Upload
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.vehicleRegistration,
              fontSize: 14.sp,
            ),
            CustomButton(
              text: AppLocalizations.of(context)!.uploadVehicleRegistration,
              onPressed: () => _pickFile(type: 'vehicle_registration'),
            ),
            _buildFilePreview(
              widget.vehicleRegistrationFiles,
              widget.vehicleRegistrationFileNames,
              'vehicle_registration',
            ),
          ],
        ),
      ],
    );
  }
} 
