import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/database/models/transaction_model.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/constants/app_translations.dart';

class EarningsLedgerScreen extends StatelessWidget {
  const EarningsLedgerScreen({super.key});

  void _speakFinancialSummary(BuildContext context, double totalCash, double pendingDues) {
    String lang = Provider.of<LocaleProvider>(context, listen: false).currentLocale.languageCode;
    String textToSpeak = "Total earnings are ${totalCash.toStringAsFixed(0)} Rupees. Pending dues are ${pendingDues.toStringAsFixed(0)} Rupees.";
    
    if (lang == 'hi') {
      textToSpeak = "आपकी कुल कमाई ${totalCash.toStringAsFixed(0)} रुपये है और बकाया ${pendingDues.toStringAsFixed(0)} रुपये है।";
    } else if (lang == 'mr') {
      textToSpeak = "तुमची एकूण कमाई ${totalCash.toStringAsFixed(0)} रुपये आहे आणि बाकी ${pendingDues.toStringAsFixed(0)} रुपये आहे.";
    }

    TTSEngine().speak(textToSpeak);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'ledger_title'), style: GoogleFonts.playfairDisplay(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TransactionModel>('transactionsBox').listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          double totalCashEarned = 0.0;
          double pendingDues = 0.0;
          int completedCount = 0;

          final transactions = box.values.toList().reversed.toList(); // Newest first

          for (var txn in transactions) {
            if (txn.status == 'HANDOVER_COMPLETE') {
              totalCashEarned += txn.totalPayoutInr;
              completedCount++;
            } else if (txn.status == 'LOCAL_PENDING') {
              pendingDues += txn.totalPayoutInr;
            }
          }

          return Column(
            children: [
              // Summary Header Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.get(lang, 'total_earnings'),
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.white),
                          onPressed: () => _speakFinancialSummary(context, totalCashEarned, pendingDues),
                        )
                      ],
                    ),
                    Text(
                      '₹${totalCashEarned.toStringAsFixed(0)}',
                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppTranslations.get(lang, 'pending_dues'), style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                            Text('₹${pendingDues.toStringAsFixed(0)}', style: GoogleFonts.inter(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(AppTranslations.get(lang, 'lots_completed'), style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                            Text('$completedCount', style: GoogleFonts.inter(color: AppTheme.successGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Transaction List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    final isCompleted = txn.status == 'HANDOVER_COMPLETE';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.recycling, color: AppTheme.primaryBlue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.get(lang, '${txn.categoryCode}_vernacular'),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  txn.status == 'LOCAL_PENDING' ? AppTranslations.get(lang, 'lot_pending') : AppTranslations.get(lang, 'lot_completed'),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppTranslations.get(lang, 'weight_kg')}: ${txn.finalWeightKg.toStringAsFixed(1)} kg',
                                  style: GoogleFonts.inter(color: AppTheme.textLight, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '+₹${txn.totalPayoutInr.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.successGreen),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted ? AppTheme.successGreen.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isCompleted ? AppTranslations.get(lang, 'paid') : AppTranslations.get(lang, 'pending'),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? AppTheme.successGreen : Colors.orange,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
