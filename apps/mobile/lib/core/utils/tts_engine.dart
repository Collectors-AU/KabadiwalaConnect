import 'dart:ui';
import 'package:flutter_tts/flutter_tts.dart';

class TTSEngine {
  static final TTSEngine _instance = TTSEngine._internal();
  factory TTSEngine() => _instance;
  TTSEngine._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isReady = false;

  Future<void> init() async {
    if (!_isReady) {
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isReady = true;
    }
  }

  Future<void> setLanguage(Locale locale) async {
    await init();
    String languageCode = '${locale.languageCode}_${locale.countryCode ?? "IN"}';

    // Try setting the language
    var isAvailable = await _flutterTts.isLanguageAvailable(languageCode);
    if (isAvailable) {
      await _flutterTts.setLanguage(languageCode);
    } else {
      // Graceful fallback logic
      if (languageCode == 'mr_IN') {
        print("Marathi TTS not available on this device. Falling back to Hindi (hi_IN)");
        await _flutterTts.setLanguage('hi_IN');
      } else {
        print("$languageCode TTS not available on this device. Falling back to English (en_IN)");
        await _flutterTts.setLanguage('en_IN');
      }
    }
  }

  Future<void> speak(String text) async {
    await init();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
