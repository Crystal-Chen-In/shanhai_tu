import 'package:flutter/material.dart';

class FeedbackDialog extends StatelessWidget {
  final String dialogue;

  const FeedbackDialog({super.key, required this.dialogue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 白泽图片
            Image.asset(
              'assets/images/baize1.png',
              width: 80,
              height: 80,
            ),
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
      )
    );
  }

  //静态方法，方便调用
  static Future<void> show(BuildContext context, String dialogue) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => FeedbackDialog(dialogue: dialogue),
    );
  }
  
}