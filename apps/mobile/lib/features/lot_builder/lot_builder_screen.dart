import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/lot_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/utils/tts_engine.dart';
import '../../core/utils/voice_intent_parser.dart';
import '../../core/utils/edge_vision_classifier.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_translations.dart';
import 'widgets/category_card.dart';

class LotBuilderScreen extends StatefulWidget {
  const LotBuilderScreen({super.key});

  @override
  State<LotBuilderScreen> createState() => _LotBuilderScreenState();
}

class _LotBuilderScreenState extends State<LotBuilderScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final ImagePicker _picker = ImagePicker();
  final EdgeVisionClassifier _classifier = EdgeVisionClassifier();

  void _announceValuation(LotProvider lotProvider, String? categoryCode) {
    if (categoryCode == null) return;
    String catName = categoryCode;
    String lang = Provider.of<LocaleProvider>(context, listen: false).currentLocale.languageCode;
    
    String textToSpeak = "${lotProvider.approxWeightKg} Kilo $catName selected. Value ${lotProvider.estimatedValuation.toStringAsFixed(0)} Rupees";
    if (lang == 'hi') {
      textToSpeak = "${lotProvider.approxWeightKg} किलो $catName का मूल्य ${lotProvider.estimatedValuation.toStringAsFixed(0)} रुपये है";
    } else if (lang == 'mr') {
      textToSpeak = "${lotProvider.approxWeightKg} किलो $catName चे मूल्य ${lotProvider.estimatedValuation.toStringAsFixed(0)} रुपये आहे";
    }

    TTSEngine().speak(textToSpeak);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = false;
      try {
        available = await _speech.initialize(
          onStatus: (val) {
            if (val == 'done' || val == 'notListening') {
              setState(() => _isListening = false);
            }
          },
          onError: (val) {
            setState(() => _isListening = false);
            if (val.errorMsg != 'error_no_match') {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voice error: ${val.errorMsg}')));
            }
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission denied.')));
        return;
      }

      if (available) {
        setState(() => _isListening = true);
        String localeId = '${Provider.of<LocaleProvider>(context, listen: false).currentLocale.languageCode}_IN';
        
        _speech.listen(
          localeId: localeId,
          onResult: (val) {
            if (val.finalResult) {
              _processVoiceIntent(val.recognizedWords);
            }
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission denied.')));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processVoiceIntent(String recognizedWords) {
    final lotProvider = Provider.of<LotProvider>(context, listen: false);
    final intent = VoiceIntentParser.parse(recognizedWords);

    bool updated = false;
    if (intent.categoryCode != null) {
      lotProvider.setCategoryCode(intent.categoryCode!);
      updated = true;
    }
    if (intent.weightKg != null) {
      lotProvider.setWeight(intent.weightKg!);
      updated = true;
    }

    if (updated && lotProvider.selectedCategoryCode != null) {
      _announceValuation(lotProvider, lotProvider.selectedCategoryCode);
    } else if (recognizedWords.isNotEmpty && !updated) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Heard: $recognizedWords (No action taken)')));
    }
  }

  Future<void> _takePhotoAndClassify() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analyzing image...')));

      final result = await _classifier.classifyImage(image.path);
      if (result != null) {
        final lotProvider = Provider.of<LotProvider>(context, listen: false);
        lotProvider.setCategoryCode(result.categoryCode);
        
        String lang = Provider.of<LocaleProvider>(context, listen: false).currentLocale.languageCode;
        String textToSpeak = "AI detected ${result.categoryCode}";
        if (lang == 'hi') textToSpeak = "AI ने ${result.categoryCode} की पहचान की है";
        else if (lang == 'mr') textToSpeak = "AI ने ${result.categoryCode} ओळखले आहे";
        
        TTSEngine().speak(textToSpeak);
      } else {
        // Fallback to manual selection gracefully
      }
    } catch (e) {
      // Permission denied or other error
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera error.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lotProvider = Provider.of<LotProvider>(context);
    final lang = Provider.of<LocaleProvider>(context).currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'lot_builder_title'), style: GoogleFonts.playfairDisplay(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue, size: 28),
            onPressed: _takePhotoAndClassify,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.red : AppTheme.primaryBlue,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
      ),
      body: Column(
        children: [
          // Category Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: AppConstants.eWasteCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.eWasteCategories[index];
                final isSelected = lotProvider.selectedCategoryCode == category;

                return CategoryCard(
                  categoryCode: category,
                  isSelected: isSelected,
                  onTap: () {
                    lotProvider.setCategoryCode(category);
                    _announceValuation(lotProvider, category);
                  },
                );
              },
            ),
          ),
          
          // Weight Slider Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get(lang, 'weight_kg'),
                  style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textLight),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0.5', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppTheme.primaryBlue,
                          inactiveTrackColor: AppTheme.lightGrey,
                          thumbColor: AppTheme.primaryBlue,
                          trackHeight: 12,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 16),
                        ),
                        child: Slider(
                          value: lotProvider.approxWeightKg,
                          min: 0.5,
                          max: 50.0,
                          divisions: 99,
                          label: lotProvider.approxWeightKg.toStringAsFixed(1),
                          onChanged: (value) {
                            lotProvider.setWeight(value);
                          },
                          onChangeEnd: (value) {
                            _announceValuation(lotProvider, lotProvider.selectedCategoryCode);
                          },
                        ),
                      ),
                    ),
                    Text('50.0', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ],
                ),
                Center(
                  child: Text(
                    '${lotProvider.approxWeightKg.toStringAsFixed(1)} Kg',
                    style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ),
                
                const SizedBox(height: 20),
                // Valuation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.offWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${AppTranslations.get(lang, 'estimated_value')} ₹${lotProvider.estimatedValuation.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTranslations.get(lang, 'base_price_breakdown')
                            .replaceAll('@basePrice', lotProvider.currentBasePrice.toStringAsFixed(0))
                            .replaceAll('@eprBonus', lotProvider.currentEprBonus.toStringAsFixed(0)),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLight),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                // Submit Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/handover');
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
                        AppTranslations.get(lang, 'create_lot_btn'),
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
