import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

// Dashboard data provider
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final healthResp = await api.get(ApiConstants.health, queryParameters: {'limit': '5'});
    final statsResp = await api.get(ApiConstants.healthStats, queryParameters: {'record_type': 'GLUCOSE'});
    
    final recentRaw = healthResp.data;
    final recentList = recentRaw is Map && recentRaw.containsKey('items') 
        ? recentRaw['items'] as List 
        : [];
        
    return {
      'recent': recentList,
      'stats': statsResp.data ?? {},
    };
  } catch (_) {
    return {'recent': [], 'stats': {}};
  }
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Diyabet Takip',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick action card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kan Şekeri Takibi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Bugün',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      dashboard.when(
                        data: (data) {
                          final stats = data['stats'] as Map<String, dynamic>;
                          final avg = stats['average_glucose']?.toString() ?? '--';
                          return Row(
                            children: [
                              Text(
                                avg,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'mg/dL\nort.',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(color: Colors.white),
                        error: (_, __) => const Text('--', style: TextStyle(color: Colors.white, fontSize: 42)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/health'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Yeni Ölçüm Ekle'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Stats Grid
                const Text('Hızlı Bakış', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard('AI Asistan', Icons.chat, AppColors.accent, () => context.go('/chat'))),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Analizler', Icons.analytics, AppColors.info, () => context.go('/analytics'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _statCard('Kayıt Ekle', Icons.add_circle, AppColors.success, () => context.go('/health'))),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Profilim', Icons.person, AppColors.warning, () => context.go('/profile'))),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent records
                const Text('Son Kayıtlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                dashboard.when(
                  data: (data) {
                    final recent = data['recent'] as List;
                    if (recent.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('Henüz kayıt yok.\nİlk ölçümünüzü ekleyin!', textAlign: TextAlign.center),
                        ),
                      );
                    }
                    return Column(
                      children: recent.take(5).map<Widget>((r) => _recordTile(r)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Veriler yüklenemedi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _recordTile(Map<String, dynamic> record) {
    final glucose = record['blood_sugar']?.toString() ?? '--';
    final glucoseNum = double.tryParse(glucose) ?? 0;
    Color statusColor = AppColors.glucoseNormal;
    if (glucoseNum < 70) statusColor = AppColors.glucoseLow;
    if (glucoseNum > 180) statusColor = AppColors.glucoseHigh;
    if (glucoseNum > 250) statusColor = AppColors.glucoseVeryHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$glucose mg/dL', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(
                  record['record_type'] ?? '',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            record['created_at']?.toString().substring(0, 10) ?? '',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın 👋';
    if (hour < 18) return 'İyi günler 👋';
    return 'İyi akşamlar 👋';
  }
}
