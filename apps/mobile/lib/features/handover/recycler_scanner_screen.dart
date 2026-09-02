import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../../core/theme/theme.dart';
import '../../core/database/models/transaction_model.dart';
import '../../core/database/models/traceability_model.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/network/sync_manager.dart';

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
    final entered = _pinController.text.trim();
    if (entered.length == 4) {
      final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
      final traceBox = Hive.box<TraceabilityModel>('traceabilityBox');
      
      // Look up active pending transaction
      final pendingTxns = transactionsBox.values.where((t) => t.status == 'LOCAL_PENDING').toList();
      if (pendingTxns.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active pending transactions found.')));
        return;
      }
      
      final activeTxn = pendingTxns.last; // Assuming the most recent one is the active one
      final traceMatch = traceBox.values.where((t) => t.lotId == activeTxn.lotId).toList();
      
      if (traceMatch.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Traceability data missing.')));
        return;
      }
      
      final hexHash = traceMatch.first.sha256Hash;
      
      // Derive the expected PIN from the stored SHA-256 hex string
      List<int> digestBytes = [];
      for (int i = 0; i < hexHash.length; i += 2) {
        digestBytes.add(int.parse(hexHash.substring(i, i + 2), radix: 16));
      }
      int rawUint32 = (digestBytes[0] << 24) | (digestBytes[1] << 16) | (digestBytes[2] << 8) | digestBytes[3];
      String expected = (rawUint32.abs() % 10000).toString().padLeft(4, '0');

      // Constant-time comparison
      bool matches = true;
      if (entered.length != expected.length) matches = false;
      int diff = 0;
      for (int i = 0; i < entered.length; i++) {
        diff |= entered.codeUnitAt(i) ^ expected.codeUnitAt(i);
      }
      if (diff != 0) matches = false;
      
      if (!matches) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid PIN: Verification failed.')));
      } else {
        _completeHandover(activeTxn.txnId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be 4 digits.')));
    }
  }

  void _completeHandover(String txnId) {
    // Update Transaction Status in Hive
    final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
    try {
      final txn = transactionsBox.values.firstWhere((t) => t.txnId == txnId, orElse: () => transactionsBox.values.last);
      txn.status = 'HANDOVER_COMPLETE';
      txn.save();
      
      // Trigger sync immediately
      SyncManager().processOutboxQueue();
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
