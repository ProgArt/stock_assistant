import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _favoriteStocksKey = 'favorite_stocks';
  static const String _indexRefreshIntervalKey = 'index_refresh_interval';

  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Theme mode
  static Future<bool> setThemeMode(String themeMode) async {
    final prefs = await _prefs;
    return await prefs.setString(_themeKey, themeMode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeKey);
  }

  // Language
  static Future<bool> setLanguage(String language) async {
    final prefs = await _prefs;
    return await prefs.setString(_languageKey, language);
  }

  static Future<String?> getLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_languageKey);
  }

  // Favorite stocks
  static Future<bool> addFavoriteStock(String stockCode) async {
    final prefs = await _prefs;
    final List<String> favorites = prefs.getStringList(_favoriteStocksKey) ?? [];
    if (!favorites.contains(stockCode)) {
      favorites.add(stockCode);
      return await prefs.setStringList(_favoriteStocksKey, favorites);
    }
    return true;
  }

  static Future<bool> removeFavoriteStock(String stockCode) async {
    final prefs = await _prefs;
    final List<String> favorites = prefs.getStringList(_favoriteStocksKey) ?? [];
    favorites.remove(stockCode);
    return await prefs.setStringList(_favoriteStocksKey, favorites);
  }

  static Future<List<String>> getFavoriteStocks() async {
    final prefs = await _prefs;
    return prefs.getStringList(_favoriteStocksKey) ?? [];
  }

  static Future<bool> isStockFavorite(String stockCode) async {
    final favorites = await getFavoriteStocks();
    return favorites.contains(stockCode);
  }

  // Index Refresh Interval
  static Future<void> setIndexRefreshInterval(int seconds) async {
    final prefs = await _prefs;
    await prefs.setInt(_indexRefreshIntervalKey, seconds);
  }

  static Future<int> getIndexRefreshInterval() async {
    final prefs = await _prefs;
    return prefs.getInt(_indexRefreshIntervalKey) ?? 60; // 默认60秒
  }
} 