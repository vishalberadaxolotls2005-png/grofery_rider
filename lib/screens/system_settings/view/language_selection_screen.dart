// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../config/colors.dart';
import '../../../config/localization_service.dart';
import '../../../utils/widgets/custom_appbar_without_navbar.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/toast_message.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBarWithoutNavbar(
        title: 'Language Selection',
        showRefreshButton: false,
        showThemeToggle: false,
      ),
      body: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          final currentLanguage = localizationService.currentLanguageCode;
          final availableLanguages = localizationService.getAvailableLanguages();

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: availableLanguages.length,
            itemBuilder: (context, index) {
              final language = availableLanguages[index];
              final isSelected = language['code'] == currentLanguage;

              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                elevation: isSelected ? 4 : 1,
                color: isSelected 
                    ? AppColors.primaryColor.withValues(alpha: 0.1)
                    : Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: isSelected 
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    width: 2.w,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  leading: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primaryColor
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: CustomText(
                        text: language['code'].toUpperCase(),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  title: CustomText(
                    text: language['name'] as String,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? AppColors.primaryColor
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  subtitle: CustomText(
                    text: language['nameEnglish'] as String,
                    fontSize: 14,
                    color: isSelected 
                        ? AppColors.primaryColor.withValues(alpha: 0.7)
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 24.sp,
                        )
                      : null,
                  onTap: () async {
                    if (!isSelected) {
                      await localizationService.changeLanguage(language['code'] as String);
                      
                      if (context.mounted) {
                        ToastManager.show(
                          context: context,
                          message: 'Language changed to ${language['name']}',
                          type: ToastType.success,
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 
