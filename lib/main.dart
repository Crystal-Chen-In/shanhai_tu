import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '山海途',// 这里控制应用内标题，通常用于任务管理器
      home: Scaffold(
        appBar: AppBar(
          title: const Text('山海灵境·伴旅'),  // 第一个页面的标题
        ),
        body: const Center(
          child: Text('你的修炼之旅，即将开始...'),
        ),
      ),
    );
  }
}
