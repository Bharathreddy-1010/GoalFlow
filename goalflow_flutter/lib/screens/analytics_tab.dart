import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AnalyticsTab extends StatefulWidget {
  final UserProfile user;
  final List<Goal> goals;

  const AnalyticsTab({
    super.key,
    required this.user,
    required this.goals,
  });

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Goals', 'Habits', 'Tasks'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Tabs Row
          Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // This Week Card
          _buildThisWeekCard(),

          const SizedBox(height: 24),

          // Goal Progress Header
          const Text(
            'Goal Progress',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Goal Progress List
          Column(
            children: widget.goals.map((g) => _buildGoalProgressRow(g)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeekCard() {
    final days = [
      DayProgress(day: 'M', value: 0.35),
      DayProgress(day: 'T', value: 0.7),
      DayProgress(day: 'W', value: 0.5),
      DayProgress(day: 'T', value: 0.8),
      DayProgress(day: 'F', value: 0.65),
      DayProgress(day: 'S', value: 0.4),
      DayProgress(day: 'S', value: 0.9, isToday: true),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border, width: 1.1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // 2x2 Metric Summary Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion Rate',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.user.completionRate}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '+12% from last week',
                      style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasks Completed',
                      style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.user.tasksCompleted}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '+6 from last week',
                      style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Focus Time Metric
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus Time',
                style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted.withOpacity(0.9)),
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.focusHours,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bar Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              return Column(
                children: [
                  Container(
                    width: 6.5,
                    height: 40,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Container(
                      width: 6.5,
                      height: 40 * d.value,
                      decoration: BoxDecoration(
                        color: d.isToday ? AppTheme.primaryGreen : AppTheme.primaryGreenLight.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d.day,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: d.isToday ? FontWeight.w700 : FontWeight.w500,
                      color: d.isToday ? AppTheme.primaryGreen : AppTheme.textMuted,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressRow(Goal goal) {
    final catColor = AppTheme.getCategoryColor(goal.category);
    final catBg = AppTheme.getCategoryBg(goal.category);

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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: catBg,
              shape: BoxShape.circle,
            ),
            child: Icon(_getCategoryIcon(goal.category), size: 16, color: catColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 4,
                    backgroundColor: AppTheme.borderSubtle,
                    valueColor: AlwaysStoppedAnimation<Color>(catColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${goal.percentage}%',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.spa_rounded;
      case 'learning':
        return Icons.menu_book_rounded;
      case 'fitness':
        return Icons.directions_run_rounded;
      case 'career':
        return Icons.work_outline_rounded;
      case 'finance':
        return Icons.account_balance_wallet_outlined;
      case 'personal':
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
