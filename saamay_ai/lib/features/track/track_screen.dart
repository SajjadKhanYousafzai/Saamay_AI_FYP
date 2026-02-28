import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import 'track_provider.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackProvider()..loadStats(),
      child: const _TrackView(),
    );
  }
}

class _TrackView extends StatelessWidget {
  const _TrackView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // ── Stats Cards ──
          Row(
            children: [
              _statCard(
                context,
                icon: Icons.menu_book,
                label: 'Memorized',
                value: '${provider.totalMemorized}',
                subtitle: 'verses',
                color: AppColors.accentGreen,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _statCard(
                context,
                icon: Icons.trending_up,
                label: 'Retention',
                value: '${provider.retentionRate.toStringAsFixed(0)}%',
                subtitle: 'accuracy',
                color: AppColors.info,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(
                context,
                icon: Icons.mic,
                label: 'Recitations',
                value: '${provider.totalRecitations}',
                subtitle: 'attempts',
                color: const Color(0xFFE879F9),
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _statCard(
                context,
                icon: Icons.replay,
                label: 'Practice',
                value: '${provider.totalPractice}',
                subtitle: 'sessions',
                color: AppColors.warning,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Weekly Chart ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(provider.weeklyProgress),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                              ];
                              final index = value.toInt();
                              if (index >= 0 && index < days.length) {
                                return Text(
                                  days[index],
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 11,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(provider.weeklyProgress),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Today's Summary ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.heroGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Activity",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _todayRow(
                  icon: Icons.menu_book,
                  label: 'Verses Memorized',
                  value: '${provider.todayProgress?['verses_memorized'] ?? 0}',
                ),
                const SizedBox(height: 10),
                _todayRow(
                  icon: Icons.mic,
                  label: 'Recitations',
                  value:
                      '${provider.todayProgress?['total_recitations'] ?? 0}',
                ),
                const SizedBox(height: 10),
                _todayRow(
                  icon: Icons.replay,
                  label: 'Practice Sessions',
                  value:
                      '${provider.todayProgress?['practice_sessions'] ?? 0}',
                ),
                const SizedBox(height: 10),
                _todayRow(
                  icon: Icons.check_circle,
                  label: 'Correct Recalls',
                  value:
                      '${provider.todayProgress?['correct_recitations'] ?? 0}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<Map<String, dynamic>> weeklyProgress) {
    double maxVal = 5;
    for (final day in weeklyProgress) {
      final memorized = (day['verses_memorized'] as int?) ?? 0;
      final sessions = (day['practice_sessions'] as int?) ?? 0;
      final val = (memorized + sessions).toDouble();
      if (val > maxVal) maxVal = val;
    }
    return maxVal + 2;
  }

  List<BarChartGroupData> _buildBarGroups(
    List<Map<String, dynamic>> weeklyProgress,
  ) {
    // Map progress data to day indices
    final dayMap = <int, double>{};
    for (final day in weeklyProgress) {
      final dateStr = day['date'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          final dayIndex = (date.weekday - 1) % 7; // Monday = 0
          final memorized = (day['verses_memorized'] as int?) ?? 0;
          final sessions = (day['practice_sessions'] as int?) ?? 0;
          dayMap[dayIndex] = (memorized + sessions).toDouble();
        }
      }
    }

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dayMap[index] ?? 0,
            color: AppColors.primaryGreen,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(weeklyProgress),
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
            ),
          ),
        ],
      );
    });
  }

  Widget _todayRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
