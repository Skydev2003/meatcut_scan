import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meat_sample.dart';
import 'storage_provider.dart';

/// Training samples provider
final samplesProvider = FutureProvider<List<MeatSample>>((ref) async {
  final storage = ref.watch(storageServiceProvider);
  return await storage.loadSamples();
});

/// Samples notifier for mutations
final samplesNotifierProvider =
    StateNotifierProvider<SamplesNotifier, AsyncValue<List<MeatSample>>>((ref) {
      return SamplesNotifier(ref);
    });

class SamplesNotifier extends StateNotifier<AsyncValue<List<MeatSample>>> {
  final Ref _ref;

  SamplesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSamples();
  }

  Future<void> _loadSamples() async {
    state = const AsyncValue.loading();
    try {
      final storage = _ref.read(storageServiceProvider);
      final samples = await storage.loadSamples();
      state = AsyncValue.data(samples);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addSample(MeatSample sample) async {
    final storage = _ref.read(storageServiceProvider);
    await storage.addSample(sample);
    await _loadSamples();
  }

  Future<void> clearSamples() async {
    final storage = _ref.read(storageServiceProvider);
    await storage.clearSamples();
    await _loadSamples();
  }

  void refresh() {
    _loadSamples();
  }
}
