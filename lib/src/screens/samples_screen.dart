import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/samples_provider.dart';
import '../models/meat_sample.dart';
import '../theme/app_theme.dart';

class SamplesScreen extends ConsumerWidget {
  const SamplesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsync = ref.watch(samplesNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
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
                        Icons.dataset,
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
                            'ข้อมูลตัวอย่าง',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ดูและจัดการข้อมูลการเรียนรู้',
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

              // Content
              Expanded(
                child: samplesAsync.when(
                  data: (samples) {
                    if (samples.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    // Group by label
                    final groupedSamples = <String, List<MeatSample>>{};
                    for (final sample in samples) {
                      groupedSamples
                          .putIfAbsent(sample.label, () => [])
                          .add(sample);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.read(samplesNotifierProvider.notifier).refresh();
                      },
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: groupedSamples.length,
                        itemBuilder: (context, index) {
                          final label = groupedSamples.keys.elementAt(index);
                          final labelSamples = groupedSamples[label]!;

                          return _buildLabelGroup(
                            context,
                            label,
                            labelSamples,
                            ref,
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'เกิดข้อผิดพลาด',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: const TextStyle(color: AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.folder_open,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ยังไม่มีข้อมูลตัวอย่าง',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'เริ่มต้นโดยการถ่ายภาพและเพิ่มข้อมูล',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelGroup(
    BuildContext context,
    String label,
    List<MeatSample> samples,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.label, color: Colors.white, size: 24),
          ),
          title: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${samples.length} ตัวอย่าง',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          children: samples.map((sample) {
            return _buildSampleItem(context, sample, ref);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSampleItem(
    BuildContext context,
    MeatSample sample,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${sample.id.substring(0, 8)}...',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Embedding: ${sample.embedding.length} มิติ',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (sample.createdAt != null)
                  Text(
                    _formatDate(sample.createdAt!),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Delete button
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.errorColor,
              size: 20,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.darkCard,
                  title: const Text(
                    'ลบข้อมูล',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  content: const Text(
                    'ต้องการลบข้อมูลตัวอย่างนี้หรือไม่?',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('ยกเลิก'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('ลบ'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // TODO: Implement delete single sample
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'ฟีเจอร์ลบข้อมูลเดี่ยวจะพร้อมในเวอร์ชันถัดไป',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
