import 'package:flutter/material.dart';
import 'package:stock_assistant/screens/market_screen.dart';
import 'package:stock_assistant/screens/favorites_screen.dart';
import 'package:stock_assistant/screens/trade_screen.dart';
import 'package:stock_assistant/screens/news_screen.dart';
import 'package:stock_assistant/screens/settings_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const MarketScreen(),
    const FavoritesScreen(),
    const TradeScreen(),
    const NewsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: l10n.marketSimple,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outlined),
            label: l10n.favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart),
            label: l10n.trade,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article),
            label: l10n.newsSimple,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
} 