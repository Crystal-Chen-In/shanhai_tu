import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/task_helper.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});
  Future<Map<String, dynamic>> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final consecutiveDays = prefs.getInt(StorageKeys.consecutiveTaskDays) ?? 0;
    final totalFocusSeconds = prefs.getInt(StorageKeys.totalFocusSeconds) ?? 0;
    final completionRate = await TaskHelper.getCompletionRate();
    return {
      'consecutiveDays': consecutiveDays,
      'totalFocusSeconds': totalFocusSeconds,
      'completionRate': completionRate,
    };
  }

  String _formatFocusHours(int seconds) {
    final hours = seconds / 3600;
    return hours.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '修行日记',
          style: TextStyle(fontFamily: 'AppFont', color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 137, 124),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('加载失败'));
          }
          final data = snapshot.data!;
          final consecutiveDays = data['consecutiveDays'] as int;
          final totalFocusSeconds = data['totalFocusSeconds'] as int;
          final completionRate = data['completionRate'] as double;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildStatCard(
                  title: '连续修行天数',
                  value: '$consecutiveDays 天',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: '累计专注时长',
                  value: '${_formatFocusHours(totalFocusSeconds)} 小时',
                  icon: Icons.timer,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  title: '任务完成率',
                  value: '${(completionRate * 100).toStringAsFixed(1)}%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(height: 32),
                Text(
                  '白泽与你同行，修行之路贵在坚持！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
