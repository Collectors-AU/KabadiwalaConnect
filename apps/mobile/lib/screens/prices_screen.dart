import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  List<dynamic> prices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    try {
      final data = await ApiService.getPrices();
      setState(() {
        prices = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Text(
              'Market Prices',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B3B86),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B3B86)))
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: prices.length,
                    itemBuilder: (context, index) {
                      final item = prices[index];
                      Color trendColor;
                      String trendIcon;
                      if (item['trend'] == 'UP') {
                        trendColor = Colors.green[800]!;
                        trendIcon = '↑';
                      } else if (item['trend'] == 'DOWN') {
                        trendColor = Colors.red[800]!;
                        trendIcon = '↓';
                      } else {
                        trendColor = Colors.grey[600]!;
                        trendIcon = '-';
                      }

                      return Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B3B86),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '₹${item['price']}',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B3B86),
                                  ),
                                ),
                                Text(
                                  '/kg',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  trendIcon,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: trendColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
