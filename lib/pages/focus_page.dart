// 专注页面组件
import 'package:flutter/material.dart';
import 'package:shanhai_tu/utils/beast_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../utils/constants.dart';
import '../widgets/feedback_dialog.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  // 当前专注分钟数(可调)
  int _focusMinutes = 25;

  // 本次专注总秒数
  int _totalSeconds = 25 * 60;

  // 当前专注剩余时间
  int _remainingSeconds = 25 * 60;

  Timer? _timer; // 定时器对象
  bool _isActive = false; // 是否正在计时

  @override
  void initState() {
    super.initState();
    _loadFocusDuration(); // 加载保存的专注时长
  }

  Future<void> _loadFocusDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt('FocusMinutes') ?? 25; // 默认25分钟
    setState(() {
      _focusMinutes = minutes;
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  // 显示剩余时间的文本
  String get _timeText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 计算进度
  double get _progress {
    return 1.0 - (_remainingSeconds / _focusMinutes);
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
            // 专注时长调节行
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isActive ? null : _decreaseFocusTime, // 计时中禁用
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 32,
                ),
                Text(
                  '$_focusMinutes 分钟',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: _isActive ? null : _increaseFocusTime,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 20),

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
      _remainingSeconds = _totalSeconds; // 重置剩余时间
    });
  }

  // 增
  void _increaseFocusTime() {
    if(_isActive) return; //计时中不允许修改
    setState(() {
      _focusMinutes++;
      _totalSeconds = _focusMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
    _saveFocusDuration();
  }

  // 减
  void _decreaseFocusTime() {
    if(_isActive || _focusMinutes <= 1) return; //最小1分钟
    setState(() {
      _focusMinutes--;
      _totalSeconds = _focusMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
    _saveFocusDuration();
  }

  // 保存用户专注时长
  Future<void> _saveFocusDuration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focusMinutes', _focusMinutes);
  }

  // 专注完成事件
  Future<void> _onFocusComplete() async {
    // 增加修为
    final prefs = await SharedPreferences.getInstance();
    int currentCultivation = prefs.getInt('cultivation') ?? 0;
    currentCultivation += 10; // 每次专注完成增加10点修为
    await prefs.setInt('cultivation', currentCultivation);

    // 累计专注时长
    int currentTotalFocus = prefs.getInt(StorageKeys.totalFocusSeconds) ?? 0;
    currentTotalFocus += _totalSeconds;
    await prefs.setInt(StorageKeys.totalFocusSeconds, currentTotalFocus);

    // 获取专注完成的随机台词
    String dialogue;
    if(_totalSeconds > 40 * 60){
      dialogue = BeastManager.getRandomDialogue('focus_long');
    }else {
      dialogue = BeastManager.getRandomDialogue('focus_complete');
    }

    if(mounted) {
      await FeedbackDialog.show(context, dialogue);
    }

    // 显示完成提示
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('专注完成！修为 +10'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    if(mounted) {
      Navigator.pop(context); // 返回洞府页面
    }
  }
}
