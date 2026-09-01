import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/providers/locale_provider.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text('Safety Guidance', style: GoogleFonts.playfairDisplay(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHazardCard(
            context: context,
            title: 'Cable Burning Hazard',
            icon: Icons.local_fire_department,
            color: Colors.redAccent,
            description: 'Open burning of cables releases toxic smoke. Please use formal wire stripping methods.',
            hiText: 'तारों को जलाने से जहरीला धुआं निकलता है। कृपया तार छीलने के सुरक्षित तरीकों का उपयोग करें।',
            mrText: 'वायर जाळल्याने विषारी धूर निघतो. कृपया वायर सोलण्याच्या सुरक्षित पद्धती वापरा.',
            enText: 'Open burning of cables releases toxic smoke. Please use formal wire stripping methods.',
          ),
          const SizedBox(height: 16),
          _buildHazardCard(
            context: context,
            title: 'Acid Leaching Hazard',
            icon: Icons.science,
            color: Colors.orange,
            description: 'Improper acid use causes water pollution. We recommend formal hydrometallurgy extraction.',
            hiText: 'गलत तरीके से एसिड के उपयोग से जल प्रदूषण होता है। सुरक्षित निष्कर्षण की सिफारिश की जाती है।',
            mrText: 'चुकीच्या पद्धतीने ॲसिड वापरल्यास जलप्रदूषण होते. सुरक्षित काढण्याची शिफारस केली जाते.',
            enText: 'Improper acid use causes water pollution. We recommend formal hydrometallurgy extraction.',
          ),
          const SizedBox(height: 16),
          _buildHazardCard(
            context: context,
            title: 'Battery Crushing Hazard',
            icon: Icons.battery_alert,
            color: Colors.deepOrange,
            description: 'Crushing batteries poses a lithium fire risk. Hand over in sealed containers.',
            hiText: 'बैटरी कुचलने से आग लगने का खतरा होता है। इन्हें सुरक्षित कंटेनरों में सौंपें।',
            mrText: 'बॅटरी फोडल्यास आग लागण्याचा धोका असतो. ते सुरक्षित कंटेनरमध्ये द्या.',
            enText: 'Crushing batteries poses a lithium fire risk. Hand over in sealed containers.',
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
