import 'package:flutter/material.dart';
import '../utils/tts_engine.dart';

class LocaleProvider extends ChangeNotifier {
  // Default to Hindi
  Locale _currentLocale = const Locale('hi', 'IN');

  Locale get currentLocale => _currentLocale;

  Future<void> setLocale(Locale newLocale) async {
    _currentLocale = newLocale;
    notifyListeners();
    // Update TTS Engine language
    await TTSEngine().setLanguage(newLocale);
  }
}
