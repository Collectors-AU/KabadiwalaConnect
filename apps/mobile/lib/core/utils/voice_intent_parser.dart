class ParsedVoiceIntent {
  final String? categoryCode;
  final double? weightKg;

  ParsedVoiceIntent({this.categoryCode, this.weightKg});
}

class VoiceIntentParser {
  static ParsedVoiceIntent parse(String rawSpeech) {
    String speech = rawSpeech.toLowerCase();

    String? category;
    double? weight;

    // 1. Extract Category
    if (speech.contains('tamba') || speech.contains('taamba') || speech.contains('tambyachi') || speech.contains('copper') || speech.contains('wire') || speech.contains('cable') || speech.contains('तांबा') || speech.contains('तार')) {
      category = 'CABLE';
    } else if (speech.contains('battery') || speech.contains('cell') || speech.contains('बैटरी') || speech.contains('बॅटरी')) {
      category = 'BATTERY';
    } else if (speech.contains('motherboard') || speech.contains('circuit') || speech.contains('green board') || speech.contains('मदरबोर्ड')) {
      category = 'PCB_HIGH';
    } else if (speech.contains('tv') || speech.contains('lcd') || speech.contains('panel') || speech.contains('स्क्रीन')) {
      category = 'LCD';
    } else if (speech.contains('plastic') || speech.contains('प्लास्टिक')) {
      category = 'PLASTIC';
    } else if (speech.contains('motor') || speech.contains('magnet') || speech.contains('मोटर')) {
      category = 'MOTOR';
    }

    // 2. Extract Weight
    // Match numbers before or after kilo/kg
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*(kilo|kg|किलो)|(kilo|kg|किलो)\s*(\d+(?:\.\d+)?)', caseSensitive: false);
    final match = regex.firstMatch(speech);

    if (match != null) {
      String numStr = match.group(1) ?? match.group(4) ?? '';
      if (numStr.isNotEmpty) {
        weight = double.tryParse(numStr);
      }
    }

    // Fallback for written out numbers like 'पाच', 'five'
    if (weight == null) {
      if (speech.contains('five') || speech.contains('पाच') || speech.contains('पांच')) weight = 5.0;
      else if (speech.contains('ten') || speech.contains('दहा') || speech.contains('दस')) weight = 10.0;
      else if (speech.contains('twenty') || speech.contains('वीस') || speech.contains('बीस')) weight = 20.0;
    }

    // Clamp between 0.5 and 50.0
    if (weight != null) {
      weight = weight.clamp(0.5, 50.0);
    }

    return ParsedVoiceIntent(categoryCode: category, weightKg: weight);
  }
}
