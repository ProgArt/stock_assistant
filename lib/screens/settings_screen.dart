import 'package:flutter/material.dart';
import 'package:stock_assistant/utils/language_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoRefresh = true;
  int _refreshInterval = 5;
  int _indexRefreshInterval = 1;
  int _stockRefreshInterval = 3;
  String _currentLanguage = 'zh';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
      _autoRefresh = prefs.getBool('autoRefresh') ?? true;
      _refreshInterval = prefs.getInt('refreshInterval') ?? 5;
      _indexRefreshInterval = prefs.getInt('indexRefreshInterval') ?? 1;
      _stockRefreshInterval = prefs.getInt('stockRefreshInterval') ?? 3;
    });
    final locale = await LanguageManager.getLocale();
    setState(() {
      _currentLanguage = locale.languageCode;
      if (locale.countryCode == 'Hant') {
        _currentLanguage = 'zh_Hant';
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('notifications', _notifications);
    await prefs.setBool('autoRefresh', _autoRefresh);
    await prefs.setInt('refreshInterval', _refreshInterval);
    await prefs.setInt('indexRefreshInterval', _indexRefreshInterval);
    await prefs.setInt('stockRefreshInterval', _stockRefreshInterval);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: _currentLanguage,
              items: const [
                DropdownMenuItem(value: 'zh', child: Text('简体中文')),
                DropdownMenuItem(value: 'zh_Hant', child: Text('繁體中文')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await LanguageManager.setLocale(value);
                  if (mounted) {
                    setState(() {
                      _currentLanguage = value;
                    });
                  }
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text(l10n.darkMode),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: Text(l10n.notifications),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: Text(l10n.autoRefresh),
            value: _autoRefresh,
            onChanged: (value) {
              setState(() {
                _autoRefresh = value;
              });
              _saveSettings();
            },
          ),
          ListTile(
            title: Text(l10n.indexRefreshInterval),
            trailing: DropdownButton<int>(
              value: _indexRefreshInterval,
              items: [
                DropdownMenuItem(value: 1, child: Text('1 ${l10n.seconds}')),
                DropdownMenuItem(value: 3, child: Text('3 ${l10n.seconds}')),
                DropdownMenuItem(value: 5, child: Text('5 ${l10n.seconds}')),
                DropdownMenuItem(value: 10, child: Text('10 ${l10n.seconds}')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _indexRefreshInterval = value;
                  });
                  _saveSettings();
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.refreshInterval),
            trailing: DropdownButton<int>(
              value: _stockRefreshInterval,
              items: [
                DropdownMenuItem(value: 3, child: Text('3 ${l10n.seconds}')),
                DropdownMenuItem(value: 5, child: Text('5 ${l10n.seconds}')),
                DropdownMenuItem(value: 10, child: Text('10 ${l10n.seconds}')),
                DropdownMenuItem(value: 30, child: Text('30 ${l10n.seconds}')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _stockRefreshInterval = value;
                  });
                  _saveSettings();
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.about),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 50),
                children: [
                  Text('${l10n.dataSource}：sina'),
                  Text('${l10n.techSupport}: dbxmarket'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
} 