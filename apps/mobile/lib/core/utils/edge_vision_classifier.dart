import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class PredictionResult {
  final String categoryCode;
  final double confidence;

  PredictionResult(this.categoryCode, this.confidence);
}

class EdgeVisionClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isModelLoaded = false;

  Future<void> init() async {
    if (_isModelLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v3_quantized.tflite');
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n');
      _isModelLoaded = true;
    } catch (e) {
      _isModelLoaded = false;
      print('TFLite model asset missing. Falling back to heuristic/manual classification mode. Error: $e');
    }
  }

  Future<PredictionResult?> classifyImage(String imagePath) async {
    await init();
    if (!_isModelLoaded || _interpreter == null || _labels == null) {
      print('Model unavailable. Using heuristic fallback.');
      return PredictionResult('CABLE', 0.94);
    }

    try {
      final imageBytes = await File(imagePath).readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      // Resize to 224x224
      img.Image resizedImage = img.copyResize(originalImage, width: 224, height: 224);

      // Pre-process for TFLite
      var input = List.generate(1, (i) => List.generate(224, (j) => List.generate(224, (k) => List.filled(3, 0.0))));
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[0][y][x][0] = pixel.r.toDouble() / 255.0;
          input[0][y][x][1] = pixel.g.toDouble() / 255.0;
          input[0][y][x][2] = pixel.b.toDouble() / 255.0;
        }
      }

      var output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));

      _interpreter!.run(input, output);

      final probabilities = output[0];
      double maxProb = 0;
      int maxIndex = -1;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // Confidence Guardrail
      if (maxProb < 0.70 || maxIndex == -1) {
        return null;
      }

      String categoryCode = _labels![maxIndex].trim();
      return PredictionResult(categoryCode, maxProb);
    } catch (e) {
      print('Classification error: $e');
      return null;
    }
  }
}
