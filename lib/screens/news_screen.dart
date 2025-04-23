import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/newsInfo.dart';
import '../services/news_api.dart';
import 'dart:async';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with TickerProviderStateMixin {
  List<NewsInfo> _news = [];
  bool _isLoading = true;
  String _error = '';
  Timer? _refreshTimer;
  int _refreshInterval = 180;
  String _currentCategory = '全部';
  int _currentTag = 0;
  int _pageSize = 45;
  late AnimationController _categoryController;
  late Animation<double> _categoryAnimation;
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _categoryController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _categoryAnimation = CurvedAnimation(
      parent: _categoryController,
      curve: Curves.easeInOut,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _loadingAnimation = CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    );
    _loadSettings();
    _fetchNews();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _categoryController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _refreshInterval = prefs.getInt('newsRefreshInterval') ?? 180;
    });
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshInterval),
      (_) => _fetchNews(),
    );
  }

  void _changeCategory(String category) {
    if (category == _currentCategory) return;
    
    setState(() {
      _isLoading = true;
    });
    
    _categoryController.forward(from: 0.0).then((_) {
      setState(() {
        _currentCategory = category;
        _currentTag = NewsApi.getNewsTypeTag(category);
      });
      _categoryController.reverse();
      _fetchNews();
    });
  }

  Future<void> _fetchNews() async {
    if (!mounted) return;


    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {

        final news = await NewsApi.getTopNews(typeTag: _currentTag, num: _pageSize);

        setState(() {
          _news = news;
        });

    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.failedToLoad;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.news),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNews,
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类按钮
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: NewsApi.CategoryTags.keys.map((category) {
                final isSelected = category == _currentCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AnimatedBuilder(
                    animation: _categoryAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? 1.0 + _categoryAnimation.value * 0.1 : 1.0,
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => _changeCategory(category),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          // 新闻列表
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _loadingAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _loadingAnimation.value * 2 * 3.14159,
                              child: const Icon(
                                Icons.refresh,
                                size: 40,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '正在加载$_currentCategory新闻...',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _fetchNews,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchNews,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: ListView.builder(
                            key: ValueKey(_currentCategory),
                            itemCount: _news.length,
                            itemBuilder: (context, index) {
                              final newsinfo = _news[index];
                              return _NewsCard(
                                time: newsinfo.updateTime,
                                content: newsinfo.richText,
                                link: newsinfo.docurl,
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatefulWidget {
  final String time;
  final String content;
  final String link;

  const _NewsCard({
    required this.time,
    required this.content,
    required this.link,
  });

  @override
  State<_NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<_NewsCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              elevation: _isHovered ? 4.0 : 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                  color: _isHovered ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                  width: 1.0,
                ),
              ),
              child: InkWell(
                onTap: () async {
                  if (widget.link.isNotEmpty) {
                    final Uri url = Uri.parse(widget.link);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: _isHovered ? Colors.blue.withOpacity(0.02) : Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 时间行
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              widget.time,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (widget.link.isNotEmpty)
                            FadeTransition(
                              opacity: _opacityAnimation,
                              child: const Icon(
                                Icons.open_in_new,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 新闻内容
                      Text(
                        widget.content,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 底部信息
                      Row(
                        children: [
                          const Icon(
                            Icons.source,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '新浪财经',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          FadeTransition(
                            opacity: _opacityAnimation,
                            child: Text(
                              '点击查看详情',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsItem {
  final String time;
  final String content;
  final String link;

  NewsItem({
    required this.time,
    required this.content,
    required this.link,
  });
}

class _NewsItemCard extends StatelessWidget {
  final NewsItem news;

  const _NewsItemCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(news.link);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.failedToLoad)),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      news.time,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                news.content,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 