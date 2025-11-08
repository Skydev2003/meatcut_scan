import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';
import '../models/meat_sample.dart';

/// Machine Learning service for embedding extraction and k-NN classification
class MLService {
  // TODO: Initialize TFLite interpreter
  // Interpreter? _interpreter;
  bool _isInitialized = false;

  /// Initialize the ML model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // TODO: Load TFLite model
      // _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);
      _isInitialized = true;
      print('ML Service initialized');
    } catch (e) {
      print('Error initializing ML service: $e');
      rethrow;
    }
  }

  /// Extract embedding from image bytes
  Future<List<double>> extractEmbedding(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Decode and preprocess image
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');

      // Resize image for model input
      img.copyResize(
        image,
        width: AppConstants.imageSize,
        height: AppConstants.imageSize,
      );

      // TODO: Run inference with TFLite
      // For now, return dummy embedding
      return List.generate(AppConstants.embeddingSize, (i) => i * 0.001);
    } catch (e) {
      print('Error extracting embedding: $e');
      rethrow;
    }
  }

  /// Predict using k-NN algorithm
  PredictionResult predict(List<double> embedding, List<MeatSample> samples) {
    if (samples.isEmpty) {
      throw Exception('No training samples available');
    }

    // Calculate distances to all samples
    final distances = samples.map((sample) {
      final distance = _euclideanDistance(embedding, sample.embedding);
      return MapEntry(sample, distance);
    }).toList();

    // Sort by distance
    distances.sort((a, b) => a.value.compareTo(b.value));

    // Get k nearest neighbors
    final kNearest = distances.take(AppConstants.kNeighbors).toList();

    // Count votes for each label
    final votes = <String, int>{};
    for (final entry in kNearest) {
      votes[entry.key.label] = (votes[entry.key.label] ?? 0) + 1;
    }

    // Find label with most votes
    final winner = votes.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Calculate confidence
    final confidence = winner.value / AppConstants.kNeighbors;

    return PredictionResult(
      label: winner.key,
      confidence: confidence,
      embedding: embedding,
    );
  }

  /// Calculate Euclidean distance between two embeddings
  double _euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Embeddings must have same length');
    }

    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sum; // No need for sqrt for comparison
  }

  /// Dispose resources
  void dispose() {
    // _interpreter?.close();
    _isInitialized = false;
  }
}
