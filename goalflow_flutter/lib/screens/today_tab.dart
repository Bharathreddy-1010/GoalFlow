import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../widgets/ai_tips_modal.dart';

class TodayTab extends StatefulWidget {
  final Goal? topPriorityGoal;
  final List<TaskItem> tasks;
  final Function(TaskItem) onToggleTask;
  final Function(TaskItem) onDeleteTask;
  final VoidCallback onAddTask;
  final VoidCallback onCalendarTap;
  final VoidCallback onContinueGoal;

  const TodayTab({
    super.key,
    required this.topPriorityGoal,
    required this.tasks,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onAddTask,
    required this.onCalendarTap,
    required this.onContinueGoal,
  });

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: widget.onCalendarTap,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.border, width: 1.1),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    size: 19,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Top Priority Header
          const Text(
            'Top Priority',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 10),

          // Top Priority Card
          if (widget.topPriorityGoal != null) _buildTopPriorityCard(widget.topPriorityGoal!),

          const SizedBox(height: 24),

          // Today's Tasks Section
          const Text(
            "Today's Tasks",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Today's Tasks List (Filtered for today's date)
          Builder(
            builder: (context) {
              final today = DateTime.now();
              final todayTasks = widget.tasks.where((t) {
                if (t.scheduledDate == null) return true;
                return t.scheduledDate!.year == today.year &&
                    t.scheduledDate!.month == today.month &&
                    t.scheduledDate!.day == today.day;
              }).toList();

              if (todayTasks.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border, width: 1.1),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, color: AppTheme.primaryGreen, size: 22),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No tasks scheduled for today. Check your Calendar for upcoming days!',
                          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: todayTasks.map((task) => _buildTaskItem(task)).toList(),
              );
            },
          ),

          const SizedBox(height: 14),

          // Add Task Button
          InkWell(
            onTap: widget.onAddTask,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border, width: 1.2),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: AppTheme.primaryGreen),
                  SizedBox(width: 6),
                  Text(
                    'Add Task',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPriorityCard(Goal goal) {
    final catColor = AppTheme.getCategoryColor(goal.category);
    final catBg = AppTheme.getCategoryBg(goal.category);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border, width: 1.1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: catBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.spa_rounded, size: 20, color: catColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${goal.percentage}%',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: widget.onContinueGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border, width: 1.1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onToggleTask(task),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: task.completed ? AppTheme.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.completed ? AppTheme.primaryGreen : AppTheme.border,
                  width: 1.4,
                ),
              ),
              child: task.completed
                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: task.completed ? AppTheme.textMuted : AppTheme.textPrimary,
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  task.duration,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // AI Tip Button
          InkWell(
            onTap: () {
              AiTipsModal.show(
                context,
                goalTitle: widget.topPriorityGoal?.title ?? task.title,
                description: widget.topPriorityGoal?.description ?? 'Daily execution step',
                category: widget.topPriorityGoal?.category ?? 'Health',
                taskTitle: task.title,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreenLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 12, color: AppTheme.primaryGreen),
                  SizedBox(width: 4),
                  Text(
                    'AI Tip',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Delete Task Button
          InkWell(
            onTap: () => widget.onDeleteTask(task),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFF9EBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC25454).withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 15,
                color: Color(0xFFC25454),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
