import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import 'track_provider.dart';
import 'history_screen.dart';

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
    // The design is strictly dark themed navy.
    const bgColor = Color(0xFF101321);
    const cardColor = Color(0xFF1B1D2A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Memorization Card
                  _buildStatCard(
                    title: 'Memorization',
                    subtitle: '${provider.totalMemorized} verses memorized',
                    icon: Icons.auto_graph,
                    progress: 0.0, // Fixed to 0 for UI as per request
                    primaryColor: const Color(0xFF2E8B57), // Green
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 12),

                  // 2. Reciting Card
                  _buildStatCard(
                    title: 'Reciting',
                    subtitle: '${provider.totalRecitations} total verses read',
                    icon: Icons.menu_book,
                    progress: 0.0,
                    primaryColor: const Color(0xFF6B528A), // Purple
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 12),

                  // 3. Retaining Card
                  _buildStatCard(
                    title: 'Retaining',
                    subtitle: '${provider.retentionRate.toStringAsFixed(0)}% accuracy',
                    icon: Icons.replay,
                    progress: 0.0,
                    primaryColor: const Color(0xFFC77C40), // Orange
                    cardColor: cardColor,
                  ),
                  const SizedBox(height: 24),

                  // Horizontal Date Picker (Static UI representation as per the screenshot)
                  _buildDateHeader(),
                  const SizedBox(height: 20),

                  // Line Chart Area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: LineChart(
                            LineChartData(
                              lineTouchData: LineTouchData(enabled: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
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
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 6,
                              minY: 0,
                              maxY: 4,
                              lineBarsData: [
                                // Memorize Line - Green (Straight at bottom)
                                _buildLineSeries(const Color(0xFF2E8B57), 0),
                                // Recite Line - Purple
                                _buildLineSeries(const Color(0xFF6B528A), 0.1),
                                // Retain Line - Orange
                                _buildLineSeries(const Color(0xFFC77C40), 0.2, showEndpoint: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildLegendItem(const Color(0xFF2E8B57), 'Memorize'),
                            const SizedBox(width: 16),
                            _buildLegendItem(const Color(0xFF6B528A), 'Recite'),
                            const SizedBox(width: 16),
                            _buildLegendItem(const Color(0xFFC77C40), 'Retain'),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                        color: const Color(0xFF171728), 
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D264A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_month, color: Color(0xFF7B66A4), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Check your Progress',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'View your daily activity history',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: const Color(0xFF7B66A4).withValues(alpha: 0.8), size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
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
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
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

  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _dateItem('17', 'Fri', false),
        _dateItem('18', 'Sat', false),
        _dateItem('19', 'Sun', false),
        _dateItem('20', 'Mon', true),
        _dateItem('21', 'Tue', false),
      ],
    );
  }

  Widget _dateItem(String date, String day, bool isActive) {
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
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            day,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineSeries(Color color, double yOffset, {bool showEndpoint = false}) {
    return LineChartBarData(
      spots: [
        FlSpot(0, yOffset),
        FlSpot(6, yOffset),
      ],
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showEndpoint,
        getDotPainter: (spot, percent, barData, index) {
          if (index == 1) {
            return FlDotCirclePainter(
              radius: 6,
              color: Colors.white,
              strokeWidth: 3,
              strokeColor: const Color(0xFFF0A060), 
            );
          }
          return FlDotCirclePainter(radius: 0, color: Colors.transparent, strokeWidth: 0);
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
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
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
