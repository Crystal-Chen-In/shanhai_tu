import 'dart:math';
import 'package:flutter/material.dart';

class BeastManager extends ChangeNotifier {
  // 台词库，按场景分类
  static const Map<String,List<String>> _dialogues = {
    'task_early': [
      '谋定后动，吉兆自显！',
      '运筹帷幄，胜券在握。',
      '未雨绸缪，白泽赞叹！',
      '提前完成，道心稳固。',
    ],
    'task_on_time': [
      '持之以恒，修行渐进。',
      '今日功课圆满，善哉。',
      '守时守信，大道可期。',
      '不早不晚，恰到好处。',
    ],
    'task_late': [
      '潮汐有信，暂缓无妨。',
      '调整呼吸，重新开始。',
      '亡羊补牢，未为晚也。',
      '迟来总比不来好，加油。',
    ],
    'focus_complete': [
      '神思贯注，心无旁骛。',
      '定力精进，殊为可贵。',
      '专注一刻，胜过百日空想。',
      '澄心静虑，道行见长。',
    ],
    'upcoming_reminder': [
    '道友，近日有功课将临，莫忘修行。',
    '白泽感应到，数日内有任务待完成。',
    '时日无多，宜早做准备。',
    '风起云涌，任务期限将近。',
    ],
  };

  // 根据场景，获取随机台词
  static String getRandomDialogue(String scene) {
    final List<String>? list = _dialogues[scene];
    if (list == null || list.isEmpty) {
      return '白泽静静地看着你。'; // 兜底台词
    }
    final random = Random();
    return list[random.nextInt(list.length)];
  }

}