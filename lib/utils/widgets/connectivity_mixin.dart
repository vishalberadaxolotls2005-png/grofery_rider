import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import '../../config/app_images.dart';
import 'custom_button.dart';
import '../../l10n/app_localizations.dart';

mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  late Stream<List<ConnectivityResult>> _connectivityStream;
  List<ConnectivityResult> _connectivityResults = [];
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (mounted) {
        setState(() {
          _connectivityResults = results;
          _isConnected = results.any((result) => result != ConnectivityResult.none);
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  bool get isConnected => _isConnected;

  Widget buildWithConnectivity({
    required Widget child,
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _connectivityResults = snapshot.data!;
          _isConnected = _connectivityResults.any((result) => result != ConnectivityResult.none);
        }

        if (!_isConnected) {
          return _buildNoInternetScreen(
            customMessage: customMessage,
            onRetry: onRetry,
          );
        }

        return child;
      },
    );
  }

  Widget _buildNoInternetScreen({
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // No internet icon
              SizedBox(
                height: 200.h,
                width: 200.w,

                child: Image.asset(AppImages.noInternet)
              ),
              SizedBox(height: 32.h),
              
              // Title
              CustomText(
              text:   AppLocalizations.of(context)!.noInternetConnection,
             fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,

              ),
              SizedBox(height: 16.h),
              
              // Message
              CustomText(
              text:   customMessage ??
                AppLocalizations.of(context)!.checkInternetConnection,

                textAlign: TextAlign.center,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,

              ),
              SizedBox(height: 32.h),
              
              // Retry button
              CustomButton(
                textSize: 15.sp,
                text: AppLocalizations.of(context)!.tryAgain,
                onPressed: () {
                  if (onRetry != null) {
                    onRetry();
                  } else {
                    _checkInitialConnectivity();
                  }
                },
                backgroundColor: Theme.of(context).primaryColor,
                textColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
