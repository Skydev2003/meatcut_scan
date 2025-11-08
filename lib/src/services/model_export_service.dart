import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/meat_sample.dart';
import '../models/prediction_stats.dart';

/// Service for exporting and importing model data
class ModelExportService {
  /// Export model data to JSON file
  Future<File> exportToFile({
    required List<MeatSample> samples,
    required PredictionStats stats,
    required ModelVersion version,
  }) async {
    final data = {
      'version': version.toJson(),
      'stats': stats.toJson(),
      'samples': samples.map((s) => s.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/meatcut_model_$timestamp.json');

    await file.writeAsString(jsonString);

    print('✅ Exported to: ${file.path}');
    return file;
  }

  /// Share exported file
  Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'MeatCut Scan Model Data',
      text: 'โมเดล AI สำหรับจำแนกประเภทเนื้อ',
    );
  }

  /// Import model data from JSON file
  Future<ImportResult> importFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final version = ModelVersion.fromJson(data['version']);
      final stats = PredictionStats.fromJson(data['stats']);
      final samples = (data['samples'] as List)
          .map((json) => MeatSample.fromJson(json))
          .toList();

      return ImportResult(
        version: version,
        stats: stats,
        samples: samples,
        success: true,
      );
    } catch (e) {
      return ImportResult(success: false, error: e.toString());
    }
  }

  /// Export to Supabase
  Future<void> exportToSupabase({
    required List<MeatSample> samples,
    required String userId,
    required Function(MeatSample) uploadSample,
  }) async {
    for (final sample in samples) {
      await uploadSample(sample);
    }
    print('✅ Exported ${samples.length} samples to Supabase');
  }

  /// Get export file size
  Future<String> getFileSize(File file) async {
    final bytes = await file.length();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Result of import operation
class ImportResult {
  final ModelVersion? version;
  final PredictionStats? stats;
  final List<MeatSample>? samples;
  final bool success;
  final String? error;

  ImportResult({
    this.version,
    this.stats,
    this.samples,
    required this.success,
    this.error,
  });
}
