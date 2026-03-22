import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskHelper {
  // 计算任务完成率（基于未过期的任务）
  static Future<double> getCompletionRate() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if(tasksJson == null) return 0.0;

    final List<dynamic> decoded = jsonDecode(tasksJson);
    final tasks = decoded.whereType<Map<String, dynamic>>().map((item) => Task.fromJson(item)).toList();

    // 只考虑未过期任务（ddl >= 今天）
    final now = DateTime.now();
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    final activeTasks = tasks.where((task) {
      final dueDateOnly = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return dueDateOnly.isAfter(nowDateOnly) || dueDateOnly.isAtSameMomentAs(nowDateOnly);
    }).toList();

    if(activeTasks.isEmpty) return 0.0; // 没有未过期任务，完成率为0
    final completedCount = activeTasks.where((task) => task.isCompleted).length;
    return completedCount / activeTasks.length;
  }

}