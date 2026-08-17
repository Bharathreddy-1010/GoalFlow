import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

import '../widgets/ai_tips_modal.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  final VoidCallback onBack;

  const GoalDetailScreen({
    super.key,
    required this.goal,
    required this.onBack,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Milestones, 2: Actions
  final List<String> _tabs = ['Overview', 'Milestones', 'Actions'];

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.getCategoryColor(widget.goal.category);
    final catBg = AppTheme.getCategoryBg(widget.goal.category);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: catBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.spa_rounded, size: 14, color: catColor),
                        const SizedBox(width: 5),
                        Text(
                          widget.goal.category,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      AiTipsModal.show(
                        context,
                        goalTitle: widget.goal.title,
                        description: widget.goal.description,
                        category: widget.goal.category,
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreenLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 13, color: AppTheme.primaryGreen),
                          SizedBox(width: 4),
                          Text(
                            'AI Advice',
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
                ],
              ),

              const SizedBox(height: 18),

              // Goal Title
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.goal.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Progress Bar + On Track
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.goal.percentage}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: widget.goal.progress,
                          minHeight: 7,
                          backgroundColor: AppTheme.borderSubtle,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.greenBgSubtle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'On Track',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Tabs (Overview, Milestones, Actions)
              Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: AppTheme.border, width: 1.1)
                              : null,
                          boxShadow: isSelected ? AppTheme.softShadow : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              if (_selectedTab == 0) _buildOverviewTab(),
              if (_selectedTab == 1) _buildMilestonesTab(),
              if (_selectedTab == 2) _buildActionsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.border, width: 1.1),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.goal.description.isNotEmpty
                    ? widget.goal.description
                    : 'Create a morning routine that sets a positive tone for the day and improves productivity.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              // Key-Value Grid
              _buildMetaRow(Icons.play_circle_outline_rounded, 'Start Date', widget.goal.startDate),
              const SizedBox(height: 10),
              _buildMetaRow(Icons.flag_outlined, 'Target End Date', widget.goal.targetDate),
              const SizedBox(height: 10),
              _buildMetaRow(Icons.category_outlined, 'Category', widget.goal.category),
              const SizedBox(height: 10),
              _buildMetaRow(Icons.repeat_rounded, 'Frequency', widget.goal.frequency),
              const SizedBox(height: 10),
              _buildMetaRow(Icons.access_time_rounded, 'Reminder', widget.goal.reminderTime),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Progress Section with Bar Chart
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.border, width: 1.1),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.goal.percentage}% completed',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              // 7 Day Activity Bar Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [0.3, 0.6, 0.45, 0.75, 0.5, 0.4, 0.85].map((val) {
                  return Container(
                    width: 6.5,
                    height: 38,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Container(
                      width: 6.5,
                      height: 38 * val,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesTab() {
    final milestones = [
      MilestoneItem(id: '1', title: 'Create a morning routine', progress: 0.6, completed: false),
      MilestoneItem(id: '2', title: 'Build the habit', progress: 0.3, completed: false),
      MilestoneItem(id: '3', title: 'Track progress', progress: 0.0, completed: false, isLocked: true),
    ];

    return Column(
      children: [
        ...milestones.map((m) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border, width: 1.1),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: m.isLocked ? AppTheme.surfaceElevated : AppTheme.greenBgSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      m.id,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: m.isLocked ? AppTheme.textMuted : AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    m.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: m.isLocked ? AppTheme.textMuted : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (m.isLocked)
                  const Icon(Icons.lock_outline_rounded, size: 16, color: AppTheme.textMuted)
                else
                  Text(
                    '${(m.progress * 100).round()}%',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        // Add Milestone Button
        Container(
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
                'Add Milestone',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border, width: 1.1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suggested Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          SizedBox(height: 12),
          Text('• Wake up 15 minutes earlier', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          SizedBox(height: 8),
          Text('• Prepare clothes the night before', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          SizedBox(height: 8),
          Text('• Drink a glass of water immediately', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
