import 'dart:async';

import 'package:flutter/material.dart';

class FeedbackDialog extends StatelessWidget {
  final String dialogue;

  const FeedbackDialog({super.key, required this.dialogue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 白泽图片
            Image.asset('assets/images/baize1.png', width: 80, height: 80),
            const SizedBox(height: 16),
            Text(
              dialogue,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('知晓'),
            ),
          ],
        ),
      ),
    );
  }

  //静态方法，方便调用
  static Future<void> show(
    BuildContext context,
    String dialogue, {
    String? reason,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) =>
          _AnimatedFeedbackDialog(dialogue: dialogue, reason: reason),
    );
  }
}

class _AnimatedFeedbackDialog extends StatefulWidget {
  final String dialogue;
  final String? reason;

  const _AnimatedFeedbackDialog({required this.dialogue, this.reason});

  @override
  State<_AnimatedFeedbackDialog> createState() =>
      _AnimatedFeedbackDialogState();
}

class _AnimatedFeedbackDialogState extends State<_AnimatedFeedbackDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  //呼吸效果相关
  bool _isBreathing = false;
  Timer? _breathingTimer;

  @override
  void initState() {
    super.initState();
    // 弹入动画
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    // 呼吸效果：1.5s切换一次状态
    _breathingTimer = Timer.periodic(const Duration(milliseconds: 1500), (
      timer,
    ) {
      if (mounted) {
        setState(() {
          _isBreathing = !_isBreathing;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: child),
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 白泽头像（呼吸效果）
              AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                width: _isBreathing ? 210 : 200,
                height: _isBreathing ? 210 : 200,
                child: Image.asset(
                  'assets/images/baize1.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              // 台词
              Text(
                widget.dialogue,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              // 原因
              if (widget.reason != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.reason!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // 确认按钮
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.teal.shade50,
                  foregroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('知晓', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
