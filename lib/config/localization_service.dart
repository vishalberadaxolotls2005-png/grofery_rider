import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('fr'),
    Locale('ar'),
    Locale('te'),
    Locale('gu'),
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'fr': 'Français',
    'ar': 'العربية',
    'te': 'తెలుగు',
    'gu': 'ગુજરાતી',
  };

  static const Map<String, String> languageNamesEnglish = {
    'en': 'English',
    'hi': 'Hindi',
    'fr': 'French',
    'ar': 'Arabic',
    'te': 'Telugu',
    'gu': 'Gujarati',
  };

  static const List<String> rtlLanguages = ['ar'];

  Future<void> initialize() async {
    await _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
      await changeLanguage(savedLanguage);
    } catch (e) {
      await changeLanguage(_defaultLanguage);
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!supportedLocales.any(
      (locale) => locale.languageCode == languageCode,
    )) {
      return;
    }

    _currentLocale = Locale(languageCode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      //
    }

    if (rtlLanguages.contains(languageCode)) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    notifyListeners();
  }

  String get currentLanguageCode => _currentLocale.languageCode;

  bool get isRTL => rtlLanguages.contains(currentLanguageCode);

  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  String getLanguageNameEnglish(String languageCode) {
    return languageNamesEnglish[languageCode] ?? languageCode;
  }

  List<Map<String, dynamic>> getAvailableLanguages() {
    return supportedLocales.map((locale) {
      final code = locale.languageCode;
      return {
        'code': code,
        'name': languageNames[code] ?? code,
        'nameEnglish': languageNamesEnglish[code] ?? code,
        'isRTL': rtlLanguages.contains(code),
      };
    }).toList();
  }

  Future<void> resetToDefault() async {
    await changeLanguage(_defaultLanguage);
  }

  Map<String, dynamic> getCurrentLanguageInfo() {
    final code = currentLanguageCode;
    return {
      'code': code,
      'name': languageNames[code] ?? code,
      'nameEnglish': languageNamesEnglish[code] ?? code,
      'isRTL': isRTL,
    };
  }
}
