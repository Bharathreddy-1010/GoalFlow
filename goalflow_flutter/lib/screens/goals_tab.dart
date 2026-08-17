import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/background_video_widget.dart';
import '../widgets/ai_tips_modal.dart';

class GoalsTab extends StatefulWidget {
  final List<Goal> goals;
  final Function(Goal) onGoalTap;
  final VoidCallback onAddGoal;
  final Function(Goal) onToggleGoalComplete;
  final Function(Goal) onDeleteGoal;

  const GoalsTab({
    super.key,
    required this.goals,
    required this.onGoalTap,
    required this.onAddGoal,
    required this.onToggleGoalComplete,
    required this.onDeleteGoal,
  });

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  String _selectedFilter = 'Active';
  final List<String> _filters = ['All', 'Active', 'Completed', 'Archived'];

  @override
  Widget build(BuildContext context) {
    final filteredGoals = widget.goals.where((g) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Active') return g.status != 'archived' && g.progress < 1.0;
      if (_selectedFilter == 'Completed') return g.progress >= 1.0 || g.status == 'completed';
      if (_selectedFilter == 'Archived') return g.status == 'archived';
      return true;
    }).toList();

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video Player (Web HTML5 + Mobile Native)
          Positioned.fill(
            child: BackgroundVideoWidget(
              assetPath: 'assets/videos/goals_page.mp4',
              zoomScale: 1.22,
              fallbackWidget: Container(color: AppTheme.bg),
            ),
          ),

          // Subtle gradient wash for visual depth and contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bg.withValues(alpha: 0.12),
                    AppTheme.bg.withValues(alpha: 0.22),
                    AppTheme.bg.withValues(alpha: 0.38),
                  ],
                ),
              ),
            ),
          ),

          // Foreground Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Goals',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onAddGoal,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Filter Pills
                  Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryGreen : AppTheme.surface.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Goals List with Frosted Backdrop
                  Column(
                    children: filteredGoals.isEmpty
                        ? [_buildEmptyState()]
                        : filteredGoals.map((g) => _buildGoalCard(g)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title = 'No goals created yet';
    String subtitle = 'Create your first goal to monitor and track your progress in real time.';
    String? buttonText = 'Create First Goal';

    if (_selectedFilter == 'Active') {
      title = 'No active goals';
      subtitle = 'All your current goals are completed or archived. Create a new goal to keep moving forward!';
      buttonText = 'Create Goal';
    } else if (_selectedFilter == 'Completed') {
      title = 'No completed goals yet';
      subtitle = 'Keep completing your daily actions! Once a goal reaches 100% progress, it will appear here.';
      buttonText = null;
    } else if (_selectedFilter == 'Archived') {
      title = 'No archived goals';
      subtitle = 'Archived goals will appear here when you archive older or paused goals.';
      buttonText = null;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreenLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedFilter == 'Completed'
                  ? Icons.emoji_events_rounded
                  : (_selectedFilter == 'Archived' ? Icons.archive_rounded : Icons.park_rounded),
              color: AppTheme.primaryGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          if (buttonText != null) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: widget.onAddGoal,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final catColor = AppTheme.getCategoryColor(goal.category);
    final catBg = AppTheme.getCategoryBg(goal.category);
    final bool isCompleted = goal.progress >= 1.0 || goal.status == 'completed';

    return GestureDetector(
      onTap: () => widget.onGoalTap(goal),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.1),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Category Icon Pill
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: catBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(goal.category),
                        size: 18,
                        color: catColor,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Category & Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isCompleted ? AppTheme.textMuted : AppTheme.textPrimary,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Progress Bar + Percentage
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${goal.percentage}%',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 65,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: goal.progress,
                              minHeight: 4.5,
                              backgroundColor: AppTheme.borderSubtle,
                              valueColor: AlwaysStoppedAnimation<Color>(catColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: AppTheme.borderSubtle),
                const SizedBox(height: 10),

                // Action Bar (Mark Complete, AI Tip, Delete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Mark Complete Button
                    InkWell(
                      onTap: () => widget.onToggleGoalComplete(goal),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppTheme.greenBgSubtle : AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCompleted ? AppTheme.primaryGreen : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                              size: 14,
                              color: isCompleted ? AppTheme.primaryGreen : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isCompleted ? 'Completed' : 'Mark Complete',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? AppTheme.primaryGreen : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // AI Tip Button
                    InkWell(
                      onTap: () {
                        AiTipsModal.show(
                          context,
                          goalTitle: goal.title,
                          description: goal.description,
                          category: goal.category,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreenLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 13, color: AppTheme.primaryGreen),
                            SizedBox(width: 4),
                            Text(
                              'AI Tip',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Delete Button
                    InkWell(
                      onTap: () => widget.onDeleteGoal(goal),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9EBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC25454).withValues(alpha: 0.25)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFC25454)),
                            SizedBox(width: 4),
                            Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFC25454),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
