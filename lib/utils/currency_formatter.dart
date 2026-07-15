import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/system_settings/bloc/system_settings_bloc.dart';

class CurrencyFormatter {
  static String formatAmount(BuildContext context, dynamic amount) {
    final systemSettingsBloc = context.read<SystemSettingsBloc>();

    final currencySymbol = systemSettingsBloc.currencySymbol;

    if (amount == null || amount == '') {
      return '$currencySymbol 0';
    }

    String amountStr = amount.toString();

    amountStr = amountStr.replaceAll(RegExp(r'[₹$€£¥]'), '').trim();

    try {
      double? numericAmount = double.tryParse(amountStr);
      if (numericAmount != null) {
        if (numericAmount == numericAmount.toInt()) {
          return '$currencySymbol${numericAmount.toInt()}';
        } else {
          return '$currencySymbol${numericAmount.toStringAsFixed(2)}';
        }
      }
    } catch (e) {
      //
    }

    return '$currencySymbol$amountStr';
  }

  static String formatAmountWithSymbol(String currencySymbol, dynamic amount) {
    if (amount == null || amount == '') {
      return '$currencySymbol 0';
    }

    String amountStr = amount.toString();

    amountStr = amountStr.replaceAll(RegExp(r'[₹$€£¥]'), '').trim();

    try {
      double? numericAmount = double.tryParse(amountStr);
      if (numericAmount != null) {
        if (numericAmount == numericAmount.toInt()) {
          return '$currencySymbol${numericAmount.toInt()}';
        } else {
          return '$currencySymbol${numericAmount.toStringAsFixed(2)}';
        }
      }
    } catch (e) {
      //
    }

    return '$currencySymbol$amountStr';
  }
}
