// 专注页面组件
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  //默认专注时长为 25 分钟(单位：秒)
  static const int defaultTotalSeconds = 25 * 60;

  // 当前专注剩余时间
  int _remainingSeconds = defaultTotalSeconds;

  Timer? _timer; // 定时器对象
  bool _isActive = false; // 是否正在计时

  // 显示剩余时间的文本
  String get _timeText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 计算进度
  double get _progress {
    return 1.0 - (_remainingSeconds / defaultTotalSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel(); // 页面销毁时取消定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专注修心'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 圆形进度条显示专注进度
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
            const SizedBox(height: 30),
            // 显示时间
            Text(
              _timeText,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // 专注按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isActive ? null : _startTimer, // 如果正在计时，按钮不可用
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('开始'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isActive ? _pauseTimer : null, // 如果没有在计时，按钮不可用
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text('暂停'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('重置'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 开始计时
  void _startTimer() {
  _timer?.cancel(); // 先取消之前的定时器

  setState(() {
    _isActive = true;
  });

  // 创建一个每秒触发的定时器
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if(_remainingSeconds <= 1) {
      // 时间到，停止计时
      _timer?.cancel();
      _isActive = false;
      _remainingSeconds = 0;
      setState(() {}); // 更新界面显示 00:00
      _onFocusComplete(); // 触发专注完成事件
    }else {
      // 继续倒计时
      setState(() {
        _remainingSeconds--;
      });
    }
  });
  }
  // 暂停计时
  void _pauseTimer() {
    _timer?.cancel(); // 取消定时器
    setState(() {
      _isActive = false; // 更新状态为非活动
    });
  }

  // 重置计时
  void _resetTimer() {
    _timer?.cancel(); // 取消定时器
    setState(() {
      _isActive = false; // 更新状态为非活动
      _remainingSeconds = defaultTotalSeconds; // 重置剩余时间
    });
  }

  // 专注完成事件
  Future<void> _onFocusComplete() async {
    // 增加修为
    final prefs = await SharedPreferences.getInstance();
    int currentCultivation = prefs.getInt('cultivation') ?? 0;
    currentCultivation += 10; // 每次专注完成增加10点修为
    await prefs.setInt('cultivation', currentCultivation);

    // 显示完成提示
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('专注完成！修为 +10'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    Navigator.pop(context); // 返回洞府页面
  }

}
