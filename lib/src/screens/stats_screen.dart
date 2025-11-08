import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/stats_provider.dart';
import '../providers/samples_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsNotifierProvider);
    final samplesAsync = ref.watch(samplesNotifierProvider);
    final modelVersionAsync = ref.watch(modelVersionProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.read(statsNotifierProvider.notifier).refresh();
              ref.read(samplesNotifierProvider.notifier).refresh();
            },
            color: AppTheme.primaryColor,
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
                            Icons.analytics,
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
                                'สถิติและข้อมูล',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'ภาพรวมประสิทธิภาพโมเดล',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            context.push('/model-management');
                          },
                          tooltip: 'จัดการโมเดล',
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Model Version Card
                      modelVersionAsync.when(
                        data: (version) => _buildModelCard(context, version),
                        loading: () => _buildLoadingCard(),
                        error: (e, _) => _buildErrorCard(e.toString()),
                      ),
                      const SizedBox(height: 16),

                      // Training Data Card
                      samplesAsync.when(
                        data: (samples) => _buildTrainingDataCard(
                          context,
                          samples.length,
                          ref,
                        ),
                        loading: () => _buildLoadingCard(),
                        error: (e, _) => _buildErrorCard(e.toString()),
                      ),
                      const SizedBox(height: 16),

                      // Prediction Stats Card
                      statsAsync.when(
                        data: (stats) =>
                            _buildPredictionStatsCard(context, stats, ref),
                        loading: () => _buildLoadingCard(),
                        error: (e, _) => _buildErrorCard(e.toString()),
                      ),
                      const SizedBox(height: 100), // Space for bottom nav
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModelCard(BuildContext context, version) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.1),
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
                  color: AppTheme.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.model_training,
                  color: AppTheme.accentGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'โมเดล AI',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.textMuted),
          _buildInfoRow('ชื่อโมเดล', version.modelName),
          _buildInfoRow('เวอร์ชัน', version.version),
          _buildInfoRow('ขนาด Embedding', '${version.embeddingSize} มิติ'),
          if (version.description != null)
            _buildInfoRow('รายละเอียด', version.description!),
        ],
      ),
    );
  }

  Widget _buildTrainingDataCard(
    BuildContext context,
    int sampleCount,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDark.withOpacity(0.3),
            AppTheme.primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.5),
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
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dataset, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ข้อมูลการเรียนรู้',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  '$sampleCount',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'ตัวอย่างทั้งหมด',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.darkCard,
                        title: const Text(
                          'ลบข้อมูลทั้งหมด',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                        content: const Text(
                          '⚠️ การดำเนินการนี้จะลบข้อมูลตัวอย่างทั้งหมด\nไม่สามารถกู้คืนได้',
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
                            child: const Text('ลบทั้งหมด'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref
                          .read(samplesNotifierProvider.notifier)
                          .clearSamples();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ลบข้อมูลทั้งหมดแล้ว'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('ลบข้อมูลทั้งหมด'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionStatsCard(BuildContext context, stats, WidgetRef ref) {
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
                  Icons.analytics,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'สถิติการทำนาย',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.textMuted),
          if (stats.totalPredictions > 0) ...[
            _buildInfoRow('จำนวนการทำนาย', '${stats.totalPredictions} ครั้ง'),
            _buildInfoRow('ทำนายถูก', '${stats.correctPredictions} ครั้ง'),
            const SizedBox(height: 16),
            // Accuracy Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ความแม่นยำ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(stats.accuracy * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.accuracy,
                  backgroundColor: AppTheme.darkSurface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.successColor,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Clear Stats Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.darkCard,
                      title: const Text(
                        'ล้างสถิติ',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      content: const Text(
                        'ต้องการล้างสถิติการทำนายทั้งหมดหรือไม่?',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('ยกเลิก'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('ล้าง'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref.read(statsNotifierProvider.notifier).clearStats();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ล้างสถิติแล้ว'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('ล้างสถิติ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningColor,
                  side: const BorderSide(color: AppTheme.warningColor),
                ),
              ),
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: AppTheme.textMuted),
                    SizedBox(height: 16),
                    Text(
                      'ยังไม่มีข้อมูลสถิติ',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Text(
        'Error: $error',
        style: const TextStyle(color: AppTheme.errorColor),
      ),
    );
  }
}
