import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.trade),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.position),
              Tab(text: l10n.order),
              Tab(text: l10n.deal),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPositionTab(context),
            _buildOrderTab(context),
            _buildDealTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionTab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  l10n.totalAssets,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '¥10,000,000.00',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: 实现交易功能
              },
              child: Text(l10n.buy),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: 实现交易功能
              },
              child: Text(l10n.sell),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: 0,
            itemBuilder: (context, index) {
              return const ListTile();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTab(BuildContext context) {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) {
        return const ListTile();
      },
    );
  }

  Widget _buildDealTab(BuildContext context) {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) {
        return const ListTile();
      },
    );
  }

} 