import 'package:flutter/material.dart';
import 'pages/task_list_page.dart'; // 导入任务列表页面组件

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( //配置应用标题和主页
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '洞府',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '卷轴',
          ),
        ],
      ),
    );
  }
}

//创建洞府页面组件（白泽、修为显示、专注按钮）
class DonfuHomePage extends StatelessWidget {
  const DonfuHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('洞府'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/baize1.png', // 白泽图片占位
            width: 200, 
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal:24,vertical: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              ),
              child: const Text(
                '修为：0',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: (){
                // 点击专注按钮时显示提示对话框
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('炼丹炉'),
                    content: const Text('专注计时功能即将开放，敬请期待！'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('知道了'),
                      )
                    ],
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '开始专注',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
        title: const Text('历练卷轴'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: const Center(
        child: Text(
          '任务列表功能即将开放，敬请期待！',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}