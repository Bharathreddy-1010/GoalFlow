import 'package:intl/intl.dart';

class TaskItem {
  final String id;
  final String goalId;
  final String title;
  final String duration; // e.g. "10 min", "30 min"
  bool completed;
  final String? time;
  final DateTime? scheduledDate;

  TaskItem({
    required this.id,
    this.goalId = '',
    required this.title,
    required this.duration,
    this.completed = false,
    this.time,
    this.scheduledDate,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] ?? '',
      goalId: json['goalId'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '15 min',
      completed: json['completed'] ?? false,
      time: json['time'],
      scheduledDate: json['scheduledDate'] != null ? DateTime.tryParse(json['scheduledDate']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'title': title,
        'duration': duration,
        'completed': completed,
        'time': time,
        'scheduledDate': scheduledDate?.toIso8601String(),
      };
}

class MilestoneItem {
  final String id;
  final String title;
  final double progress; // 0.0 to 1.0
  final bool completed;
  final bool isLocked;

  MilestoneItem({
    required this.id,
    required this.title,
    required this.progress,
    this.completed = false,
    this.isLocked = false,
  });

  factory MilestoneItem.fromJson(Map<String, dynamic> json) {
    return MilestoneItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      completed: json['completed'] ?? false,
      isLocked: json['isLocked'] ?? false,
    );
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final String category; // Health, Learning, Fitness, Career, Finance, Personal
  final double progress; // 0.0 to 1.0
  final String startDate;
  final String targetDate;
  final String frequency; // Daily, Weekly
  final String reminderTime; // e.g. "7:00 AM"
  final String status; // active, completed, archived
  final bool isTodayFocus;
  final List<MilestoneItem> milestones;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.progress,
    this.startDate = 'Today',
    this.targetDate = 'Dec 31, 2024',
    this.frequency = 'Daily',
    this.reminderTime = '7:00 AM',
    this.status = 'active',
    this.isTodayFocus = false,
    this.milestones = const [],
  });

  int get totalTimelineDays {
    try {
      final DateFormat fmt = DateFormat('MMM dd, yyyy');
      final DateTime start = fmt.parse(startDate);
      final DateTime end = fmt.parse(targetDate);
      final diff = end.difference(start).inDays;
      return diff < 0 ? 1 : diff + 1; // e.g. same day = 1 day
    } catch (_) {
      return 1;
    }
  }

  double get dailyProgressIncrement {
    final days = totalTimelineDays;
    return 1.0 / days;
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? progress,
    String? startDate,
    String? targetDate,
    String? frequency,
    String? reminderTime,
    String? status,
    bool? isTodayFocus,
    List<MilestoneItem>? milestones,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      isTodayFocus: isTodayFocus ?? this.isTodayFocus,
      milestones: milestones ?? this.milestones,
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    var mList = json['milestones'] as List? ?? [];
    return Goal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Health',
      progress: (json['progress'] as num?)?.toDouble() ??
          ((json['currentProgress'] as num?)?.toDouble() ?? 0.0) /
              ((json['targetProgress'] as num?)?.toDouble() ?? 100.0),
      startDate: json['startDate'] ?? 'Today',
      targetDate: json['targetDate'] ?? 'Dec 31, 2024',
      frequency: json['frequency'] ?? 'Daily',
      reminderTime: json['reminderTime'] ?? '7:00 AM',
      status: json['status'] ?? 'active',
      isTodayFocus: json['isTodayFocus'] ?? false,
      milestones: mList.map((m) => MilestoneItem.fromJson(m)).toList(),
    );
  }

  int get percentage => (progress * 100).round();
}

class DayProgress {
  final String day; // M, T, W, T, F, S, S
  final double value; // 0.0 to 1.0
  final bool isToday;

  DayProgress({
    required this.day,
    required this.value,
    this.isToday = false,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String greeting;
  final int completionRate;
  final int tasksCompleted;
  final String focusHours;
  final String? avatarUrl;
  final List<String> preferredAreas;
  final String morningTime;
  final String dailyFocusTarget;

  UserProfile({
    required this.name,
    this.email = 'bharath404074@gmail.com',
    required this.greeting,
    this.completionRate = 78,
    this.tasksCompleted = 24,
    this.focusHours = '12h 45m',
    this.avatarUrl,
    this.preferredAreas = const ['Fitness & Health', 'Learning & Education'],
    this.morningTime = '7:00 AM',
    this.dailyFocusTarget = '1h 30m',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? greeting,
    int? completionRate,
    int? tasksCompleted,
    String? focusHours,
    String? avatarUrl,
    List<String>? preferredAreas,
    String? morningTime,
    String? dailyFocusTarget,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      greeting: greeting ?? this.greeting,
      completionRate: completionRate ?? this.completionRate,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      focusHours: focusHours ?? this.focusHours,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredAreas: preferredAreas ?? this.preferredAreas,
      morningTime: morningTime ?? this.morningTime,
      dailyFocusTarget: dailyFocusTarget ?? this.dailyFocusTarget,
    );
  }
}
