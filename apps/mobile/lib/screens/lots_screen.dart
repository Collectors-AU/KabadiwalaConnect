import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LotsScreen extends StatelessWidget {
  const LotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'My Lots',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B3B86),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Text(
                  'No lots found yet.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
