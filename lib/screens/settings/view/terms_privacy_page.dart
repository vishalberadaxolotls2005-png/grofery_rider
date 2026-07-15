import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';


import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

import 'package:grofery_rider/config/colors.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';

import 'package:grofery_rider/utils/widgets/loading_widget.dart';

import '../../system_settings/bloc/system_settings_bloc.dart';
import '../../system_settings/bloc/system_settings_event.dart';
import '../../system_settings/bloc/system_settings_state.dart';
import '../../system_settings/repo/system_settings_repo.dart';

class TermsPrivacyPage extends StatelessWidget {
  final bool isTerms;
  
  const TermsPrivacyPage({
    super.key,
    required this.isTerms,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SystemSettingsBloc(SystemSettingsRepo())..add(FetchDeliveryBoySettings()),
      child: BlocBuilder<SystemSettingsBloc, SystemSettingsState>(
        builder: (context, state) {
          return CustomScaffold(
            appBar: CustomAppBarWithoutNavbar(
              title: isTerms 
                  ? AppLocalizations.of(context)!.termsOfService
                  : AppLocalizations.of(context)!.privacyPolicy,
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SystemSettingsState state) {
    if (state is SystemSettingsLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (state is SystemSettingsError) {
      return ErrorStateWidget(
        onRetry: (){
          context.read<SystemSettingsBloc>().add(FetchDeliveryBoySettings());
        }
      );
    }

    if (state is SystemSettingsLoaded) {
      final settings = state.settings;
      


      final content = isTerms 
          ? settings.termsCondition 
          : settings.privacyPolicy;

      if (content == null || content.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64.sp,
                color: AppColors.primaryColor.withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: 'No content available',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () {
                  context.read<SystemSettingsBloc>().add(FetchDeliveryBoySettings());
                },
                child: const Text('Tap to Refresh'),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            
            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Html(
                data: content,
                style: {
                  "body": Style(
                    fontSize: FontSize(16.sp),
                    lineHeight: LineHeight(1.6),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  "h1": Style(
                    fontSize: FontSize(24.sp),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                    margin: Margins.only(bottom: 16.h),
                  ),
                  "h2": Style(
                    fontSize: FontSize(20.sp),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                    margin: Margins.only(top: 24.h, bottom: 12.h),
                  ),
                  "h3": Style(
                    fontSize: FontSize(18.sp),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    margin: Margins.only(top: 20.h, bottom: 10.h),
                  ),
                  "p": Style(
                    fontSize: FontSize(16.sp),
                    margin: Margins.only(bottom: 12.h),
                    lineHeight: LineHeight(1.6),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  "ul": Style(
                    margin: Margins.only(bottom: 16.h, left: 16.w),
                  ),
                  "li": Style(
                    fontSize: FontSize(16.sp),
                    margin: Margins.only(bottom: 8.h),
                    lineHeight: LineHeight(1.6),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  "strong": Style(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  "a": Style(
                    color: AppColors.primaryColor,
                    textDecoration: TextDecoration.underline,
                  ),
                },
              ),
            ),
            
            SizedBox(height: 24.h),
            

          ],
        ),
      );
    }

    return const Center(
      child: LoadingWidget(),
    );
  }
} 
