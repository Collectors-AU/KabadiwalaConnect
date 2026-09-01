import 'package:flutter/material.dart';
import '../lot_builder/lot_builder_screen.dart';
import '../../core/theme/theme.dart';
import '../ledger/earnings_ledger_screen.dart';
import '../safety/safety_guidance_screen.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle),
            label: 'Lot Builder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Price Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Ledger',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Safety',
          ),
        ],
      ),
    );
  }
}
