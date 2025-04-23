import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _languageKey = 'language';
  static const Locale _defaultLocale = Locale('zh');

  static final Map<String, Locale> _supportedLocales = {
    'zh': const Locale('zh'), // 简体中文
    'zh_Hant': const Locale('zh', 'Hant'), // 繁体中文
    'en': const Locale('en'), // 英文
  };

  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'zh';
    return _supportedLocales[languageCode] ?? _defaultLocale;
  }

  static Future<void> setLocale(String languageCode) async {
    if (!_supportedLocales.containsKey(languageCode)) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static List<Locale> get supportedLocales => _supportedLocales.values.toList();

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return '简体中文';
      case 'zh_Hant':
        return '繁體中文';
      case 'en':
        return 'English';
      default:
        return '简体中文';
    }
  }
} 