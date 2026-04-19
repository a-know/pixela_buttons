import 'package:flutter/material.dart';
import 'package:pixela_buttons/l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'graphs/graphs_screen.dart';
import 'settings/settings_screen.dart';

// 外部からホームタブへの切り替えと再読み込みをトリガーする
final homeTabNotifier = ValueNotifier<int>(0);

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _homeVersion = 0;

  @override
  void initState() {
    super.initState();
    homeTabNotifier.addListener(_onHomeTabNotified);
  }

  @override
  void dispose() {
    homeTabNotifier.removeListener(_onHomeTabNotified);
    super.dispose();
  }

  void _onHomeTabNotified() {
    setState(() {
      _currentIndex = 0;
      _homeVersion++;
    });
  }

  void _onTabSelected(int index) {
    if (index == 0 && _currentIndex != 0) {
      // ホームタブに切り替わるとき最新データを読み込む
      setState(() {
        _currentIndex = 0;
        _homeVersion++;
      });
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: ValueKey(_homeVersion)),
          const GraphsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: AppLocalizations.of(context)!.tabGraphs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.tabSettings,
          ),
        ],
      ),
    );
  }
}
