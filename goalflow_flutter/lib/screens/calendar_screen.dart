import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  final List<TaskItem> tasks;
  final Function(TaskItem) onToggleTask;
  final VoidCallback onBack;

  const CalendarScreen({
    super.key,
    required this.tasks,
    required this.onToggleTask,
    required this.onBack,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Sunday of the current week
    _currentWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
      _selectedDate = _currentWeekStart;
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
      _selectedDate = _currentWeekStart;
    });
  }

  List<DateTime> get _weekDays {
    return List.generate(7, (index) => _currentWeekStart.add(Duration(days: index)));
  }

  Color _getTaskIndicatorColor(int index) {
    switch (index % 4) {
      case 0:
        return const Color(0xFF385E46); // Green
      case 1:
        return const Color(0xFFD6A856); // Amber Gold
      case 2:
        return const Color(0xFF3D6F9D); // Soft Blue
      case 3:
      default:
        return const Color(0xFFC25454); // Coral Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final String monthYearStr = DateFormat('MMMM yyyy').format(_selectedDate);
    final weekDays = _weekDays;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Title "Calendar" + Back/Chevron
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: widget.onBack,
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.textPrimary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Calendar',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.close_rounded, size: 24, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Month Subtitle with Chevron Navigation (Real-Time)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _previousWeek,
                          icon: const Icon(Icons.chevron_left_rounded, size: 26, color: AppTheme.textPrimary),
                        ),
                        Text(
                          monthYearStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.1,
                          ),
                        ),
                        IconButton(
                          onPressed: _nextWeek,
                          icon: const Icon(Icons.chevron_right_rounded, size: 26, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Real-Time Dynamic Weekday Strip (7 Days)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: weekDays.map((date) {
                        final int dayNum = date.day;
                        final String weekdayStr = DateFormat('EEE').format(date).toUpperCase();
                        final bool isSelected = date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedDate = date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weekdayStr,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white.withValues(alpha: 0.85) : AppTheme.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Claymorphic Schedule Container Sheet
                    Builder(
                      builder: (context) {
                        final dayTasks = widget.tasks.where((t) {
                          if (t.scheduledDate == null) return true;
                          return t.scheduledDate!.year == _selectedDate.year &&
                              t.scheduledDate!.month == _selectedDate.month &&
                              t.scheduledDate!.day == _selectedDate.day;
                        }).toList();

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppTheme.border, width: 1.1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2C3931).withValues(alpha: 0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.9),
                                blurRadius: 6,
                                offset: const Offset(-2, -2),
                              ),
                            ],
                          ),
                          child: dayTasks.isEmpty
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.event_available_rounded, size: 36, color: AppTheme.primaryGreen),
                                      SizedBox(height: 10),
                                      Text(
                                        'No tasks scheduled for this day',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Create a goal or task to start tracking your daily progress.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: dayTasks.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final task = entry.value;
                                    final color = _getTaskIndicatorColor(idx);

                                    return _buildTaskRow(task, color);
                                  }).toList(),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskRow(TaskItem task, Color indicatorColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3931).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color Indicator Bar
          Container(
            width: 5,
            height: 32,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),

          // Task Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: task.completed ? AppTheme.textMuted : AppTheme.textPrimary,
                    decoration: task.completed ? TextDecoration.lineThrough : null,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  task.time != null ? '${task.time} · ${task.duration}' : task.duration,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Custom Checkbox
          GestureDetector(
            onTap: () => widget.onToggleTask(task),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.completed ? AppTheme.primaryGreen : Colors.transparent,
                border: Border.all(
                  color: task.completed ? AppTheme.primaryGreen : AppTheme.border,
                  width: 1.8,
                ),
              ),
              child: task.completed
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
