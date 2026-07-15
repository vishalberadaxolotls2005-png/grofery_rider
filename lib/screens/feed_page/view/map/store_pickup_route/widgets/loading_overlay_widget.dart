import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/widgets/custom_text.dart';

class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CupertinoActivityIndicator(),
            SizedBox(height: 16.h),
            const CustomText(
              text: 'Getting your location...',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 8.h),
            const CustomText(
              text: 'Please ensure location permissions are enabled',
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
