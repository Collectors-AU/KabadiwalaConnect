import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/constants/app_translations.dart';

class SafetyGuidanceScreen extends StatelessWidget {
  const SafetyGuidanceScreen({super.key});

  void _speakGuidance(BuildContext context, String hiText, String mrText, String enText) {
    String lang = Provider.of<LocaleProvider>(context, listen: false).currentLocale.languageCode;
    String textToSpeak = enText;
    if (lang == 'hi') textToSpeak = hiText;
    else if (lang == 'mr') textToSpeak = mrText;

    TTSEngine().speak(textToSpeak);
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'safety_title'), style: GoogleFonts.playfairDisplay(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHazardCard(
            context: context,
            title: AppTranslations.get(lang, 'cable_burning_title'),
            icon: Icons.local_fire_department,
            color: Colors.redAccent,
            description: AppTranslations.get(lang, 'cable_burning_desc'),
            hiText: AppTranslations.get('hi', 'cable_burning_desc'),
            mrText: AppTranslations.get('mr', 'cable_burning_desc'),
            enText: AppTranslations.get('en', 'cable_burning_desc'),
          ),
          const SizedBox(height: 16),
          _buildHazardCard(
            context: context,
            title: AppTranslations.get(lang, 'acid_leaching_title'),
            icon: Icons.science,
            color: Colors.orange,
            description: AppTranslations.get(lang, 'acid_leaching_desc'),
            hiText: AppTranslations.get('hi', 'acid_leaching_desc'),
            mrText: AppTranslations.get('mr', 'acid_leaching_desc'),
            enText: AppTranslations.get('en', 'acid_leaching_desc'),
          ),
          const SizedBox(height: 16),
          _buildHazardCard(
            context: context,
            title: AppTranslations.get(lang, 'battery_crushing_title'),
            icon: Icons.battery_alert,
            color: Colors.deepOrange,
            description: AppTranslations.get(lang, 'battery_crushing_desc'),
            hiText: AppTranslations.get('hi', 'battery_crushing_desc'),
            mrText: AppTranslations.get('mr', 'battery_crushing_desc'),
            enText: AppTranslations.get('en', 'battery_crushing_desc'),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required String hiText,
    required String mrText,
    required String enText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppTheme.primaryBlue, size: 28),
                onPressed: () => _speakGuidance(context, hiText, mrText, enText),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight, height: 1.5),
          )
        ],
      ),
    );
  }
}
