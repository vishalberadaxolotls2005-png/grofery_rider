import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/colors.dart';
import '../../config/theme_bloc.dart';
import '../../utils/widgets/custom_text.dart';


class CustomAppBarWithoutNavbar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onRefreshPressed;
  final bool showRefreshButton;
  final bool showThemeToggle;
  final List<Widget>? additionalActions;

  const CustomAppBarWithoutNavbar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.onRefreshPressed,
    this.showRefreshButton = true,
    this.showThemeToggle = true,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkTheme = themeState.currentTheme == 'dark';
        return AppBar(
          backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : AppColors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDarkTheme ? AppColors.backgroundColor : AppColors.darkBackgroundColor,
            ),
            onPressed: onBackPressed ?? () {
              context.pop(context);
              // Always navigate to Feed tab (index 0) instead of just going back
              // context.go('/feed');
            },
          ),
          title:   CustomText(
            text: title,

              color: isDarkTheme ? AppColors.backgroundColor : AppColors.darkBackgroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,

          ),
          centerTitle: true,
          actions: [
            // Additional actions if provided
            if (additionalActions != null) ...additionalActions!,

            // // Refresh button
            // if (showRefreshButton)
            //   IconButton(
            //     icon: Icon(Icons.refresh, color: theme.colorScheme.onSurface),
            //     onPressed: onRefreshPressed,
            //   ),
            //
            // // Theme toggle button
            // if (showThemeToggle)
            //   IconButton(
            //     icon: Icon(
            //       theme.brightness == Brightness.dark
            //         ? Icons.light_mode
            //         : Icons.dark_mode,
            //       color: theme.colorScheme.onSurface,
            //     ),
            //     onPressed: () {
            //       context.read<ThemeBloc>().add(ToggleTheme());
            //     },
            //   ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
