import 'package:flutter/material.dart';
import '../lot_builder/lot_builder_screen.dart';
import '../../core/theme/theme.dart';
import '../ledger/earnings_ledger_screen.dart';
import '../safety/safety_guidance_screen.dart';
import '../../core/constants/app_translations.dart';
import '../../core/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LotBuilderScreen(),
    const Scaffold(body: Center(child: Text("Price Board (Coming Soon)", style: TextStyle(fontSize: 24)))),
    const EarningsLedgerScreen(),
    const SafetyGuidanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).currentLocale.languageCode;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.build_circle),
            label: AppTranslations.get(lang, 'nav_lot_builder'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: AppTranslations.get(lang, 'price_board_title'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: AppTranslations.get(lang, 'nav_ledger'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.health_and_safety),
            label: AppTranslations.get(lang, 'nav_safety'),
          ),
        ],
      ),
    );
  }
}
