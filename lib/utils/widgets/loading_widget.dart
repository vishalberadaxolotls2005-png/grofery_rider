import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class LoadingWidget extends StatelessWidget {
  final double size;
  final Color? leftDotColor;
  final Color? rightDotColor;
  final EdgeInsetsGeometry? padding;

  const LoadingWidget({
    super.key,
    this.size = 250,
    this.leftDotColor,
    this.rightDotColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Lottie.asset(
        'assets/lottie/Food Courier.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );
  }
}
