import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'prediction_types.freezed.dart';
part 'prediction_types.g.dart';

/// Single class prediction result with confidence score
@freezed
class ClassPrediction with _$ClassPrediction {
  const factory ClassPrediction({
    required String label,
    required double confidence,
    String? category,
    Map<String, dynamic>? metadata,
  }) = _ClassPrediction;

  factory ClassPrediction.fromJson(Map<String, dynamic> json) =>
      _$ClassPredictionFromJson(json);
}

/// Multi-class prediction result containing multiple detections
@freezed
class MultiClassPredictionResult with _$MultiClassPredictionResult {
  const factory MultiClassPredictionResult({
    required List<ClassPrediction> predictions,
    required List<double> embedding,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) = _MultiClassPredictionResult;

  factory MultiClassPredictionResult.fromJson(Map<String, dynamic> json) =>
      _$MultiClassPredictionResultFromJson(json);
}
