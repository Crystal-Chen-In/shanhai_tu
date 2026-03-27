import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/task_list_page.dart'; // 导入任务列表页面组件
import 'pages/focus_page.dart'; // 导入专注页面组件
import 'pages/stats_page.dart'; // 导入修行日记页面组件
import '../models/task.dart'; // 导入任务模型
import '../utils/beast_manager.dart'; // 获取随机台词
import '../widgets/feedback_dialog.dart'; // 导入反馈对话框组件

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //配置应用标题和主页
      title: '山海途',
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // 记录当前选中的底部导航栏索引

  // 定义两个页面，分别对应洞府和卷轴
  final List<Widget> _pages = [
    const DonfuHomePage(), // 洞府页面
    const TaskListPage(), // 卷轴页面
    const StatsPage(), // 修行日记页面
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 根据选中的索引显示对应页面
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 设置当前选中的索引
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // 点击时更新选中的索引
          });
        },
        selectedLabelStyle: TextStyle(fontFamily: 'AppFont'),
        unselectedLabelStyle: TextStyle(fontFamily: 'AppFont'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '洞府'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '卷轴'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '修行录'),
        ],
      ),
    );
  }
}

//创建洞府页面组件（白泽、修为显示、专注按钮）
class DonfuHomePage extends StatefulWidget {
  const DonfuHomePage({super.key});

  @override
  State<DonfuHomePage> createState() => _DonfuHomePageState();
}

class _DonfuHomePageState extends State<DonfuHomePage> {
  int _cultivation = 0; // 修为值

  @override
  void initState() {
    super.initState();
    _loadCultivation(); // 初始化时加载修为值
    _checkUpcomingTasks(); // 检查即将逾期的任务
  }

  // 加载修为值
  Future<void> _loadCultivation() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cultivation = prefs.getInt('cultivation') ?? 0; // 获取修为值，默认为0
    });
  }

  Future<void> _checkUpcomingTasks() async {
    //加载任务列表
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson == null) return; // 没有任务数据则不继续检查

    final String nonNullJson = tasksJson; // 确保 tasksJson 不为 null
    dynamic decoded;
    try {
      decoded = jsonDecode(nonNullJson);
    } catch (e) {
      return; // 解析失败则不继续检查
    }

    if (decoded is! List) return; // 解析结果不是列表则不继续检查

    final tasks = decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => Task.fromJson(item))
        .toList();

    // 筛选未完成且即将逾期任务
    final now = DateTime.now();
    final nowdate = DateTime(now.year, now.month, now.day);
    const remindDays = 3; // 提前3天提醒
    final upcomingTasks = tasks.where((task) {
      if (task.isCompleted) return false; // 已完成的任务不提示
      final duedate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      final daysLeft = duedate.difference(nowdate).inDays;
      return daysLeft >= 0 && daysLeft <= remindDays; // 0表示今日到期
    }).toList();

    // 如果有即将逾期的任务，且当天尚未提醒过，显示提示对话框
    if (upcomingTasks.isNotEmpty) {
      //只提醒一次
      final lastReminderDate = prefs.getString('lastUpcomingReminderDate');
      final todayStr = nowdate.toIso8601String().split('T')[0]; // 获取年月日部分

      if (lastReminderDate != todayStr) {
        await prefs.setString('lastUpcomingReminderDate', todayStr);

        // 获取随机台词
        final dialogue = BeastManager.getRandomDialogue('upcoming_reminder');
        if (mounted) {
          await FeedbackDialog.show(context, dialogue);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '洞府修心',
          style: TextStyle(fontFamily: 'AppFont', color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 20, 137, 124),
      ),
      body: Stack(
        children: [
          // 背景图
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgpic.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/baize.png', // 白泽图片占位
                  width: 250,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '修为：$_cultivation',
                    style: const TextStyle(
                      fontFamily: 'AppFont',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    // 点击开始专注按钮，跳转到专注修心页面
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const FocusPage()),
                    );
                    // 从专注修心页面返回后，重新加载修为值，更新界面
                    _loadCultivation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '开始专注',
                    style: TextStyle(
                      fontFamily: 'AppFont',
                      fontSize: 20,
                      color: Colors.white,
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
}

//创建卷轴页面组件（卷轴列表显示）
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历练卷轴', style: TextStyle(fontFamily: 'AppFont')),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 20, 137, 124),
      ),
      body: const Center(
        child: Text('任务列表功能即将开放，敬请期待！', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
