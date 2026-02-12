import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final resp = await api.get(ApiConstants.analyticsSummary);
    return resp.data ?? {};
  } catch (_) {
    return {};
  }
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analizler')),
      body: analytics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Veriler yüklenemedi')),
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Ortalama',
                        '${data['average_glucose'] ?? '--'}',
                        'mg/dL',
                        AppColors.primary,
                        Icons.analytics,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        'Toplam Kayıt',
                        '${data['total_records'] ?? '0'}',
                        'kayıt',
                        AppColors.accent,
                        Icons.format_list_numbered,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _summaryCard(
                        'Min',
                        '${data['min_glucose'] ?? '--'}',
                        'mg/dL',
                        AppColors.glucoseLow,
                        Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _summaryCard(
                        'Max',
                        '${data['max_glucose'] ?? '--'}',
                        'mg/dL',
                        AppColors.glucoseHigh,
                        Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Chart
                const Text('Kan Şekeri Trendi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildChart(data),
                ),
                const SizedBox(height: 28),

                // Target range
                const Text('Hedef Aralıklar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _rangeIndicator('Düşük', '< 70 mg/dL', AppColors.glucoseLow),
                _rangeIndicator('Normal', '70 - 180 mg/dL', AppColors.glucoseNormal),
                _rangeIndicator('Yüksek', '180 - 250 mg/dL', AppColors.glucoseHigh),
                _rangeIndicator('Çok Yüksek', '> 250 mg/dL', AppColors.glucoseVeryHigh),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(String label, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          Text(unit, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildChart(Map<String, dynamic> data) {
    // Generate sample spots from data
    final List<FlSpot> spots = [];
    final recent = data['recent_values'];
    if (recent is List && recent.isNotEmpty) {
      for (int i = 0; i < recent.length; i++) {
        spots.add(FlSpot(i.toDouble(), (recent[i] as num).toDouble()));
      }
    } else {
      // Default sample data
      spots.addAll([
        const FlSpot(0, 130), const FlSpot(1, 115), const FlSpot(2, 145),
        const FlSpot(3, 120), const FlSpot(4, 135), const FlSpot(5, 110),
        const FlSpot(6, 125),
      ]);
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(y: 70, color: AppColors.glucoseLow.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5]),
            HorizontalLine(y: 180, color: AppColors.glucoseHigh.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5]),
          ],
        ),
      ),
    );
  }

  Widget _rangeIndicator(String label, String range, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          Text(range, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
