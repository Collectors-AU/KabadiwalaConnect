import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../core/theme/theme.dart';
import '../../core/database/models/transaction_model.dart';
import '../../core/database/models/traceability_model.dart';
import '../../core/utils/tts_engine.dart';

class RecyclerScannerScreen extends StatefulWidget {
  const RecyclerScannerScreen({super.key});

  @override
  State<RecyclerScannerScreen> createState() => _RecyclerScannerScreenState();
}

class _RecyclerScannerScreenState extends State<RecyclerScannerScreen> {
  bool _isSuccess = false;
  final TextEditingController _pinController = TextEditingController();

  void _onDetect(BarcodeCapture capture) {
    if (_isSuccess) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        try {
          final payload = jsonDecode(barcode.rawValue!);
          if (payload['txn_id'] != null && payload['sha256_hash'] != null) {
            final traceBox = Hive.box<TraceabilityModel>('traceabilityBox');
            final match = traceBox.values.where((t) => t.sha256Hash == payload['sha256_hash']).toList();
            if (match.isNotEmpty) {
              _completeHandover(payload['txn_id']);
              break;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid QR: Hash mismatch.')));
            }
          }
        } catch (e) {
          // Invalid QR Code format
        }
      }
    }
  }

  void _completeHandoverByPin() {
    final pin = _pinController.text.trim().toUpperCase();
    if (pin.length == 4) {
      final traceBox = Hive.box<TraceabilityModel>('traceabilityBox');
      final match = traceBox.values.where((t) => t.sha256Hash.toUpperCase().startsWith(pin)).toList();
      if (match.isNotEmpty) {
        final lotId = match.first.lotId;
        final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
        final txnMatch = transactionsBox.values.where((t) => t.lotId == lotId).toList();
        if (txnMatch.isNotEmpty) {
          _completeHandover(txnMatch.first.txnId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN: Transaction not found.')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN: Hash mismatch.')));
      }
    }
  }

  void _completeHandover(String txnId) {
    // Update Transaction Status in Hive
    final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
    try {
      final txn = transactionsBox.values.firstWhere((t) => t.txnId == txnId, orElse: () => transactionsBox.values.last);
      txn.status = 'HANDOVER_COMPLETE';
      txn.save();
    } catch (e) {
      // Demo logic fallback
    }

    setState(() {
      _isSuccess = true;
    });

    TTSEngine().speak('Handover successful. Payment approved.');
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return _buildSuccessScreen();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recycler Scanner', style: GoogleFonts.playfairDisplay(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryBlue,
            indicatorColor: AppTheme.primaryBlue,
            tabs: [
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan QR'),
              Tab(icon: Icon(Icons.pin), text: 'Enter PIN'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // QR Scanner Tab
            Stack(
              children: [
                MobileScanner(
                  onDetect: _onDetect,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.successGreen, width: 4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // PIN Fallback Tab
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter Collector\'s 4-Digit PIN',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 10),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _completeHandoverByPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Confirm Handover', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppTheme.successGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 120, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Material Handover Confirmed!',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Cash Payout Approved',
              style: GoogleFonts.inter(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/main_shell'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.successGreen,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
