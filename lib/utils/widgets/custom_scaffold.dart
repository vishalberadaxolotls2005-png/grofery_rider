import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme_bloc.dart';

import '../../../../config/colors.dart';
class CustomScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final EdgeInsetsGeometry? padding;
  final Widget? bottomSheet;

  const CustomScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.padding,
    this.bottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkTheme = themeState.currentTheme == 'dark';
        return Scaffold(
          backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : backgroundColor,
          appBar: appBar,
          body: Container(
            color: isDarkTheme ? AppColors.darkBackgroundColor : backgroundColor,
            child: SafeArea(
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: body,
              ),
            ),
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          drawer: drawer,
          endDrawer: endDrawer,
          bottomSheet: bottomSheet,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          primary: primary,
        );
      },
    );
  }

  // Method to show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget bottomSheet,
    bool isScrollControlled = false,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    bool isDismissible = true,
    bool useSafeArea = true,
    bool isScrollControlledDefault = false,
    bool enableDragDefault = true,
    Color? backgroundColorDefault,
    double? elevationDefault,
    ShapeBorder? shapeDefault,
    Clip? clipBehaviorDefault,
  }) {
    final themeState = context.read<ThemeBloc>().state;
    final isDarkTheme = themeState.currentTheme == 'dark';

    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => bottomSheet,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? backgroundColorDefault ?? (isDarkTheme ? AppColors.darkBackgroundColor : Colors.white),
      elevation: elevation ?? elevationDefault ?? 8.0,
      shape: shape ?? shapeDefault ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: clipBehavior ?? clipBehaviorDefault ?? Clip.antiAlias,
      isDismissible: isDismissible,
      useSafeArea: useSafeArea,
    );
  }

  // Method to show persistent bottom sheet
  static PersistentBottomSheetController showPersistentBottomSheet({
    required BuildContext context,
    required Widget bottomSheet,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    bool useSafeArea = true,
    Color? backgroundColorDefault,
    double? elevationDefault,
    ShapeBorder? shapeDefault,
    Clip? clipBehaviorDefault,
  }) {
    final themeState = context.read<ThemeBloc>().state;
    final isDarkTheme = themeState.currentTheme == 'dark';

    return Scaffold.of(context).showBottomSheet(
      (context) => bottomSheet,
      backgroundColor: backgroundColor ?? backgroundColorDefault ?? (isDarkTheme ? AppColors.darkBackgroundColor : Colors.white),
      elevation: elevation ?? elevationDefault ?? 8.0,
      shape: shape ?? shapeDefault ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: clipBehavior ?? clipBehaviorDefault ?? Clip.antiAlias,
      enableDrag: enableDrag,
    );
  }

  // Simple method to show a themed bottom sheet
  static Future<T?> showThemedBottomSheet<T>({
    required BuildContext context,
    required Widget bottomSheet,
    bool isScrollControlled = false,
    bool enableDrag = true,
    bool isDismissible = true,
    bool useSafeArea = true,
    double? elevation,
    ShapeBorder? shape,
  }) {
    final themeState = context.read<ThemeBloc>().state;
    final isDarkTheme = themeState.currentTheme == 'dark';

    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => bottomSheet,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: isDarkTheme ? AppColors.darkBackgroundColor : Colors.white,
      elevation: elevation ?? 8.0,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      isDismissible: isDismissible,
      useSafeArea: useSafeArea,
    );
  }
}
