// 任务数据模型
class Task {
  final String id; // 唯一标识，用于删除/更新
  String title;
  DateTime dueDate;
  bool isCompleted;
  bool isImporatant;
  DateTime createdAt;
  DateTime? completedAt; // 任务完成时间,null表示未完成

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    this.isImporatant = false,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 将 Task 对象转换为 Map 以便存储
  Map<String,dynamic> toJson() => {
    'id': id,
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'isImportant': isImporatant,
  };

  // 从 Map 创建 Task 对象
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    dueDate: DateTime.parse(json['dueDate']),
    isCompleted: json['isCompleted'],
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    isImporatant: json['isImportant'] ?? false,
  );

}