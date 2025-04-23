import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/newsInfo.dart';

class NewsApi {
  static const String _baseUrl = 'https://zhibo.sina.com.cn/api/zhibo/feed';
  static const String _indexUrl = 'https://hq.sinajs.cn/list=';
  static const String _searchUrl = 'https://suggest3.sinajs.cn/suggest/type=11,12,13,14,15&key=';

  static const String referer_url = "http://finance.sina.com.cn/7x24/?tag=0";
  static const String cookie = "UOR=,www.sina.com.cn,; SGUID=1745137249968_93408520; SR_SEL=1_511; SINAGLOBAL=39.187.70.10_1745138724.398573; Apache=39.187.70.10_1745138724.398574; ULV=1745141869599:2:2:2:39.187.70.10_1745138724.398574:1745137249420; FIN_ALL_VISITED=sh000001; FINA_V_S_2=sh000001; FINA_V5_HQ=0; sinaH5EtagStatus=y; hqEtagMode=1; SFA_version8.11.0=2025-04-21%2006%3A54; SFA_version8.11.0_click=2";
  static const Map<String, String>  headers = {
                  "Accept": "*/*",
                  "Accept-Encoding": "gzip, deflate",
                  "Accept-Language": "zh-CN,zh;q=0.9",
                  "Connection": "keep-alive",
                  "Cookie": cookie,
                  "Host": "zhibo.sina.com.cn",
                  "Referer": referer_url,
                  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
              };

  // 新闻分类映射
  static const Map<String, int> _categoryTags = {
    '全部': 0,
    'A股': 10,
    '公司': 3,
    '数据': 4,
    '市场': 5,
    '国际': 102,
    '其他': 8,
  };

  static const Map<String, int> CategoryTags  = _categoryTags;

  // 获取指数代码的公共方法
  static int getNewsTypeTag(String name) {
    return _categoryTags[name] ?? 0;
  }

  static Future<List<NewsInfo>> getTopNews({
    int typeTag = 0,
    int num = 45,
  }) async {
    try {

      final response = await http.get(
        Uri.parse('$_baseUrl?zhibo_id=152&tag_id=$typeTag&page_size=$num&dire=f&dpc=1'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final parsedJson = json.decode(response.body);
        //final jsonData = parsedJson['result']['data']['feed']['list'];
        final List<dynamic> jsonList = parsedJson['result']['data']['feed']['list'];
        return jsonList.map((json) => NewsInfo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }



  static Future<List<Map<String, dynamic>>> searchNews(String keyword) async {
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
        throw Exception('Failed to search news');
      }
    } catch (e) {
      throw Exception('Failed to search news: $e');
    }
  }
} 