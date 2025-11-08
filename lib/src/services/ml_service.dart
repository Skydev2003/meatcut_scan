import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../constants/app_constants.dart';
import '../models/meat_sample.dart';

/// Machine Learning service for embedding extraction and k-NN classification
class MLService {
  Interpreter? _interpreter;
  bool _isInitialized = false;
  int _embeddingSize = AppConstants.embeddingSize;

  /// Initialize the ML model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset(AppConstants.modelPath);

      // Get input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // Update embedding size from model
      _embeddingSize = outputShape.last;

      print('✅ ML Service initialized');
      print('📊 Input shape: $inputShape');
      print('📊 Output shape: $outputShape');
      print('📊 Embedding size: $_embeddingSize');

      _isInitialized = true;
    } catch (e) {
      print('❌ Error initializing ML service: $e');
      print('💡 Make sure MobileNet-v3-Large.tflite is in assets/models/');
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

      // Resize image for model input (224x224 for MobileNetV3)
      final resized = img.copyResize(
        image,
        width: AppConstants.imageSize,
        height: AppConstants.imageSize,
      );

      // Convert to normalized float array
      final input = _imageToByteListFloat32(resized);

      // Prepare output buffer
      final output = List.filled(
        _embeddingSize,
        0.0,
      ).reshape([1, _embeddingSize]);

      // Run inference
      _interpreter!.run(input, output);

      // Extract embedding (flatten output)
      final embedding = (output[0] as List).cast<double>();

      print('✅ Embedding extracted: ${embedding.length} dimensions');
      return embedding;
    } catch (e) {
      print('❌ Error extracting embedding: $e');
      rethrow;
    }
  }

  /// Convert image to normalized float32 array
  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image) {
    final convertedBytes = List.generate(
      1,
      (batch) => List.generate(
        AppConstants.imageSize,
        (y) => List.generate(AppConstants.imageSize, (x) {
          final pixel = image.getPixel(x, y);

          // Extract RGB values and normalize to [0, 1]
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;

          // Normalize to [-1, 1] for MobileNetV3
          return [(r - 0.5) * 2, (g - 0.5) * 2, (b - 0.5) * 2];
        }),
      ),
    );

    return convertedBytes;
  }

  /// Predict using k-NN algorithm
  PredictionResult predict(List<double> embedding, List<MeatSample> samples) {
    if (samples.isEmpty) {
      throw Exception('ยังไม่มีข้อมูลตัวอย่าง กรุณาเพิ่มข้อมูลก่อน');
    }

    // Validate embedding sizes
    final firstSampleSize = samples.first.embedding.length;
    if (embedding.length != firstSampleSize) {
      throw Exception(
        'ขนาด embedding ไม่ตรงกัน: ภาพใหม่ ${embedding.length} มิติ, '
        'ข้อมูลเก่า $firstSampleSize มิติ\n'
        'กรุณาลบข้อมูลเก่าและเพิ่มใหม่',
      );
    }

    // Calculate distances to all samples
    final distances = samples
        .map((sample) {
          try {
            final distance = _euclideanDistance(embedding, sample.embedding);
            return MapEntry(sample, distance);
          } catch (e) {
            print('⚠️ Skip sample ${sample.id}: $e');
            return null;
          }
        })
        .whereType<MapEntry<MeatSample, double>>()
        .toList();

    // Sort by distance
    distances.sort((a, b) => a.value.compareTo(b.value));

    // Get k nearest neighbors
    final k = math.min(AppConstants.kNeighbors, samples.length);
    final kNearest = distances.take(k).toList();

    // Count votes for each label
    final votes = <String, int>{};
    for (final entry in kNearest) {
      votes[entry.key.label] = (votes[entry.key.label] ?? 0) + 1;
    }

    // Find label with most votes
    final winner = votes.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Calculate confidence
    final confidence = winner.value / k;

    print(
      '🎯 Prediction: ${winner.key} (${(confidence * 100).toStringAsFixed(1)}%)',
    );
    print('📊 Votes: $votes');

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
    return math.sqrt(sum);
  }

  /// Calculate accuracy from test samples
  double calculateAccuracy(
    List<MeatSample> trainSamples,
    List<MeatSample> testSamples,
  ) {
    if (testSamples.isEmpty) return 0.0;

    int correct = 0;
    for (final testSample in testSamples) {
      final prediction = predict(testSample.embedding, trainSamples);
      if (prediction.label == testSample.label) {
        correct++;
      }
    }

    return correct / testSamples.length;
  }

  /// Get embedding size
  int get embeddingSize => _embeddingSize;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
    print('🔴 ML Service disposed');
  }
}
