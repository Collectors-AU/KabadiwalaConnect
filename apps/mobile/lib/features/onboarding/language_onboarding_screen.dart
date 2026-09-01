import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageOnboardingScreen extends StatelessWidget {
  const LanguageOnboardingScreen({super.key});

  void _selectLanguage(BuildContext context, Locale locale, String welcomeText) {
    // Update Provider
    Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
    
    // Speak Welcome Message
    TTSEngine().speak(welcomeText);

    // Navigate to Main Dashboard
    Navigator.of(context).pushReplacementNamed('/main_shell');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Language\nभाषा निवडा\nभाषा चुनें',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              _buildLanguageCard(
                context,
                title: 'हिंदी',
                locale: const Locale('hi', 'IN'),
                welcomeText: 'कबाड़ीवाला कनेक्ट में आपका स्वागत है।',
              ),
              const SizedBox(height: 20),
              _buildLanguageCard(
                context,
                title: 'मराठी',
                locale: const Locale('mr', 'IN'),
                welcomeText: 'कबाडीवाला कनेक्ट मध्ये आपले स्वागत आहे.',
              ),
              const SizedBox(height: 20),
              _buildLanguageCard(
                context,
                title: 'English',
                locale: const Locale('en', 'IN'),
                welcomeText: 'Welcome to Kabadiwala Connect.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, {required String title, required Locale locale, required String welcomeText}) {
    return GestureDetector(
      onTap: () => _selectLanguage(context, locale, welcomeText),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryBlue, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}
