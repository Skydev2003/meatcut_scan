import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ml_service.dart';

/// ML service provider
final mlServiceProvider = Provider<MLService>((ref) {
  final service = MLService();
  ref.onDispose(() => service.dispose());
  return service;
});
