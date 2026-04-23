import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/database_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Expanded tracking. Only one card open theoretically, or multiple. Set one as default 'Today'
  int _expandedIndex = 0; 
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = DatabaseService().getFullProgressHistory();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF101321);
    const cardColor = Color(0xFF1A1C29);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Progress History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              setState(() {
                _historyFuture = DatabaseService().getFullProgressHistory();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }
          
          final data = snapshot.data ?? [];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'April 2026', // Mock month header as per design
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (data.isEmpty)
                  _buildEmptyState()
                else
                  ...data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    final isExpanded = index == _expandedIndex;
                    return _buildDayCard(day, isExpanded, index, cardColor);
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text(
          'No history found yet',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day, bool isExpanded, int index, Color cardColor) {
    final dateStr = day['date'] as String? ?? '';
    DateTime? date = DateTime.tryParse(dateStr);
    
    // Fallback static values for UI match
    final dayNum = date != null ? DateFormat('d').format(date) : '20';
    final dayNameShort = date != null ? DateFormat('E').format(date) : 'Mon';
    final fullDayName = date != null ? DateFormat('EEEE').format(date) : 'Today';
    final fullDateAttr = date != null ? DateFormat('MMM d, yyyy').format(date) : 'Apr 20, 2026';
    
    final memorized = (day['verses_memorized'] as int?) ?? 0;
    final reads = (day['total_recitations'] as int?) ?? 0;
    final practice = (day['practice_sessions'] as int?) ?? 0;
    final correct = (day['correct_recitations'] as int?) ?? 0;
    final accuracyStr = practice > 0 ? '${((correct / practice) * 100).toInt()}%' : '0%';

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded ? const Color(0xFF6B528A) : Colors.white.withValues(alpha: 0.05),
            width: isExpanded ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                // Date Icon Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isExpanded ? const Color(0xFF6B528A) : const Color(0xFF2E8B57),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayNum,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        dayNameShort,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Titles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isExpanded ? 'Today' : fullDayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fullDateAttr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Right Side icon / Active chip
                if (!isExpanded) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8B57).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF2E8B57), size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'Active',
                          style: TextStyle(
                            color: Color(0xFF2E8B57),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.5)),
                ] else ...[
                  const Icon(Icons.keyboard_arrow_up, color: Color(0xFF2E8B57)),
                ],
              ],
            ),
            
            // Expanded Content Grid
            if (isExpanded) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailGridItem(
                      icon: Icons.auto_graph,
                      title: 'Memorized',
                      value: '$memorized verses',
                      iconColor: const Color(0xFF2E8B57),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailGridItem(
                      icon: Icons.menu_book,
                      title: 'Read',
                      value: '$reads verses',
                      iconColor: const Color(0xFF6B528A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailGridItem(
                      icon: Icons.replay,
                      title: 'Accuracy',
                      value: accuracyStr,
                      iconColor: const Color(0xFFC77C40),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailGridItem(
                      icon: Icons.timer,
                      title: 'Time Spent',
                      value: '0 min',
                      iconColor: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGridItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF212332), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
