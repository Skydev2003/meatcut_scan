import 'package:freezed_annotation/freezed_annotation.dart';

part 'prediction_stats.freezed.dart';
part 'prediction_stats.g.dart';

/// Statistics for predictions
@freezed
class PredictionStats with _$PredictionStats {
  const factory PredictionStats({
    required int totalPredictions,
    required int correctPredictions,
    required double accuracy,
    required Map<String, int> labelCounts,
    required Map<String, double> labelAccuracies,
    DateTime? lastUpdated,
  }) = _PredictionStats;

  factory PredictionStats.fromJson(Map<String, dynamic> json) =>
      _$PredictionStatsFromJson(json);

  factory PredictionStats.empty() => const PredictionStats(
    totalPredictions: 0,
    correctPredictions: 0,
    accuracy: 0.0,
    labelCounts: {},
    labelAccuracies: {},
  );
}

/// Model version info
@freezed
class ModelVersion with _$ModelVersion {
  const factory ModelVersion({
    required String version,
    required String modelName,
    required int embeddingSize,
    required DateTime createdAt,
    String? description,
  }) = _ModelVersion;

  factory ModelVersion.fromJson(Map<String, dynamic> json) =>
      _$ModelVersionFromJson(json);

  factory ModelVersion.current() => ModelVersion(
    version: '1.0.0',
    modelName: 'MobileNet-v3-Large',
    embeddingSize: 1280,
    createdAt: DateTime.now(),
    description: 'MobileNetV3 Large for meat classification',
  );
}
