import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/samples_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final samplesAsync = ref.watch(samplesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ยินดีต้อนรับ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      authState.maybeWhen(
                        authenticated: (userId, email) => Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        orElse: () => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Training samples info
              samplesAsync.when(
                data: (samples) => Card(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ตัวอย่างการเรียนรู้',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${samples.length} ตัวอย่าง',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Scan button
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/capture');
                },
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text('สแกนเนื้อ', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Features
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: const [
                    _FeatureCard(
                      icon: Icons.analytics,
                      title: 'วิเคราะห์',
                      description: 'ระบุประเภทเนื้อ',
                      color: AppTheme.primaryColor,
                    ),
                    _FeatureCard(
                      icon: Icons.add_circle,
                      title: 'เพิ่มข้อมูล',
                      description: 'สอนแอปเรียนรู้',
                      color: AppTheme.secondaryColor,
                    ),
                    _FeatureCard(
                      icon: Icons.cloud_upload,
                      title: 'ซิงค์คลาวด์',
                      description: 'บันทึกข้อมูล',
                      color: AppTheme.warningColor,
                    ),
                    _FeatureCard(
                      icon: Icons.offline_bolt,
                      title: 'ออฟไลน์',
                      description: 'ใช้งานได้ทุกที่',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
