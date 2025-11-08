import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/meat_sample.dart';
import '../constants/app_constants.dart';

/// Service for exporting TensorFlow Lite models
class TFLiteExportService {
  static const String _assetKey = 'assets/models/MobileNet-v3-Large.tflite';

  /// Export current model as TFLite file
  Future<File> exportTFLiteModel() async {
    try {
      // Load model from assets
      final ByteData modelData = await rootBundle.load(_assetKey);

      // Create export directory if not exists
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/exported_models');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // Create version-specific file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportPath =
          '${exportDir.path}/meatcut_model_v${AppConstants.appVersion}_$timestamp.tflite';

      // Write model data to file
      final File exportFile = File(exportPath);
      await exportFile.writeAsBytes(
        modelData.buffer.asUint8List(
          modelData.offsetInBytes,
          modelData.lengthInBytes,
        ),
      );

      print('✅ Exported TFLite model to: $exportPath');
      return File(exportPath);
    } catch (e) {
      print('❌ Error exporting TFLite model: $e');
      rethrow;
    }
  }

  /// Export model with metadata
  Future<File> exportTFLiteWithMetadata({
    required List<MeatSample> samples,
    required Map<String, dynamic> metadata,
  }) async {
    // This is a placeholder for future implementation of custom metadata
    // TODO: Add metadata embedding into TFLite file
    // For now, just export the base model
    return exportTFLiteModel();
  }

  /// Get list of available model versions
  Future<List<File>> getAvailableModels() async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exported_models');

    if (!await exportDir.exists()) {
      return [];
    }

    final files = await exportDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.tflite'))
        .map((e) => File(e.path))
        .toList();

    return files;
  }

  /// Delete exported model
  Future<void> deleteModel(File modelFile) async {
    if (await modelFile.exists()) {
      await modelFile.delete();
    }
  }
}
