import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/lot_provider.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/theme/theme.dart';
import '../../core/database/models/transaction_model.dart';
import '../../core/database/models/traceability_model.dart';
import '../../core/constants/app_translations.dart';
import '../../core/providers/locale_provider.dart';

class HandoverScreen extends StatefulWidget {
  const HandoverScreen({super.key});

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  String? _transactionJson;
  String? _hashHandover;
  String? _fourDigitPin;
  bool _transactionSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAndSaveTransaction();
    });
  }

  void _generateAndSaveTransaction() {
    final lotProvider = Provider.of<LotProvider>(context, listen: false);
    
    if (lotProvider.selectedCategoryCode == null) {
      Navigator.pop(context);
      return;
    }

    // Generate Transaction Data
    const uuid = Uuid();
    final txnId = uuid.v4();
    final lotId = uuid.v4();
    final timestamp = DateTime.now().toIso8601String();
    
    // Extract 4-digit PIN (using last 4 numeric digits or hash segment)
    _fourDigitPin = (txnId.hashCode.abs() % 10000).toString().padLeft(4, '0');

    // SHA-256 (CollectorID || Timestamp || GPS || Weight || Category)
    final rawData = 'COLLECTOR_DEMO_01$timestamp${0.0}${lotProvider.approxWeightKg}${lotProvider.selectedCategoryCode}';
    final bytes = utf8.encode(rawData);
    final digest = sha256.convert(bytes);
    _hashHandover = digest.toString();

    // Prepare JSON for QR
    final payload = {
      'txnId': txnId,
      'lotId': lotId,
      'category': lotProvider.selectedCategoryCode,
      'weightKg': lotProvider.approxWeightKg,
      'valuation': lotProvider.estimatedValuation,
      'signature': _hashHandover,
      'pin': _fourDigitPin,
    };
    _transactionJson = jsonEncode(payload);

    // Save to Hive
    final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
    final traceabilityBox = Hive.box<TraceabilityModel>('traceabilityBox');

    transactionsBox.add(
      TransactionModel(
        txnId: txnId,
        lotId: lotId,
        collectorId: 'COLLECTOR_DEMO_01',
        finalWeightKg: lotProvider.approxWeightKg,
        ratePerKg: lotProvider.approxWeightKg > 0 ? lotProvider.estimatedValuation / lotProvider.approxWeightKg : 0,
        totalPayoutInr: lotProvider.estimatedValuation,
        paymentMode: 'CASH',
        status: 'LOCAL_PENDING',
      )
    );

    traceabilityBox.add(
      TraceabilityModel(
        traceId: uuid.v4(),
        lotId: lotId,
        sha256Hash: _hashHandover!,
        latitude: 0.0,
        longitude: 0.0,
        timestampUtc: DateTime.now().toUtc(),
      )
    );

    setState(() {
      _transactionSaved = true;
    });
  }

  void _speakPin() {
    if (_fourDigitPin == null) return;
    
    String spokenPin = _fourDigitPin!.split('').join(' - ');
    TTSEngine().speak(spokenPin);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).currentLocale.languageCode;

    if (!_transactionSaved) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'handover_title'), style: GoogleFonts.playfairDisplay(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppTranslations.get(lang, 'show_qr_instruction'),
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Tier-1: Dynamic QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: QrImageView(
                  data: _transactionJson ?? '',
                  version: QrVersions.auto,
                  size: 250.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppTheme.primaryBlue,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              // Tier-2: Spoken 4-Digit PIN Fallback
              Text(
                'PIN: $_fourDigitPin',
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, letterSpacing: 8),
              ),
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                onPressed: _speakPin,
                icon: const Icon(Icons.volume_up, color: Colors.white),
                label: Text(AppTranslations.get(lang, 'listen_pin'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),

              const Spacer(),

              // Switch to Recycler Scanner Mode
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/recycler_scanner');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      AppTranslations.get(lang, 'switch_scanner_mode'),
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
