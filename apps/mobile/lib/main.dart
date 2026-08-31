import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/lots_screen.dart';
import 'screens/prices_screen.dart';

void main() {
  runApp(const KabadiwalaApp());
}

class KabadiwalaApp extends StatelessWidget {
  const KabadiwalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kabadiwala Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F0E6),
        primaryColor: const Color(0xFF1B3B86),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(color: const Color(0xFF1B3B86), fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.inter(color: const Color(0xFF152042)),
          bodyMedium: GoogleFonts.inter(color: const Color(0xFF666666)),
        ),
      ),
      home: const MainTabView(),
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
