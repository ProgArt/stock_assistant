import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_assistant/providers/stock_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/preferences_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    StockProvider stockProvider = StockProvider();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.favorites),
          actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:  () => stockProvider.fetchStocks(),
          ),
        ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.all),
              Tab(text: l10n.stock),
              Tab(text: l10n.fund),
              Tab(text: l10n.bond),
              Tab(text: l10n.futures),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStockRankings(context),
            _buildStockRankings(context),
            _buildStockRankings(context),
            _buildStockRankings(context),
            _buildFuturesRankings(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStockRankings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        if (stockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (stockProvider.error.isNotEmpty) {
          return Center(child: Text(stockProvider.error));
        }

        return RefreshIndicator(
          onRefresh: () => stockProvider.fetchStocks(),
          child: ListView.builder(
            itemCount: stockProvider.stocks.length,
            itemBuilder: (context, index) {
              final stock = stockProvider.stocks[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: (stock['change'] ?? 0) >= 0
                      ? Colors.red
                      : Colors.green,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(stock['name'] ?? ''),
                subtitle: Text(stock['code'] ?? ''),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock['price']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stock['change']?.toString() ?? ''}%',
                      style: TextStyle(
                        color: (stock['change'] ?? 0) >= 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFuturesRankings(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<StockProvider>(
      builder: (context, stockProvider, child) {
        if (stockProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (stockProvider.error.isNotEmpty) {
          return Center(child: Text(stockProvider.error));
        }

        return RefreshIndicator(
          onRefresh: () => stockProvider.fetchFutures(),
          child: ListView.builder(
            itemCount: stockProvider.futures.length,
            itemBuilder: (context, index) {
              final future = stockProvider.futures[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: (future['change'] ?? 0) >= 0
                      ? Colors.red
                      : Colors.green,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(future['name'] ?? ''),
                subtitle: Text(future['code'] ?? ''),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      future['price']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${future['volume']?.toString() ?? ''}${l10n.hands}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
} 