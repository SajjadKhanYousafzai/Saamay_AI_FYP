import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import 'track_provider.dart';
import 'history_screen.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  late final TrackProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TrackProvider()..loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh stats every time this tab becomes visible
    _provider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const _TrackView(),
    );
  }
}

class _TrackView extends StatelessWidget {
  const _TrackView();

  // Total verses in the Quran
  static const int _totalQuranVerses = 6236;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrackProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardColor = theme.cardTheme.color ?? (isDark ? const Color(0xFF1B1D2A) : AppColors.cardLight);
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final textMuted = isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textGrey;

    // Calculate dynamic percentages
    final memorizeProgress = provider.totalMemorized / _totalQuranVerses;
    final reciteProgress = provider.totalRecitations / _totalQuranVerses;
    final retainProgress = provider.retentionRate / 100;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: () => provider.loadStats(),
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // 1. Memorization Card
                  _buildStatCard(
                    title: 'Memorization',
                    subtitle: '${provider.totalMemorized} verses memorized',
                    icon: Icons.auto_graph,
                    progress: memorizeProgress.clamp(0.0, 1.0),
                    primaryColor: const Color(0xFF2E8B57), // Green
                    cardColor: cardColor,
                    textColor: textColor,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),

                  // 2. Reciting Card
                  _buildStatCard(
                    title: 'Reciting',
                    subtitle: '${provider.totalRecitations} total verses read',
                    icon: Icons.menu_book,
                    progress: reciteProgress.clamp(0.0, 1.0),
                    primaryColor: const Color(0xFF6B528A), // Purple
                    cardColor: cardColor,
                    textColor: textColor,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 12),

                  // 3. Retaining Card
                  _buildStatCard(
                    title: 'Retaining',
                    subtitle: '${provider.retentionRate.toStringAsFixed(0)}% accuracy',
                    icon: Icons.replay,
                    progress: retainProgress.clamp(0.0, 1.0),
                    primaryColor: const Color(0xFFC77C40), // Orange
                    cardColor: cardColor,
                    textColor: textColor,
                    textMuted: textMuted,
                  ),
                  const SizedBox(height: 24),

                  // Horizontal Date Picker (Dynamic)
                  _buildDynamicDateHeader(textColor, textMuted),
                  const SizedBox(height: 20),

                  // Line Chart Area (Dynamic)
                  _buildDynamicChart(provider, cardColor, textColor, textMuted),
                  const SizedBox(height: 16),

                  // Check Progress Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 30),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF171728) : AppColors.surfaceLight, 
                        borderRadius: BorderRadius.circular(16),
                        border: isDark ? null : Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D264A) : AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.calendar_month, color: isDark ? const Color(0xFF7B66A4) : AppColors.primaryGreen, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check your Progress',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'View your daily activity history',
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: isDark ? const Color(0xFF7B66A4).withValues(alpha: 0.8) : Colors.grey.shade400, size: 16),
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

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double progress,
    required Color primaryColor,
    required Color cardColor,
    required Color textColor,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 30),
            ),
          ),
          const SizedBox(width: 16),
          // Text Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Circular Progress
          SizedBox(
            width: 55,
            height: 55,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.1)),
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    _formatProgress(progress),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatProgress(double progress) {
    final percent = progress * 100;
    if (percent > 0 && percent < 1) {
      return '${percent.toStringAsFixed(1)}%';
    }
    return '${percent.toInt()}%';
  }

  // ── Dynamic Date Header ──
  Widget _buildDynamicDateHeader(Color textColor, Color textMuted) {
    final now = DateTime.now();
    final days = <DateTime>[];
    // Generate 2 days before today, today, and 2 days after
    for (int i = -2; i <= 2; i++) {
      days.add(now.add(Duration(days: i)));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((date) {
        final isToday = date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;
        final dayNum = date.day.toString();
        final dayName = DateFormat('EEE').format(date); // Mon, Tue, etc.
        return _dateItem(dayNum, dayName, isToday, textColor, textMuted);
      }).toList(),
    );
  }

  Widget _dateItem(String date, String day, bool isActive, Color textColor, Color textMuted) {
    if (isActive) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2E8B57), // Green highlight
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  date,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  day,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 11.0),
      child: Column(
        children: [
          Text(
            date,
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(color: textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Dynamic Chart ──
  Widget _buildDynamicChart(TrackProvider provider, Color cardColor, Color textColor, Color textMuted) {
    final weeklyData = provider.weeklyProgress;

    // Build a map of date -> data for quick lookup
    final Map<String, Map<String, dynamic>> dataByDate = {};
    for (final row in weeklyData) {
      final dateStr = row['date'] as String?;
      if (dateStr != null && dateStr.length >= 10) {
        dataByDate[dateStr.substring(0, 10)] = row;
      } else if (dateStr != null) {
        dataByDate[dateStr] = row;
      }
    }

    // Generate the last 7 days
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    // Build data points for each line
    final List<FlSpot> memorizeSpots = [];
    final List<FlSpot> reciteSpots = [];
    final List<FlSpot> retainSpots = [];
    double maxVal = 4; // Minimum maxY to avoid flat charts

    for (int i = 0; i < last7Days.length; i++) {
      final dateStr = last7Days[i].toIso8601String().split('T').first;
      final dayData = dataByDate[dateStr];

      final memorized = (dayData?['verses_memorized'] as int?)?.toDouble() ?? 0;
      final recitations = (dayData?['total_recitations'] as int?)?.toDouble() ?? 0;

      // Calculate daily retain accuracy (0-100) then scale down by /10 for chart
      double retainVal = 0;
      final practice = (dayData?['practice_sessions'] as int?) ?? 0;
      final correct = (dayData?['correct_recitations'] as int?) ?? 0;
      if (practice > 0) {
        retainVal = (correct / practice) * 100; // Scale: 100% becomes 100
      }

      memorizeSpots.add(FlSpot(i.toDouble(), memorized));
      reciteSpots.add(FlSpot(i.toDouble(), recitations));
      retainSpots.add(FlSpot(i.toDouble(), retainVal));

      // Track dynamic max
      if (memorized > maxVal) maxVal = memorized;
      if (recitations > maxVal) maxVal = recitations;
      if (retainVal > maxVal) maxVal = retainVal;
    }

    // Add some padding above the max value
    maxVal = (maxVal * 1.2).ceilToDouble();
    if (maxVal < 4) maxVal = 4;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textMuted.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final color = spot.bar.color ?? Colors.white;
                        String label;
                        if (color == const Color(0xFF2E8B57)) {
                          label = '${spot.y.toInt()} memorized';
                        } else if (color == const Color(0xFF6B528A)) {
                          label = '${spot.y.toInt()} read';
                        } else {
                          label = '${spot.y.toInt()}% accuracy';
                        }
                        return LineTooltipItem(
                          label,
                          TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= last7Days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('E').format(last7Days[idx]), // M, T, W...
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxVal,
                lineBarsData: [
                  // Memorize Line - Green
                  _buildDynamicLineSeries(const Color(0xFF2E8B57), memorizeSpots, showDots: true),
                  // Recite Line - Purple
                  _buildDynamicLineSeries(const Color(0xFF6B528A), reciteSpots, showDots: true),
                  // Retain Line - Orange
                  _buildDynamicLineSeries(const Color(0xFFC77C40), retainSpots, showDots: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildLegendItem(const Color(0xFF2E8B57), 'Memorize', textMuted),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFF6B528A), 'Recite', textMuted),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFFC77C40), 'Retain', textMuted),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildDynamicLineSeries(Color color, List<FlSpot> spots, {bool showDots = false}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, barData, index) {
          if (index == spots.length - 1) {
            return FlDotCirclePainter(
              radius: 5,
              color: Colors.white,
              strokeWidth: 2.5,
              strokeColor: color,
            );
          }
          return FlDotCirclePainter(radius: 0, color: Colors.transparent, strokeWidth: 0);
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textMuted) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
