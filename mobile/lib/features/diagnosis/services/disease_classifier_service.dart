import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:flutter_litert/flutter_litert.dart';
import '../models/diagnosis_result.dart';

class DiseaseClassifierService {
  DiseaseClassifierService._();

  static const String _modelPath =
      'assets/models/poultryguard_disease_model.tflite';

  static const int _imageSize = 224;

  // IMPORTANT:
  // This order must match the model's training output order.
  static const List<String> _labels = [
    'Coccidiosis',
    'Healthy',
    'Newcastle Disease',
    'Salmonellosis',
  ];

  static Interpreter? _interpreter;

  static Future<Interpreter> _getInterpreter() async {
    if (_interpreter != null) {
      return _interpreter!;
    }

    _interpreter = await Interpreter.fromAsset(_modelPath);

    return _interpreter!;
  }

  static Future<DiagnosisResult> classifyImage(String imagePath) async {
    final interpreter = await _getInterpreter();

    final file = File(imagePath);

    if (!await file.exists()) {
      throw Exception('Selected image could not be found.');
    }

    final imageBytes = await file.readAsBytes();

    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Unable to decode the selected image.');
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: _imageSize,
      height: _imageSize,
      interpolation: img.Interpolation.linear,
    );

    final input = _createInputTensor(resizedImage);

    final output = [List<double>.filled(_labels.length, 0.0)];

    interpreter.run(input, output);

    final probabilities = output[0];

    int bestIndex = 0;

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[bestIndex]) {
        bestIndex = i;
      }
    }

    final confidence = probabilities[bestIndex];

    return DiagnosisResult(
      label: _labels[bestIndex],
      confidence: confidence,
      imagePath: imagePath,
    );
  }

  static List<List<List<List<double>>>> _createInputTensor(img.Image image) {
    return [
      List.generate(_imageSize, (y) {
        return List.generate(_imageSize, (x) {
          final pixel = image.getPixel(x, y);

          return [pixel.r.toDouble(), pixel.g.toDouble(), pixel.b.toDouble()];
        });
      }),
    ];
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
