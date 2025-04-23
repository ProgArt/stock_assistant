import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/stock.dart';
import '../services/stock_api.dart';
import '../services/preferences_service.dart';
import 'dart:async';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<MarketIndex> _indices = [];
  List<Stock> _stocks = [];
  bool _isLoading = true;
  String _error = '';
  String _currentSort = 'changepercent';
  int _currentAsc = 0;
  Timer? _refreshTimer;
  int _refreshInterval = 60;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchMarketData();
    _fetchStocks();
  }

  Future<void> _loadSettings() async {
    final interval = await PreferencesService.getIndexRefreshInterval();
    if (mounted) {
      setState(() {
        _refreshInterval = interval;
      });
      _startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshInterval),
      (_) => _fetchMarketData(),
    );
  }

  Future<void> _fetchMarketData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final indices = await StockApi.getAllMarketIndices();
      setState(() {
        _indices = indices.map((data) => MarketIndex(
          name: data['name'],
          code: StockApi.getIndexCode(data['name']),
          price: data['current'],
          change: data['change'],
          changePercent: data['changePercent'],
          volume: data['volume'],
          amount: data['amount'],
        )).toList();
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)?.failedToLoad ?? 'Failed to load';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchStocks() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final stocks = await StockApi.getTopStocks(
        sort: _currentSort,
        asc: _currentAsc,
      );
      setState(() {
        _stocks = stocks;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)?.failedToLoad ?? 'Failed to load';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortStocks(String sort) {
    if (_currentSort == sort) {
      setState(() {
        _currentAsc = _currentAsc == 0 ? 1 : 0;
      });
    } else {
      setState(() {
        _currentSort = sort;
        _currentAsc = 0;
      });
    }
    _fetchStocks();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.market),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMarketData,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _indices.length,
                        itemBuilder: (context, index) {
                          final indexData = _indices[index];
                          return SizedBox(
                            width: 128,
                            child: _MarketIndexCard(
                              index: indexData,
                              name: indexData.name,
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSortButton('trade', l10n.price, context),
                _buildSortButton('changepercent', l10n.change, context),
                _buildSortButton('amount', l10n.amount, context),
                _buildSortButton('volume', l10n.volume, context),
                _buildSortButton('turnoverratio', l10n.turnoverRatio, context, fontSize: 10),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : RefreshIndicator(
                        onRefresh: _fetchStocks,
                        child: ListView.builder(
                          itemCount: _stocks.length,
                          itemBuilder: (context, index) {
                            final stock = _stocks[index];
                            return _StockItem(stock: stock);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(String sort, String title, BuildContext context,{double fontSize = 12}) {
    final isSelected = _currentSort == sort;
    final isAscending = _currentAsc == 1;
    
    return TextButton(
      onPressed: () => _sortStocks(sort),
      child: Row(
        children: [
          Text(title),
          if (isSelected)
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
        ],
      ),
    );
  }
}

class MarketIndex {
  final String name;
  final String code;
  double price;
  double change;
  double changePercent;
  double volume;
  double amount;

  MarketIndex({
    required this.name,
    required this.code,
    this.price = 0.0,
    this.change = 0.0,
    this.changePercent = 0.0,
    this.volume = 0.0,
    this.amount = 0.0,
  });
}

class _MarketIndexCard extends StatelessWidget {
  final MarketIndex index;
  final String name;

  const _MarketIndexCard({
    required this.index,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPositive = index.change >= 0;
    final color = isPositive ? Colors.red : Colors.green;
    final changeSymbol = isPositive ? '+' : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat('##0.00').format(index.price),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$changeSymbol${index.change.toStringAsFixed(2)} (${index.changePercent.toStringAsFixed(2)}%)',
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${NumberFormat("##0.00").format(index.amount / 10000 / 10000)}${l10n.hundredMillion}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockItem extends StatelessWidget {
  final Stock stock;

  const _StockItem({required this.stock});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPositive = stock.changePercent >= 0;
    final color = isPositive ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // 第一列：股票名称和代码
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    stock.code,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // 第二列：价格和涨跌幅
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stock.trade.toStringAsFixed(2),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 第三列：成交金额
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat("##0.00").format(stock.amount / 10000 / 10000)}${l10n.hundredMillion}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 第四列：成交数量和换手率
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${NumberFormat("##0").format(stock.volume / 10000)}${l10n.tenThousand}${l10n.hands}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${stock.turnoverRatio.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 