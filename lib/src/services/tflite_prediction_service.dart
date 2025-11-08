import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class TFLitePredictionService {
  static Interpreter? _interpreter;
  final Map<String, int> _predictionCounts = {};
  final Map<String, List<double>> _accuracies = {};

  Future<void> loadModel({File? customModel}) async {
    try {
      if (_interpreter != null) {
        _interpreter!.close();
      }

      if (customModel != null) {
        _interpreter = Interpreter.fromFile(customModel);
      } else {
        _interpreter = await Interpreter.fromAsset(
          'assets/models/MobileNet-v3-Large.tflite',
        );
      }
    } catch (e) {
      print('❌ Error loading TFLite model: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> runInference(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Model not loaded');
    }

    try {
      // Load and preprocess image
      final imageData = await imageFile.readAsBytes();
      final image = img.decodeImage(imageData);
      if (image == null) throw Exception('Failed to decode image');

      // Resize image to match model input
      final resized = img.copyResize(image, width: 224, height: 224);

      // Convert to float32 array and normalize
      var input = List.generate(
        1,
        (index) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) => List.generate(3, (c) {
              final pixel = resized.getPixel(x, y);
              final r = pixel.r;
              final g = pixel.g;
              final b = pixel.b;
              return c == 0
                  ? r / 255.0
                  : c == 1
                  ? g / 255.0
                  : b / 255.0;
            }),
          ),
        ),
      );

      // Prepare output tensor
      var output = List.filled(1 * 1000, 0.0).reshape([1, 1000]);

      // Run inference
      _interpreter!.run(input, output);

      // Process results
      var results = Map<String, double>.fromIterables(
        ['beef', 'pork', 'chicken', 'lamb', 'fish'], // Example labels
        output[0].sublist(0, 5), // Take first 5 predictions
      );

      // Update statistics
      _updateStats(results);

      return results;
    } catch (e) {
      print('❌ Error running inference: $e');
      rethrow;
    }
  }

  void _updateStats(Map<String, double> predictions) {
    final topPrediction = predictions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    _predictionCounts.update(
      topPrediction,
      (value) => value + 1,
      ifAbsent: () => 1,
    );

    _accuracies.update(
      topPrediction,
      (values) => [...values, predictions[topPrediction]!],
      ifAbsent: () => [predictions[topPrediction]!],
    );
  }

  Map<String, int> getPredictionCounts() {
    return Map.from(_predictionCounts);
  }

  Map<String, double> getAverageAccuracies() {
    return _accuracies.map(
      (key, values) =>
          MapEntry(key, values.reduce((a, b) => a + b) / values.length),
    );
  }

  Future<void> saveStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/prediction_stats.json');

      final data = {'counts': _predictionCounts, 'accuracies': _accuracies};

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('❌ Error saving prediction stats: $e');
    }
  }

  Future<void> loadStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/prediction_stats.json');

      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());

        _predictionCounts.clear();
        _predictionCounts.addAll(Map<String, int>.from(data['counts']));

        _accuracies.clear();
        _accuracies.addAll(
          Map<String, List<double>>.from(
            data['accuracies'].map(
              (key, values) => MapEntry(key, List<double>.from(values)),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error loading prediction stats: $e');
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
