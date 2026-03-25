import 'beast_manager.dart';

class FeedbackSelector {
    // 完成任务的台词选择
    // 优先级：连续天数 > 完成率 > 重要任务 > 基础场景
    static Future<String> selectTaskDialogue({
        required String basescene,
        required int consecutiveDays,
        required double completionRate,
        bool isImportant = false,
    }) async {
        if(consecutiveDays >= 7) {
          // print('使用 streak_7');
          return BeastManager.getRandomDialogue('streak_7');
        } else if(consecutiveDays >= 3) {
          // print('使用 streak_3');
          return BeastManager.getRandomDialogue('streak_3');
        } else if(completionRate > 0.8) {
          // print('使用 high_completion');
          return BeastManager.getRandomDialogue('high_completion');
        } else if(isImportant) {
          return BeastManager.getRandomDialogue('important_task');
        } else {
          // print('使用基础场景: $basescene');
          return BeastManager.getRandomDialogue(basescene);
        }
    }

    // 专注完成时台词选择
    static String selectFocusDialogue(int totalSeconds) {
        if(totalSeconds > 40 * 60){
            return BeastManager.getRandomDialogue('focus_long');
        } else {
            return BeastManager.getRandomDialogue('focus_complete');
        }
    }
}