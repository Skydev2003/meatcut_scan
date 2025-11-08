import 'package:freezed_annotation/freezed_annotation.dart';

part 'meat_sample.freezed.dart';
part 'meat_sample.g.dart';

/// Represents a training sample with embedding and label
@freezed
class MeatSample with _$MeatSample {
  const factory MeatSample({
    required String id,
    required String label,
    required List<double> embedding,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
  }) = _MeatSample;

  factory MeatSample.fromJson(Map<String, dynamic> json) =>
      _$MeatSampleFromJson(json);
}

/// Prediction result with confidence score
@freezed
class PredictionResult with _$PredictionResult {
  const factory PredictionResult({
    required String label,
    required double confidence,
    required List<double> embedding,
  }) = _PredictionResult;

  factory PredictionResult.fromJson(Map<String, dynamic> json) =>
      _$PredictionResultFromJson(json);
}
