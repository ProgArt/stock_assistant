import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

class StockApi {
  static const String _baseUrl = 'https://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData';
  //'https://vip.stock.finance.sina.com.cn/quotes_service/api/json_v2.php/Market_Center.getHQNodeData';
  static const String _indexUrl = 'https://hq.sinajs.cn/list=';
  static const String _searchUrl = 'https://suggest3.sinajs.cn/suggest/type=11,12,13,14,15&key=';

  // 市场指数代码映射
  static const Map<String, String> _indexCodes = {
    '上证指数': 'sh000001',
    '深证成指': 'sz399001',
    '创业板指': 'sz399006',
    '科创综指': 'sh000680',
    // '恒生指数': 'hkHSI',
    // '科创50': 'sh000688',
    // '沪深300': 'sh000300',
    // '中证500': 'sh000905',
    // '上证50': 'sh000016',
    // '恒生科技': 'hkHSTECH',
    // '道琼斯': 'int_dji',
    // '纳斯达克': 'int_nasdaq',
    // '标普500': 'int_sp500',
  };

  // 获取指数代码的公共方法
  static String getIndexCode(String name) {
    return _indexCodes[name] ?? '';
  }

  // 获取最新价的公共方法
  static double getNewPrice({double left = 0, double curr = 0}) {

    if (curr == 0) {
      return left;
    }
    return curr;
  }

  // 获取差价的公共方法
  static double getChangePrice({double left = 0, double curr = 0}) {

    if (curr == 0) {
      return 0;
    }
    return (curr - left);
  }

  // 获取涨幅的公共方法
  static double getChangePercent({double left = 0, double curr = 0}) {

    if (curr == 0 || left == 0) {
      return 0;
    }
    return (curr - left) / left * 100;
  }

  static Future<List<Stock>> getTopStocks({
    String node = 'hs_a',
    String sort = 'changepercent',
    int asc = 0,
    int num = 40,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?page=1&num=$num&sort=$sort&asc=$asc&node=$node&symbol=&_s_r_a=sort'),
        //page=1&num=40&sort=changepercent&asc=0&node=hs_a&symbol=&_s_r_a=sort
        headers: {
          'Referer': 'https://vip.stock.finance.sina.com.cn/mkt/', 
          'Host': 'vip.stock.finance.sina.com.cn',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Stock.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stocks');
      }
    } catch (e) {
      throw Exception('Failed to load stocks: $e');
    }
  }

  static Future<Map<String, dynamic>> getMarketIndex(String name) async {
    try {
      final code = _indexCodes[name];
      if (code == null) {
        throw Exception('Invalid market index name');
      }

      final response = await http.get(
        Uri.parse('$_indexUrl$code'),
        headers: {
          'Referer': 'https://finance.sina.com.cn', 
          'Host': 'hq.sinajs.cn',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
        },
      );

      if (response.statusCode == 200) {
        final String data = response.body;
        final List<String> parts = data.split('"')[1].split(',');
        
        return {
          'name': name,
          'current': getNewPrice(left: double.parse(parts[2]), curr: double.parse(parts[3])),   //double.parse(parts[1]),
          'change': getChangePrice(left: double.parse(parts[2]), curr: double.parse(parts[3])),   //double.parse(parts[1]) - double.parse(parts[2]),
          'changePercent': getChangePercent(left: double.parse(parts[2]), curr: double.parse(parts[3])),   //double.parse(parts[3]) / double.parse(parts[2]) * 100,
          'volume': double.parse(parts[8]),
          'amount': double.parse(parts[9]),
        };
      } else {
        throw Exception('Failed to load market index');
      }
    } catch (e) {
      throw Exception('Failed to load market index: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllMarketIndices() async {
    try {
      final indices = await Future.wait(
        _indexCodes.keys.map((name) => getMarketIndex(name)),
      );
      return indices;
    } catch (e) {
      throw Exception('Failed to load market indices: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchStocks(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$_searchUrl$keyword'),
         headers: {
          'Referer': 'https://finance.sina.com.cn', 
          'Host': 'suggest3.sinajs.cn',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'
        },
      );

      if (response.statusCode == 200) {
        final String data = response.body;
        final String jsonStr = data.split('"')[1];
        final List<String> items = jsonStr.split(';');
        
        return items.map((item) {
          final parts = item.split(',');
          return {
            'code': parts[0],
            'name': parts[1],
            'type': parts[2],
          };
        }).toList();
      } else {
        throw Exception('Failed to search stocks');
      }
    } catch (e) {
      throw Exception('Failed to search stocks: $e');
    }
  }
} 