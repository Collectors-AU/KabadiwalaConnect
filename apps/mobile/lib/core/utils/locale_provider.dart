import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum AppLanguage { english, hindi, marathi }

class LocaleProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsEnabled = true;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isTtsEnabled => _isTtsEnabled;

  LocaleProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    switch (language) {
      case AppLanguage.hindi:
        _flutterTts.setLanguage("hi-IN");
        break;
      case AppLanguage.marathi:
        _flutterTts.setLanguage("mr-IN");
        break;
      case AppLanguage.english:
      default:
        _flutterTts.setLanguage("en-IN");
        break;
    }
    notifyListeners();
  }

  void toggleTts(bool enabled) {
    _isTtsEnabled = enabled;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (_isTtsEnabled) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
