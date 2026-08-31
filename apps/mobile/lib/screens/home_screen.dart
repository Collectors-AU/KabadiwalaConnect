import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'sell_scrap_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalLots = 0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final metrics = await ApiService.getMetrics();
    setState(() {
      totalLots = metrics['total_lots'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK,',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Ramesh',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B3B86),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B3B86),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DEMO',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFF3F0E6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SellScrapScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B3B86),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'SELL SCRAP',
                      style: GoogleFonts.playfairDisplay(
                        color: const Color(0xFFF3F0E6),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'कबाड़ बेचें',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA0ABC0),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCard('01', 'Today\'s Prices', 'आज के भाव', () {
                  // Usually handled via bottom nav, but can push direct if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Use tabs to navigate')));
                }),
                _buildCard('02', 'My Lots', 'मेरा माल ($totalLots)', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Use tabs to navigate')));
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCard('03', 'Find Buyers', 'खरीदार खोजें', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')));
                }),
                _buildCard('04', 'Safety Guide', 'सुरक्षा गाइड', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      String number, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFFD1CDBC))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                color: const Color(0xFF1B3B86).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B3B86),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
