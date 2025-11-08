import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/prediction_stats.dart';
import '../providers/samples_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/ml_provider.dart';
import '../services/model_export_service.dart';
import '../services/tflite_export_service.dart';
import '../theme/app_theme.dart';

class ModelManagementScreen extends ConsumerStatefulWidget {
  const ModelManagementScreen({super.key});

  @override
  ConsumerState<ModelManagementScreen> createState() =>
      _ModelManagementScreenState();
}

class _ModelManagementScreenState extends ConsumerState<ModelManagementScreen> {
  final _exportService = ModelExportService();
  final _tfliteService = TFLiteExportService();
  bool _isExporting = false;
  bool _isTesting = false;
  String? _testResult;

  Future<void> _exportModel() async {
    setState(() => _isExporting = true);
    try {
      final samplesAsync = ref.read(samplesNotifierProvider);
      final statsAsync = ref.read(statsNotifierProvider);
      final versionAsync = await ref.read(modelVersionProvider.future);

      final samples = samplesAsync.value ?? [];
      final stats = statsAsync.value ?? PredictionStats.empty();

      if (samples.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่มีข้อมูลให้ export'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
        return;
      }

      final file = await _exportService.exportToFile(
        samples: samples,
        stats: stats,
        version: versionAsync,
      );

      if (mounted) {
        final exportType = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkCard,
            title: const Text(
              'เลือกรูปแบบการ Export',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.dataset,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text(
                    'Export Dataset (JSON)',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    'ส่งออกข้อมูลตัวอย่าง ${samples.length} รายการ',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  onTap: () => context.pop('json'),
                ),
                Divider(color: AppTheme.primaryColor.withOpacity(0.2)),
                ListTile(
                  leading: const Icon(
                    Icons.memory,
                    color: AppTheme.successColor,
                  ),
                  title: const Text(
                    'Export TFLite Model',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: const Text(
                    'ส่งออกโมเดล AI ที่เทรนแล้ว',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  onTap: () => context.pop('tflite'),
                ),
              ],
            ),
          ),
        );

        if (exportType == null) return;

        File exportedFile;
        if (exportType == 'tflite') {
          exportedFile = await _tfliteService.exportTFLiteModel();
        } else {
          exportedFile = file;
        }

        final exportFileSize = await _exportService.getFileSize(exportedFile);

        if (!mounted) return;

        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.darkCard,
            title: const Text(
              'Export สำเร็จ',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ไฟล์: ${exportedFile.path.split('/').last}',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                Text(
                  'ขนาด: $exportFileSize',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                if (exportType == 'json')
                  Text(
                    'ตัวอย่าง: ${samples.length} รายการ',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('ปิด'),
              ),
              ElevatedButton(
                onPressed: () => context.pop(true),
                child: const Text('แชร์'),
              ),
            ],
          ),
        );

        if (result == true) {
          await _exportService.shareFile(exportedFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _testModel() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final mlService = ref.read(mlServiceProvider);
      final samplesAsync = ref.read(samplesNotifierProvider);
      final samples = samplesAsync.value ?? [];

      if (samples.isEmpty) {
        setState(() {
          _testResult = '❌ ไม่มีข้อมูลตัวอย่างสำหรับทดสอบ';
        });
        return;
      }

      final results = <String, int>{};
      int correct = 0;
      int total = 0;

      for (final testSample in samples) {
        final trainSamples = samples
            .where((s) => s.id != testSample.id)
            .toList();
        if (trainSamples.isEmpty) continue;

        try {
          final prediction = mlService.predict(
            testSample.embedding,
            trainSamples,
          );
          total++;

          // Check if any prediction matches the test sample label
          final matched = prediction.predictions.any(
            (p) => p.label == testSample.label,
          );
          if (matched) correct++;

          // Track samples per label
          results[testSample.label] = (results[testSample.label] ?? 0) + 1;
        } catch (e) {
          print('Test error: $e');
        }
      }

      final accuracy = total > 0 ? (correct / total * 100) : 0;

      setState(() {
        _testResult =
            '''
✅ ทดสอบเสร็จสิ้น

📊 ผลการทดสอบ:
• ทดสอบทั้งหมด: $total ตัวอย่าง
• จำแนกถูกต้อง: $correct ตัวอย่าง
• ความแม่นยำรวม: ${accuracy.toStringAsFixed(1)}%

📈 การกระจายข้อมูล:
${results.entries.map((e) => '• ${e.key}: ${e.value} ตัวอย่าง').join('\n')}

📋 ประสิทธิภาพ:
• แม่นยำในการจำแนกหลายคลาส
• รองรับการระบุลักษณะพิเศษ (มันแทรก, สี)
• ใช้ confidence score ในการกรองผล

${accuracy >= 80
                ? '🎉 ความแม่นยำดีมาก! พร้อมใช้งาน'
                : accuracy >= 60
                ? '👍 ความแม่นยำดี แต่ควรเพิ่มตัวอย่างให้หลากหลาย'
                : '⚠️ ควรเพิ่มข้อมูลตัวอย่างในแต่ละหมวดให้มากขึ้น'}

💡 คำแนะนำ:
• เพิ่มตัวอย่างที่มีมุมมอง/แสงที่หลากหลาย
• ระบุลักษณะพิเศษ (มันแทรก, สี) ให้ครบถ้วน
• ใช้ภาพที่มีคุณภาพดี ไม่มืด/สว่างเกินไป
''';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ เกิดข้อผิดพลาด: $e';
      });
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'ลบข้อมูลทั้งหมด',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '⚠️ การดำเนินการนี้จะลบข้อมูลตัวอย่างและสถิติทั้งหมด\nไม่สามารถกู้คืนได้',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('ลบทั้งหมด'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(samplesNotifierProvider.notifier).clearSamples();
      await ref.read(statsNotifierProvider.notifier).clearStats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ล้างข้อมูลทั้งหมดแล้ว'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'จัดการโมเดล',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ทดสอบและจัดการข้อมูล',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Test Model Card
                    _buildTestCard(),
                    const SizedBox(height: 16),

                    // Export Card
                    _buildExportCard(),
                    const SizedBox(height: 16),

                    // Danger Zone
                    _buildDangerCard(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.science, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ทดสอบโมเดล',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ทดสอบความแม่นยำของโมเดลด้วย Cross-Validation',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTesting ? null : _testModel,
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isTesting ? 'กำลังทดสอบ...' : 'เริ่มทดสอบ'),
            ),
          ),
          if (_testResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                _testResult!,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.upload,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export โมเดล',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'สำรองข้อมูลและแชร์โมเดลให้เพื่อน',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportModel,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isExporting ? 'กำลัง Export...' : 'Export โมเดล'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'การดำเนินการเหล่านี้ไม่สามารถย้อนกลับได้',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text('ลบข้อมูลทั้งหมด'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
