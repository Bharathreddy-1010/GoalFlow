import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/plant_painter.dart';
import '../widgets/background_video_widget.dart';
import '../widgets/ai_tips_modal.dart';

class HomeTab extends StatelessWidget {
  final UserProfile user;
  final List<Goal> goals;
  final VoidCallback onStartFocus;
  final VoidCallback onViewAllGoals;
  final Function(Goal) onGoalTap;

  const HomeTab({
    super.key,
    required this.user,
    required this.goals,
    required this.onStartFocus,
    required this.onViewAllGoals,
    required this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    final focusGoal = goals.isNotEmpty
        ? goals.firstWhere(
            (g) => g.isTodayFocus,
            orElse: () => goals.first,
          )
        : null;

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video Player (Web HTML5 + Mobile Native)
          Positioned.fill(
            child: BackgroundVideoWidget(
              assetPath: 'assets/videos/home.mp4',
              fallbackWidget: Container(color: AppTheme.bg),
            ),
          ),

          // Subtle gradient wash so video shines through with optimal contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bg.withValues(alpha: 0.35),
                    AppTheme.bg.withValues(alpha: 0.45),
                    AppTheme.bg.withValues(alpha: 0.60),
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
              // Greeting Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.greeting}, ${user.name} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Let's make today productive.",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border.withValues(alpha: 0.8), width: 1.1),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Today's Focus Hero Card with Frosted Backdrop
              _buildTodayFocusCard(context, focusGoal),

              const SizedBox(height: 18),

              // ✨ AI Daily Insight Card — Prominent AI Feature
              _buildAiInsightCard(context),

              const SizedBox(height: 18),

              // Overall Progress Card with Frosted Backdrop
              _buildOverallProgressCard(context),

              const SizedBox(height: 22),

              // My Goals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Goals',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewAllGoals,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border.withValues(alpha: 0.6)),
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Goals Mini List
              Column(
                children: goals.isEmpty
                    ? [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.park_rounded, color: AppTheme.primaryGreen, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'No goals added yet',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap + to create your first goal in real time.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        )
                      ]
                    : goals.take(3).map((g) => _buildMiniGoalCard(g)).toList(),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildAiInsightCard(BuildContext context) {
    final focusGoal = goals.isNotEmpty
        ? goals.firstWhere((g) => g.isTodayFocus, orElse: () => goals.first)
        : null;

    return GestureDetector(
      onTap: () {
        AiTipsModal.show(
          context,
          goalTitle: focusGoal?.title ?? 'Daily productivity',
          description: focusGoal?.description ?? 'Get personalized AI-powered advice for your goals',
          category: focusGoal?.category ?? 'Learning',
          taskTitle: 'Daily focus',
          showCategorySelector: true,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.12),
                  AppTheme.primaryGreenLight.withValues(alpha: 0.25),
                  AppTheme.surface.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // AI Icon with glow
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✨ AI Daily Insight',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Select domain for AI tips (Learning, Fitness, Health...)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTodayFocusCard(BuildContext context, Goal? goal) {
    if (goal == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Focus",
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                ),
                SizedBox(height: 8),
                Text(
                  "No active focus goal set",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 4),
                Text(
                  "Create your first goal to set today's priority focus.",
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Focus",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted.withValues(alpha: 0.9),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.52,
                    child: Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Progress Bar & Percentage
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 6,
                            backgroundColor: AppTheme.borderSubtle,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${goal.percentage}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Start Now Button
                  GestureDetector(
                    onTap: onStartFocus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Start Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Potted Sprout Plant Graphic on the Right
              const Positioned(
                right: 0,
                bottom: 0,
                child: PlantIllustration(size: 88),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallProgressCard(BuildContext context) {
    final days = [
      DayProgress(day: 'M', value: 0.4),
      DayProgress(day: 'T', value: 0.7),
      DayProgress(day: 'W', value: 0.5),
      DayProgress(day: 'T', value: 0.85),
      DayProgress(day: 'F', value: 0.6),
      DayProgress(day: 'S', value: 0.3),
      DayProgress(day: 'S', value: 0.9, isToday: true),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "You're doing great!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Circular Dynamic Overall Progress Badge
                  Builder(
                    builder: (context) {
                      final double avgProgress = goals.isNotEmpty
                          ? (goals.fold<double>(0.0, (sum, g) => sum + g.progress) / goals.length)
                          : 0.0;
                      final int overallPct = (avgProgress * 100).round();

                      return Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.greenBgSubtle.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3), width: 1.2),
                        ),
                        child: Center(
                          child: Text(
                            '$overallPct%',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 7 Day Activity Bar Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((d) {
                  final barHeight = 44.0 * d.value;
                  return Column(
                    children: [
                      Container(
                        width: 7,
                        height: 44,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          color: AppTheme.borderSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Container(
                          width: 7,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: d.isToday ? AppTheme.primaryGreen : AppTheme.primaryGreenLight.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.day,
                        style: TextStyle(
                          fontSize: 11,
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
        ),
      ),
    );
  }

  Widget _buildMiniGoalCard(Goal goal) {
    final catColor = AppTheme.getCategoryColor(goal.category);
    final catBg = AppTheme.getCategoryBg(goal.category);

    return GestureDetector(
      onTap: () => onGoalTap(goal),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.1),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${goal.percentage}%',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary.withValues(alpha: 0.9),
                  ),
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
