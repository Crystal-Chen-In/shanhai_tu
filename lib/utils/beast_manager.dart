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
    'streak_3': [
    '三日不辍，道心渐明。',
    '连续三日修习，白泽欣慰。',
    '持之以恒，已见成效。',
    '三日之功，不可小觑。',
    '修行之路，贵在坚持。',
    ],
    'streak_7': [
      '七日一轮回，道行精进。',
      '连续七日，白泽赞叹不已！',
      '七星连珠，修行有成。',
      '七日之功，奠定根基。',
      '坚持不懈，必成大器。',
    ],
    'focus_long': [
      '心无旁骛，专注超常！',
      '定力非凡，白泽佩服。',
      '长时间专注，修为大增。',
      '静心凝神，事半功倍。',
      '此等定力，实属难得。',
    ],
    'high_completion': [
      '任务完成率极高，善哉！',
      '行事高效，白泽赞赏。',
      '诸事皆成，修行加速。',
      '如此效率，前途无量。',
      '任务圆满，道心稳固。',
    ],
    'important_task': [
      '重要任务完成，大吉！',
      '此事了结，可安心修行。',
      '关键一步，白泽祝贺。',
      '不负重托，道行精进。',
      '重要之事已毕，善莫大焉。',
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