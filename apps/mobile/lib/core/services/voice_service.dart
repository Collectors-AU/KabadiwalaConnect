import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool isListening = false;

  static Future<bool> ensurePermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  static bool _hasAttemptedFallback = false;

  static Future<void> startListening({
    required String localeId,
    required Function(String) onResult,
    required Function(String) onError,
    required Function(String) onStatus,
  }) async {
    bool hasPermission = await ensurePermissions();
    if (!hasPermission) return;

    if (!isListening) {
      _hasAttemptedFallback = false;
      
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            isListening = false;
          }
          onStatus(status);
        },
        onError: (error) async {
          if ((error.errorMsg.contains('error_language_unavailable') || error.errorMsg.contains('error_speech_timeout')) && !_hasAttemptedFallback) {
            _hasAttemptedFallback = true;
            await _speech.stop();
            await Future.delayed(const Duration(milliseconds: 300)); // Brief pause to let Android recognizer reset
            
            isListening = true;
            // Retry unconditionally with system default (null)
            await _speech.listen(
              localeId: null,
              onResult: (val) {
                if (val.finalResult) {
                  onResult(val.recognizedWords);
                }
              },
              listenFor: const Duration(seconds: 15),
              pauseFor: const Duration(seconds: 4),
              cancelOnError: true,
              partialResults: false,
            );
          } else {
            isListening = false;
            onError("Voice unavailable. You can adjust the slider manually.");
          }
        },
      );

      if (available) {
        isListening = true;
        
        final List locales = await _speech.locales();
        String? actualLocaleId = localeId;
        
        bool isSupported = locales.any((l) => l.localeId == actualLocaleId || l.localeId == actualLocaleId?.replaceAll('_', '-'));
        
        if (!isSupported) {
          print("Target locale unavailable. Falling back to device default recognizer.");
          actualLocaleId = null;
        }
        
        await _speech.listen(
          localeId: actualLocaleId,
          onResult: (val) {
            if (val.finalResult) {
              onResult(val.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: true,
          partialResults: false,
        );
      } else {
        onError("Speech recognition not available on this device.");
      }
    }
  }

  static Future<void> stopListening() async {
    if (isListening) {
      await _speech.stop();
      isListening = false;
    }
  }
}
