import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/hive_setup.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/theme.dart';
import 'core/providers/lot_provider.dart';
import 'features/onboarding/language_onboarding_screen.dart';
import 'features/navigation/main_shell_screen.dart';
import 'features/handover/handover_screen.dart';
import 'features/handover/recycler_scanner_screen.dart';
import 'screens/lots_screen.dart';
import 'screens/prices_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveSetup.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => LotProvider()),
      ],
      child: const KabadiwalaApp(),
    ),
  );
}

class KabadiwalaApp extends StatelessWidget {
  const KabadiwalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kabadiwala Connect',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const LanguageOnboardingScreen(),
        '/main_shell': (context) => const MainShellScreen(),
        '/handover': (context) => const HandoverScreen(),
        '/recycler_scanner': (context) => const RecyclerScannerScreen(),
      },
    );
  }
}

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const LotsScreen(),
    const PricesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF1B3B86),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Lots'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_rupee), label: 'Prices'),
        ],
      ),
    );
  }
}
