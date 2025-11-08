import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../models/meat_sample.dart';
import '../providers/ml_provider.dart';
import '../providers/samples_provider.dart';
import '../theme/app_theme.dart';

class PredictScreen extends ConsumerStatefulWidget {
  final List<int>? imageBytes;

  const PredictScreen({super.key, this.imageBytes});

  @override
  ConsumerState<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends ConsumerState<PredictScreen> {
  PredictionResult? _prediction;
  bool _isLoading = false;
  String? _selectedLabel;

  @override
  void initState() {
    super.initState();
    if (widget.imageBytes != null) {
      _predict();
    }
  }

  Future<void> _predict() async {
    if (widget.imageBytes == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mlService = ref.read(mlServiceProvider);
      final samplesAsync = ref.read(samplesNotifierProvider);

      final samples = samplesAsync.value ?? [];

      if (samples.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ยังไม่มีข้อมูลตัวอย่าง กรุณาเพิ่มข้อมูลก่อน'),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final embedding = await mlService.extractEmbedding(
        Uint8List.fromList(widget.imageBytes!),
      );

      final prediction = mlService.predict(embedding, samples);

      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTrainingSample() async {
    if (_selectedLabel == null || widget.imageBytes == null) return;

    try {
      final mlService = ref.read(mlServiceProvider);
      final embedding = await mlService.extractEmbedding(
        Uint8List.fromList(widget.imageBytes!),
      );

      final sample = MeatSample(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: _selectedLabel!,
        embedding: embedding,
        createdAt: DateTime.now(),
      );

      await ref.read(samplesNotifierProvider.notifier).addSample(sample);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มข้อมูลตัวอย่างสำเร็จ')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ผลการวิเคราะห์')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              if (widget.imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    Uint8List.fromList(widget.imageBytes!),
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 24),

              // Prediction result
              if (_isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('กำลังวิเคราะห์...'),
                    ],
                  ),
                )
              else if (_prediction != null)
                Card(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 64,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ประเภทเนื้อ',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _prediction!.label,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _prediction!.confidence,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ความมั่นใจ: ${(_prediction!.confidence * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Add training sample section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เพิ่มเป็นข้อมูลตัวอย่าง',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text('ช่วยให้แอปเรียนรู้และทำนายได้แม่นยำขึ้น'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLabel,
                        decoration: const InputDecoration(
                          labelText: 'เลือกประเภทเนื้อ',
                          border: OutlineInputBorder(),
                        ),
                        items: AppConstants.meatTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLabel = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _selectedLabel != null
                              ? _addTrainingSample
                              : null,
                          icon: const Icon(Icons.add),
                          label: const Text('เพิ่มข้อมูล'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
