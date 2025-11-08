import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../constants/app_constants.dart';
import '../models/meat_sample.dart';
import '../models/prediction_types.dart';
import '_label_stats.dart';

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

  /// Predict with multi-class support and enhanced confidence scores
  MultiClassPredictionResult predict(
    List<double> embedding,
    List<MeatSample> samples,
  ) {
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

    // Track stats for each label
    final labelStats = <String, LabelStats>{};

    // Collect statistics for each label
    for (final entry in kNearest) {
      final label = entry.key.label;
      final distance = entry.value;

      labelStats.putIfAbsent(label, () => LabelStats());
      labelStats[label]!.addSample(distance);
    }

    // Calculate confidence scores for each class
    final predictions = <ClassPrediction>[];

    for (final entry in labelStats.entries) {
      final label = entry.key;
      final stats = entry.value;

      // Confidence calculation factors:
      // 1. Vote ratio (how many times this label appears in k-NN)
      final voteConfidence = stats.count / k;

      // 2. Distance-based confidence (closer samples = higher confidence)
      // Normalize distances to 0-1 range with exponential decay
      final avgDistance = stats.averageDistance;
      final distanceConfidence = math.exp(-avgDistance);

      // Combined confidence score (weighted average)
      final confidence = (voteConfidence * 0.7 + distanceConfidence * 0.3)
          .clamp(0.0, 1.0);

      // Only include predictions above threshold
      if (confidence >= AppConstants.confidenceThreshold) {
        predictions.add(ClassPrediction(label: label, confidence: confidence));
      }
    }

    // Sort by confidence
    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Debug output
    for (final pred in predictions) {
      print('🎯 ${pred.label}: ${(pred.confidence * 100).toStringAsFixed(1)}%');
    }

    return MultiClassPredictionResult(
      predictions: predictions,
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

      // Check if any prediction matches the test sample label
      final matched = prediction.predictions.any(
        (p) => p.label == testSample.label,
      );

      if (matched) {
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
