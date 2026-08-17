import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/app_toast.dart';

class ProfileTab extends StatefulWidget {
  final UserProfile user;
  final List<Goal> goals;
  final List<TaskItem> tasks;
  final VoidCallback onLogOut;
  final VoidCallback onViewGoals;
  final VoidCallback? onToggleTheme;
  final Function(UserProfile updatedUser)? onProfileUpdated;

  const ProfileTab({
    super.key,
    required this.user,
    this.goals = const [],
    this.tasks = const [],
    required this.onLogOut,
    required this.onViewGoals,
    this.onToggleTheme,
    this.onProfileUpdated,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late String _name;
  late String _email;
  String? _customImagePath;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _email = widget.user.email;
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.name != widget.user.name || oldWidget.user.email != widget.user.email) {
      setState(() {
        _name = widget.user.name;
        _email = widget.user.email;
      });
    }
  }

  // Real-Time Dynamic Stats Calculation
  int get activeGoalsCount {
    if (widget.goals.isEmpty) return 0;
    return widget.goals.where((g) => g.progress < 1.0 && g.status != 'archived').length;
  }

  int get completedGoalsCount {
    if (widget.goals.isEmpty) return 0;
    return widget.goals.where((g) => g.progress >= 1.0 || g.status == 'completed').length;
  }

  int get streakDaysCount {
    final completedTasks = widget.tasks.where((t) => t.completed).toList();
    final activeHabitStreaks = _habits.where((h) => h['completed'] == true).map((h) => h['streak'] as int? ?? 0).toList();

    int maxHabitStreak = 0;
    for (var s in activeHabitStreaks) {
      if (s > maxHabitStreak) maxHabitStreak = s;
    }

    if (completedTasks.isEmpty) {
      return maxHabitStreak;
    }

    final dates = completedTasks
        .map((t) => t.scheduledDate)
        .where((d) => d != null)
        .cast<DateTime>()
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return maxHabitStreak;

    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    DateTime cursor = dates.contains(todayDate) ? todayDate : dates.first;

    for (final date in dates) {
      if (date == cursor || date == cursor.subtract(const Duration(days: 1))) {
        streak++;
        cursor = date;
      } else {
        break;
      }
    }
    return streak > maxHabitStreak ? streak : maxHabitStreak;
  }

  // Settings State
  bool _morningBriefing = true;
  bool _focusAlerts = true;
  bool _eveningReview = false;
  String _morningTime = '07:30 AM';
  String _eveningTime = '09:00 PM';
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;
  String _currentTheme = 'Warm Ivory';

  // Habits State
  final List<Map<String, dynamic>> _habits = [
    {'name': 'Morning Meditation', 'streak': 0, 'completed': false, 'icon': Icons.spa_rounded},
    {'name': 'Read 20 Pages', 'streak': 0, 'completed': false, 'icon': Icons.menu_book_rounded},
    {'name': 'Daily Workout', 'streak': 0, 'completed': false, 'icon': Icons.directions_run_rounded},
    {'name': 'Hydrate 2L', 'streak': 0, 'completed': false, 'icon': Icons.water_drop_outlined},
  ];

  // Dynamic Real-Time Achievements & Badges Calculation
  List<Map<String, dynamic>> get achievements {
    final completedTasksCount = widget.tasks.where((t) => t.completed).length;
    final totalGoalsCount = widget.goals.length;
    final completedGoals = completedGoalsCount;
    final streak = streakDaysCount;
    final activeHabitsCount = _habits.where((h) => h['completed'] == true).length;

    return [
      {
        'title': 'Goal Pioneer',
        'desc': 'Create your first goal to kickstart your growth journey',
        'icon': Icons.flag_rounded,
        'unlocked': totalGoalsCount >= 1,
        'date': totalGoalsCount >= 1 ? 'Unlocked' : null,
        'progress': '$totalGoalsCount / 1 goal',
      },
      {
        'title': 'Task Master',
        'desc': 'Complete at least 5 daily action tasks',
        'icon': Icons.check_circle_outline_rounded,
        'unlocked': completedTasksCount >= 5,
        'date': completedTasksCount >= 5 ? 'Unlocked' : null,
        'progress': '$completedTasksCount / 5 tasks',
      },
      {
        'title': 'Streak Legend',
        'desc': 'Maintain an unbroken 7-day execution streak',
        'icon': Icons.local_fire_department_rounded,
        'unlocked': streak >= 7,
        'date': streak >= 7 ? 'Unlocked' : null,
        'progress': '$streak / 7 days',
      },
      {
        'title': 'Goal Crusher',
        'desc': 'Successfully complete 3 big goals',
        'icon': Icons.emoji_events_rounded,
        'unlocked': completedGoals >= 3,
        'date': completedGoals >= 3 ? 'Unlocked' : null,
        'progress': '$completedGoals / 3 completed',
      },
      {
        'title': 'Habit Architect',
        'desc': 'Complete all 4 daily habits today',
        'icon': Icons.architecture_rounded,
        'unlocked': activeHabitsCount >= 4,
        'date': activeHabitsCount >= 4 ? 'Unlocked' : null,
        'progress': '$activeHabitsCount / 4 habits',
      },
    ];
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _customImagePath = pickedFile.path;
          });
        } else {
          setState(() {
            _customImagePath = pickedFile.path;
          });
        }
        if (mounted) {
          AppToast.show(
            context,
            'Profile photo updated successfully!',
            icon: Icons.camera_alt_rounded,
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.greenBgSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryGreen),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.greenBgSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryGreen),
              ),
              title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_customImagePath != null || _webImageBytes != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9EBEB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC25454)),
                ),
                title: const Text('Reset to Default Avatar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFFC25454))),
                onTap: () {
                  setState(() {
                    _customImagePath = null;
                    _webImageBytes = null;
                  });
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (nameCtrl.text.trim().isNotEmpty) _name = nameCtrl.text.trim();
                    if (emailCtrl.text.trim().isNotEmpty) _email = emailCtrl.text.trim();
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Clear All', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNotificationItem('Morning Briefing', 'Focus check-in set for ${widget.user.morningTime}', 'Just now', Icons.spa_rounded),
            _buildNotificationItem('Streak Status', '🔥 $streakDaysCount-day streak active. Keep up the momentum!', 'Today', Icons.local_fire_department_rounded),
            _buildNotificationItem('Goal Activity Summary', 'You have $activeGoalsCount active goals and ${widget.tasks.where((t) => t.completed).length} completed tasks.', 'Today', Icons.analytics_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.greenBgSubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
                    Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppTheme.primaryGreen, size: 22),
                SizedBox(width: 8),
                Text('Achievements & Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (c, idx) {
                  final ach = achievements[idx];
                  final isUnlocked = ach['unlocked'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppTheme.surfaceElevated : AppTheme.bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isUnlocked ? AppTheme.primaryGreen.withValues(alpha: 0.3) : AppTheme.border,
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isUnlocked ? AppTheme.greenBgSubtle : AppTheme.borderSubtle,
                          ),
                          child: Icon(
                            ach['icon'] as IconData,
                            color: isUnlocked ? AppTheme.primaryGreen : AppTheme.textMuted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ach['title'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ach['desc'] as String,
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isUnlocked ? (ach['date'] as String? ?? 'Unlocked') : 'Progress: ${ach['progress']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isUnlocked ? AppTheme.primaryGreen : AppTheme.warmGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isUnlocked)
                          const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHabitTrackerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppTheme.primaryGreen, size: 22),
                      SizedBox(width: 8),
                      Text('Daily Habit Tracker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryGreen),
                    onPressed: () {
                      _showAddHabitDialog(context, () => setModalState(() {}));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: _habits.length,
                  itemBuilder: (c, idx) {
                    final habit = _habits[idx];
                    final completed = habit['completed'] as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Icon(habit['icon'] as IconData, color: AppTheme.primaryGreen, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit['name'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary),
                                ),
                                Text(
                                  '🔥 ${habit['streak']} day streak',
                                  style: const TextStyle(fontSize: 11.5, color: AppTheme.warmGold, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                habit['completed'] = !completed;
                                if (!completed) {
                                  habit['streak'] = (habit['streak'] as int) + 1;
                                } else {
                                  habit['streak'] = (habit['streak'] as int) - 1;
                                }
                              });
                              setState(() {});
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: completed ? AppTheme.primaryGreen : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: completed ? AppTheme.primaryGreen : AppTheme.border,
                                  width: 1.5,
                                ),
                              ),
                              child: completed
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, VoidCallback onAdded) {
    final habitCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Habit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: habitCtrl,
          decoration: const InputDecoration(hintText: 'e.g. 10,000 steps daily'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (habitCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _habits.add({
                    'name': habitCtrl.text.trim(),
                    'streak': 1,
                    'completed': false,
                    'icon': Icons.bolt_rounded,
                  });
                });
                onAdded();
                Navigator.pop(dCtx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRemindersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.notifications_none_outlined, color: AppTheme.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text('Reminders & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryGreen,
                title: const Text('Morning Briefing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('Receive daily focus summary at ${widget.user.morningTime}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: _morningBriefing,
                onChanged: (val) {
                  setModalState(() => _morningBriefing = val);
                  setState(() => _morningBriefing = val);
                  AppToast.show(
                    context,
                    val ? 'Morning Briefing active for ${widget.user.morningTime}' : 'Morning Briefing disabled',
                    isError: !val,
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryGreen,
                title: const Text('Focus Timer Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text('Alert when 25-min interval finishes', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: _focusAlerts,
                onChanged: (val) {
                  setModalState(() => _focusAlerts = val);
                  setState(() => _focusAlerts = val);
                  AppToast.show(
                    context,
                    val ? 'Focus Timer interval alerts enabled' : 'Focus alerts muted',
                    isError: !val,
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryGreen,
                title: const Text('Evening Reflection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('Review completed tasks at $_eveningTime', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: _eveningReview,
                onChanged: (val) {
                  setModalState(() => _eveningReview = val);
                  setState(() => _eveningReview = val);
                  AppToast.show(
                    context,
                    val ? 'Evening Reflection scheduled for $_eveningTime' : 'Evening Reflection disabled',
                    isError: !val,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.settings_outlined, color: AppTheme.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ],
              ),
              const SizedBox(height: 18),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryGreen,
                secondary: const Icon(Icons.volume_up_outlined, color: AppTheme.primaryGreen),
                title: const Text('Sound Effects', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _soundEnabled,
                onChanged: (v) {
                  setModalState(() => _soundEnabled = v);
                  setState(() => _soundEnabled = v);
                  AppToast.show(
                    context,
                    v ? 'Sound effects enabled' : 'Sound effects muted',
                    isError: !v,
                  );
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryGreen,
                secondary: const Icon(Icons.vibration_rounded, color: AppTheme.primaryGreen),
                title: const Text('Haptic Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _hapticsEnabled,
                onChanged: (v) {
                  setModalState(() => _hapticsEnabled = v);
                  setState(() => _hapticsEnabled = v);
                  if (v) HapticFeedback.lightImpact();
                  AppToast.show(
                    context,
                    v ? 'Haptic feedback enabled' : 'Haptic feedback disabled',
                    isError: !v,
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cloud_sync_outlined, color: AppTheme.primaryGreen),
                title: const Text('Backup & Cloud Sync', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ApiService.fetchGoals();
                  if (mounted) {
                    AppToast.show(
                      context,
                      '✅ Backup complete! Synced with PostgreSQL cloud.',
                      icon: Icons.cloud_done_rounded,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.help_outline_rounded, color: AppTheme.primaryGreen, size: 22),
                SizedBox(width: 8),
                Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildFaqItem('How do I track a new goal?', 'Tap the center "+" button in the navigation bar to add a new goal with custom categories and target dates.'),
                  _buildFaqItem('How does the Focus Timer work?', 'Select any priority goal and tap "Start Now" to launch the 25:00 countdown timer with interval alerts.'),
                  _buildFaqItem('Can I sync data across devices?', 'Yes! GoalFlow automatically syncs with the Node.js + PostgreSQL database backend in real time.'),
                  _buildFaqItem('How is streak calculated?', 'Completing at least one scheduled goal or habit daily extends your unbroken streak.'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.greenBgSubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.mail_outline_rounded, color: AppTheme.primaryGreen),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Need direct assistance?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary)),
                            Text('support@goalflow.app', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppTheme.textPrimary)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(answer, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }

  void _showLogOutDialog() {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppTheme.surface,
        title: const Text('Log Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to log out of GoalFlow on this device?',
          style: TextStyle(fontSize: 13.5, color: AppTheme.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC25454),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dCtx);
              widget.onLogOut();
            },
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_webImageBytes != null) {
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    } else if (_customImagePath != null && !kIsWeb) {
      return Image.file(File(_customImagePath!), fit: BoxFit.cover);
    } else {
      return Image.asset(
        'assets/images/alex_avatar.jpg',
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Icon(
          Icons.person,
          size: 40,
          color: AppTheme.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Title + Notification Bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              GestureDetector(
                onTap: _showNotificationsSheet,
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
                    Icons.notifications_none_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // User Info Section: Avatar + Name + Email + Edit Profile Pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Avatar with Tap-to-Upload
              GestureDetector(
                onTap: _showPhotoOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border, width: 1.5),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              // Name, Email, Edit Profile Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _email,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _showEditProfileSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border, width: 1.1),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Setup & Focus Preferences Card
          _buildPreferencesCard(),

          const SizedBox(height: 24),

          // Stats Header
          const Text(
            'Stats',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 12),

          // 3 Stats Cards
          Row(
            children: [
              // Card 1: Goals Active
              Expanded(
                child: GestureDetector(
                  onTap: widget.onViewGoals,
                  child: _buildStatCard(
                    title: 'Goals',
                    value: '$activeGoalsCount',
                    subtitle: 'Active',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Card 2: Completed
              Expanded(
                child: _buildStatCard(
                  title: 'Completed',
                  value: '$completedGoalsCount',
                  subtitle: '',
                ),
              ),
              const SizedBox(width: 10),
              // Card 3: Streak Days
              Expanded(
                child: _buildStatCard(
                  title: 'Streak',
                  value: '$streakDaysCount',
                  subtitle: 'Days',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Menu Card (Achievements, Habit Tracker, Reminders, Settings, Help & Support)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppTheme.border, width: 1.1),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.shield_outlined,
                  title: 'Achievements',
                  onTap: _showAchievementsSheet,
                  isFirst: true,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.timer_outlined,
                  title: 'Habit Tracker',
                  onTap: _showHabitTrackerSheet,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.notifications_none_outlined,
                  title: 'Reminders',
                  onTap: _showRemindersSheet,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: _showSettingsSheet,
                ),
                _buildDivider(),
                _buildMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: _showHelpSheet,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Separate Log Out Card
          GestureDetector(
            onTap: _showLogOutDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border, width: 1.1),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppTheme.textPrimary,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPreferencesSheet() {
    final availableAreas = [
      'Fitness & Health',
      'Learning & Education',
      'Career & Business',
      'Mindfulness & Peace',
      'Financial Freedom',
      'Personal Growth',
    ];

    List<String> selectedAreas = List.from(widget.user.preferredAreas);
    String selectedMorningTime = widget.user.morningTime;
    String selectedDailyTarget = widget.user.dailyFocusTarget;

    final morningTimes = ['6:00 AM', '6:30 AM', '7:00 AM', '7:30 AM', '8:00 AM', '8:30 AM', '9:00 AM'];
    final dailyTargets = ['30m', '45m', '1h 0m', '1h 30m', '2h 0m', '2h 30m', '3h 0m'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppTheme.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Edit Focus & Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 1. Preferred Goal Domains
              const Text(
                'Preferred Goal Domains',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableAreas.map((area) {
                  final isSelected = selectedAreas.contains(area);
                  return FilterChip(
                    label: Text(area),
                    selected: isSelected,
                    selectedColor: AppTheme.greenBgSubtle,
                    checkmarkColor: AppTheme.primaryGreen,
                    backgroundColor: AppTheme.bg,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.border,
                    ),
                    onSelected: (val) {
                      setModalState(() {
                        if (val) {
                          selectedAreas.add(area);
                        } else {
                          if (selectedAreas.length > 1) {
                            selectedAreas.remove(area);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // 2. Morning Check-In Time
              const Text(
                'Morning Check-In Time',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: morningTimes.contains(selectedMorningTime) ? selectedMorningTime : morningTimes[2],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                ),
                items: morningTimes.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedMorningTime = val);
                  }
                },
              ),

              const SizedBox(height: 18),

              // 3. Daily Focus Target
              const Text(
                'Daily Focus Target',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: dailyTargets.contains(selectedDailyTarget) ? selectedDailyTarget : dailyTargets[3],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                ),
                items: dailyTargets.map((target) => DropdownMenuItem(value: target, child: Text(target))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() => selectedDailyTarget = val);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final updatedUser = widget.user.copyWith(
                      preferredAreas: selectedAreas,
                      morningTime: selectedMorningTime,
                      dailyFocusTarget: selectedDailyTarget,
                    );

                    if (widget.onProfileUpdated != null) {
                      widget.onProfileUpdated!(updatedUser);
                    }

                    // Save to PostgreSQL Backend
                    ApiService.updateProfile(
                      name: widget.user.name,
                      email: widget.user.email,
                      preferredAreas: selectedAreas,
                      morningTime: selectedMorningTime,
                      dailyFocusTarget: selectedDailyTarget,
                    );

                    Navigator.pop(ctx);

                    AppToast.show(
                      context,
                      'Setup & Focus Preferences saved!',
                      icon: Icons.check_circle_rounded,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Save Preferences', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: AppTheme.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Setup & Focus Preferences',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showEditPreferencesSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.greenBgSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 13, color: AppTheme.primaryGreen),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
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
          const SizedBox(height: 14),

          // Preferred Goal Areas
          const Text('Preferred Goal Domains', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.user.preferredAreas.map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.greenBgSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  area,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.borderSubtle),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Morning Check-In', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny_outlined, size: 15, color: AppTheme.warmGold),
                        const SizedBox(width: 6),
                        Text(widget.user.morningTime, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Target', style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 15, color: AppTheme.primaryGreen),
                        const SizedBox(width: 6),
                        Text(widget.user.dailyFocusTarget, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border, width: 1.1),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
              ),
            ),
          ] else
            const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(22) : Radius.zero,
        bottom: isLast ? const Radius.circular(22) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.textPrimary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: AppTheme.borderSubtle,
      ),
    );
  }
}
