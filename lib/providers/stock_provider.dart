import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StockProvider with ChangeNotifier {
  List<dynamic> _stocks = [];
  List<dynamic> _futures = [];
  List<dynamic> _news = [];
  bool _isLoading = false;
  String _error = '';

  List<dynamic> get stocks => _stocks;
  List<dynamic> get futures => _futures;
  List<dynamic> get news => _news;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchStocks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://hq.sinajs.cn/list=sh000001,sz399001'),
         headers: {
          'Referer': 'https://finance.sina.com.cn', 
          'Host': 'hq.sinajs.cn',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
        },
      );
      if (response.statusCode == 200) {
        _stocks = _parseStockData(response.body);
      } else {
        _error = 'Failed to load stock data';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFutures() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://hq.sinajs.cn/list=CFF_RE_IF0'),
         headers: {
          'Referer': 'https://finance.sina.com.cn', 
          'Host': 'hq.sinajs.cn',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
        },
      );
      if (response.statusCode == 200) {
        _futures = _parseFuturesData(response.body);
      } else {
        _error = 'Failed to load futures data';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('https://finance.sina.com.cn/stock/'),
         headers: {
          'Referer': 'https://finance.sina.com.cn', 
          'Host': 'hq.sinajs.cn',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
        },      
      );
      if (response.statusCode == 200) {
        _news = _parseNewsData(response.body);
      } else {
        _error = 'Failed to load news';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  List<dynamic> _parseStockData(String data) {
    // 解析股票数据
    return [];
  }

  List<dynamic> _parseFuturesData(String data) {
    // 解析期货数据
    return [];
  }

  List<dynamic> _parseNewsData(String data) {
    // 解析新闻数据
    return [];
  }
} 