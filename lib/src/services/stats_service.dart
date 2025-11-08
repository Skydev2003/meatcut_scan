import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_stats.dart';

/// Statistics service for tracking predictions
class StatsService {
  SharedPreferences? _prefs;
  static const String _statsKey = 'prediction_stats';
  static const String _modelVersionKey = 'model_version_info';

  /// Initialize storage
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load statistics
  Future<PredictionStats> loadStats() async {
    await initialize();
    final jsonString = _prefs!.getString(_statsKey);
    if (jsonString == null) return PredictionStats.empty();

    try {
      final json = jsonDecode(jsonString);
      return PredictionStats.fromJson(json);
    } catch (e) {
      print('Error loading stats: $e');
      return PredictionStats.empty();
    }
  }

  /// Save statistics
  Future<void> saveStats(PredictionStats stats) async {
    await initialize();
    final jsonString = jsonEncode(stats.toJson());
    await _prefs!.setString(_statsKey, jsonString);
  }

  /// Record a prediction
  Future<void> recordPrediction({
    required String predictedLabel,
    required String actualLabel,
  }) async {
    final stats = await loadStats();

    final isCorrect = predictedLabel == actualLabel;
    final newTotal = stats.totalPredictions + 1;
    final newCorrect = stats.correctPredictions + (isCorrect ? 1 : 0);

    // Update label counts
    final labelCounts = Map<String, int>.from(stats.labelCounts);
    labelCounts[actualLabel] = (labelCounts[actualLabel] ?? 0) + 1;

    // Update label accuracies
    final labelAccuracies = Map<String, double>.from(stats.labelAccuracies);
    final labelTotal = labelCounts[actualLabel]!;
    final labelCorrect =
        (labelAccuracies[actualLabel] ?? 0.0) * (labelTotal - 1);
    labelAccuracies[actualLabel] =
        (labelCorrect + (isCorrect ? 1 : 0)) / labelTotal;

    final newStats = PredictionStats(
      totalPredictions: newTotal,
      correctPredictions: newCorrect,
      accuracy: newCorrect / newTotal,
      labelCounts: labelCounts,
      labelAccuracies: labelAccuracies,
      lastUpdated: DateTime.now(),
    );

    await saveStats(newStats);
  }

  /// Clear statistics
  Future<void> clearStats() async {
    await initialize();
    await _prefs!.remove(_statsKey);
  }

  /// Load model version
  Future<ModelVersion> loadModelVersion() async {
    await initialize();
    final jsonString = _prefs!.getString(_modelVersionKey);
    if (jsonString == null) return ModelVersion.current();

    try {
      final json = jsonDecode(jsonString);
      return ModelVersion.fromJson(json);
    } catch (e) {
      print('Error loading model version: $e');
      return ModelVersion.current();
    }
  }

  /// Save model version
  Future<void> saveModelVersion(ModelVersion version) async {
    await initialize();
    final jsonString = jsonEncode(version.toJson());
    await _prefs!.setString(_modelVersionKey, jsonString);
  }

  /// Update model version
  Future<void> updateModelVersion({
    required String version,
    required String modelName,
    required int embeddingSize,
    String? description,
  }) async {
    final newVersion = ModelVersion(
      version: version,
      modelName: modelName,
      embeddingSize: embeddingSize,
      createdAt: DateTime.now(),
      description: description,
    );

    await saveModelVersion(newVersion);
  }
}
