// 任务管理页面
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../utils/beast_manager.dart';
import '../widgets/feedback_dialog.dart';
import '../utils/constants.dart';
import '../utils/task_helper.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();

}

// 任务列表页面状态类，负责显示和管理任务列表
class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = []; // 任务列表

  @override
  void initState() {
    super.initState();
    _loadTasks(); // 启动时加载本地任务
  }

  // 加载任务列表
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> taskList = jsonDecode(tasksJson);
      setState(() {
        _tasks = taskList.map((item) => Task.fromJson(item)).toList();
        // 按截止日期排序
        _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      });
    }
  }

  // 保存任务列表到本地存储
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
  }

  // 添加新任务
  void _addTask() async{
    final result = await showDialog<Task>(
      context: context,
      builder: (ctx) => AddTaskDialog(),
    );
    if (result != null) {
      setState(() {
        _tasks.add(result);
        // 按截止日期排序
        _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      });
      _saveTasks(); // 保存更新后的任务列表
    }
  }

  // 删除任务（滑动删除时调用）
  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
    _saveTasks(); // 保存更新后的任务列表
  }

  // 切换任务完成状态
  void _toggleTaskCompletion(Task task) async {
    // 如果任务原本未完成，现在要标记为完成
    if(!task.isCompleted) {
      // 记录完成时间
      task.completedAt = DateTime.now();

      // 更新连续完成天数
      final prefs = await SharedPreferences.getInstance();
      int consecutiveDays = prefs.getInt(StorageKeys.consecutiveTaskDays) ?? 0;
      final lastCompletionDateStr = prefs.getString(StorageKeys.lastTaskCompletionDate);

      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day); // 只比较日期部分
      final todayStr = todayDate.toIso8601String().split('T')[0]; // 只保留日期部分
      if(lastCompletionDateStr == null) {
        consecutiveDays = 1;
      } else {
        final lastDate = DateTime.parse(lastCompletionDateStr);
        final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final yesterdayDateOnly = todayDate.subtract(const Duration(days: 1));

        if(lastDateOnly == yesterdayDateOnly) {
          consecutiveDays += 1; // 连续完成，增加天数
        } else if (lastDateOnly == todayDate) {
          // 同一天内完成多次，不增加天数
        } else {
          consecutiveDays = 1; // 中断，重置为1
        }
      }

      await prefs.setInt(StorageKeys.consecutiveTaskDays, consecutiveDays);
      await prefs.setString(StorageKeys.lastTaskCompletionDate, todayStr);

      // 判断是否提前完成(比较日期而非具体时间) // 获取基础场景
      final duedate = DateTime(task.dueDate.year,task.dueDate.month,task.dueDate.day);
      final nowdate = DateTime(now.year,now.month,now.day);
      String basescene;
      if(nowdate.isBefore(duedate)) {
        basescene = 'task_early'; // 提前
      } else if(nowdate.isAfter(duedate)) {
        basescene = 'task_late'; // 逾期
      } else {
        basescene = 'task_on_time'; // 按时
      }

      // 读取用户行为数据
      final completionRate = await TaskHelper.getCompletionRate();
      final dialogue = await _selectTaskDialogue(
        basescene: basescene,
        consecutiveDays: consecutiveDays,
        completionRate: completionRate,
        // isImportant: task.isImportant,
      );

      // 更新状态
      setState(() {
        task.isCompleted = true;
      });
      _saveTasks(); // 保存更新后的任务列表

      // 显示反馈对话框
      if(mounted) {
        await FeedbackDialog.show(context, dialogue);
      }
    }else {
      // 如果任务原本已完成，现在要标记为未完成
      task.completedAt = null; // 清除完成时间
      setState(() {
        task.isCompleted = false;
      });
      _saveTasks(); // 保存更新后的任务列表
    }
  }

  // 选择最终台词
  Future<String> _selectTaskDialogue({
    required String basescene,
    required int consecutiveDays,
    required double completionRate,
    // bool isImportant = false,
  }) async {
    // 优先级：连续天数 > 完成率 > 重要任务 > 基础场景
    if(consecutiveDays >= 7) {
      // print('使用 streak_7');
      return BeastManager.getRandomDialogue('streak_7');
    } else if(consecutiveDays >= 3) {
      // print('使用 streak_3');
      return BeastManager.getRandomDialogue('streak_3');
    } else if(completionRate > 0.8) {
      // print('使用 high_completion');
      return BeastManager.getRandomDialogue('high_completion');
    } /*else if(isImportant) {
      return BeastManager.getRandomDialogue('important_task');
    }*/else{
      // print('使用基础场景: $basescene');
      return BeastManager.getRandomDialogue(basescene);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历练卷轴'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: _tasks.isEmpty
          ? const Center(
            child:Text(
              '暂无任务，点击右下角按钮添加',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (ctx,index) {
            final task = _tasks[index];
            return Dismissible(
              key: Key(task.id), // 使用任务ID作为唯一Key
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart, // 只能从右向左滑动删除
              onDismissed: (_) => _deleteTask(task.id), // 删除任务
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => _toggleTaskCompletion(task), // 切换完成状态
                  activeColor: Colors.teal,
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Text(
                  '截止: ${_formatDate(task.dueDate)}',
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey : Colors.grey.shade700,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () => _editTask(task), // 编辑任务
                ),
              ),
            );
          },
        ),
  floatingActionButton: FloatingActionButton(
        onPressed: _addTask, // 添加新任务
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  // 编辑任务（简化版，可复用添加对话框）
  void _editTask(Task task) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (ctx) => AddTaskDialog(existingTask: task), // 传入现有任务进行编辑
    );
    if (result != null) {
      // 更新现有任务
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        setState(() {
          _tasks[index] = result;
          // 按截止日期排序
          _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        });
        _saveTasks(); // 保存更新后的任务列表
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

}

// 添加\编辑任务对话框组件
class AddTaskDialog extends StatefulWidget {
  final Task? existingTask; // 如果传入，则为编辑模式

  const AddTaskDialog({super.key, this.existingTask});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      _titleController.text = widget.existingTask!.title;
      _selectedDate = widget.existingTask!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTask == null ? '添加任务' : '编辑任务'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '任务名称',
              hintText: '例如：完成数学作业',
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title:  const Text('截止日期'),
            subtitle: Text(_formatDate(_selectedDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context), // 选择截止日期
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // 取消
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) return; // 标题不能为空
            final task = Task(
              id: widget.existingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), // 编辑时保留ID
              title: _titleController.text.trim(),
              dueDate: _selectedDate,
              isCompleted: widget.existingTask?.isCompleted ?? false, // 编辑时保留完成状态
            );
            Navigator.pop(context, task); // 返回新建/编辑的任务对象
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

}