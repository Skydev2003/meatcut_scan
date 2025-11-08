import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prediction_stats.dart';
import '../services/stats_service.dart';

/// Stats service provider
final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService();
});

/// Prediction stats provider
final predictionStatsProvider = FutureProvider<PredictionStats>((ref) async {
  final service = ref.watch(statsServiceProvider);
  return await service.loadStats();
});

/// Model version provider
final modelVersionProvider = FutureProvider<ModelVersion>((ref) async {
  final service = ref.watch(statsServiceProvider);
  return await service.loadModelVersion();
});

/// Stats notifier for mutations
final statsNotifierProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<PredictionStats>>((ref) {
      return StatsNotifier(ref);
    });

class StatsNotifier extends StateNotifier<AsyncValue<PredictionStats>> {
  final Ref _ref;

  StatsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(statsServiceProvider);
      final stats = await service.loadStats();
      state = AsyncValue.data(stats);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> recordPrediction({
    required String predictedLabel,
    required String actualLabel,
  }) async {
    final service = _ref.read(statsServiceProvider);
    await service.recordPrediction(
      predictedLabel: predictedLabel,
      actualLabel: actualLabel,
    );
    await _loadStats();
  }

  Future<void> clearStats() async {
    final service = _ref.read(statsServiceProvider);
    await service.clearStats();
    await _loadStats();
  }

  void refresh() {
    _loadStats();
  }
}
