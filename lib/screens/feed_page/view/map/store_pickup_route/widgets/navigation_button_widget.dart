import 'package:flutter/material.dart';
import '../../../../../../config/colors.dart';

class NavigationButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const NavigationButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.navigation),
    );
  }
}
