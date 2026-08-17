import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'services/api_service.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/create_goal_sheet.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_tab.dart';
import 'screens/today_tab.dart';
import 'screens/goals_tab.dart';
import 'screens/goal_detail_screen.dart';
import 'screens/focus_timer_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_tab.dart';
import 'screens/account_setup_screen.dart';

void main() {
  runApp(const GoalFlowApp());
}

class GoalFlowApp extends StatefulWidget {
  const GoalFlowApp({super.key});

  @override
  State<GoalFlowApp> createState() => _GoalFlowAppState();
}

class _GoalFlowAppState extends State<GoalFlowApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoalFlow — Personal Daily Goal Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: RootNavigationContainer(onToggleTheme: _toggleTheme),
    );
  }
}

class RootNavigationContainer extends StatefulWidget {
  final VoidCallback? onToggleTheme;

  const RootNavigationContainer({super.key, this.onToggleTheme});

  @override
  State<RootNavigationContainer> createState() => _RootNavigationContainerState();
}

class _RootNavigationContainerState extends State<RootNavigationContainer> {
  // Navigation State
  bool _hasSeenOnboarding = false;
  bool _isAuthenticated = false;
  bool _isSetupComplete = false;
  int _currentTabIndex = 0;

  // Active Data State (Clean start for real-time goal creation workflow)
  UserProfile _user = UserProfile(
    name: 'Bharath B',
    email: 'bharath404074@gmail.com',
    greeting: 'Good morning',
    completionRate: 0,
    tasksCompleted: 0,
    focusHours: '0h 0m',
  );

  List<Goal> _goals = [];
  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchBackendData();
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('MMM dd, yyyy').parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  List<TaskItem> _generateTasksForGoals(List<Goal> goals) {
    final generatedTasks = <TaskItem>[];
    for (var goal in goals) {
      final start = _parseDate(goal.startDate);
      final end = _parseDate(goal.targetDate);

      final startDateOnly = DateTime(start.year, start.month, start.day);
      final endDateOnly = DateTime(end.year, end.month, end.day);

      DateTime cursor = startDateOnly;
      int dayIndex = 1;
      final totalDays = goal.totalTimelineDays;
      final completedDaysCount = (goal.progress * totalDays).round();

      while (!cursor.isAfter(endDateOnly)) {
        final isCompleted = dayIndex <= completedDaysCount;

        generatedTasks.add(
          TaskItem(
            id: 't_${goal.id}_$dayIndex',
            goalId: goal.id,
            title: 'Daily Action: ${goal.title}',
            duration: '25 min',
            time: '8:00 AM',
            completed: isCompleted,
            scheduledDate: cursor,
          ),
        );
        cursor = cursor.add(const Duration(days: 1));
        dayIndex++;
      }
    }
    return generatedTasks;
  }

  Future<void> _fetchBackendData() async {
    final remoteGoals = await ApiService.fetchGoals();
    if (mounted && remoteGoals.isNotEmpty) {
      final tasks = _generateTasksForGoals(remoteGoals);
      setState(() {
        _goals = remoteGoals;
        _tasks = tasks;
      });
    }
  }

  void _openGoalDetail(Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => GoalDetailScreen(
          goal: goal,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _openFocusTimer(Goal? goal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => FocusTimerScreen(
          focusGoal: goal ?? (_goals.isNotEmpty ? _goals.first : null),
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _openCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => CalendarScreen(
          tasks: _tasks,
          onToggleTask: _toggleTask,
          onBack: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _openCreateGoalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateGoalSheet(
        onCreateGoal: ({
          required String title,
          required String description,
          required String category,
          required String startDate,
          required String targetDate,
        }) async {
          final goalId = 'g_${DateTime.now().millisecondsSinceEpoch}';

          final newGoal = Goal(
            id: goalId,
            title: title,
            description: description.isEmpty ? 'Track progress daily to achieve your goal.' : description,
            category: category,
            progress: 0.0, // Initial progress 0%
            startDate: startDate,
            targetDate: targetDate,
            isTodayFocus: _goals.isEmpty,
            milestones: [
              MilestoneItem(id: 'm1', title: 'Initial goal setup', progress: 0.05, completed: true),
              MilestoneItem(id: 'm2', title: 'First progress check-in', progress: 0.0, completed: false),
              MilestoneItem(id: 'm3', title: 'Achieve 50% target', progress: 0.0, completed: false),
            ],
          );

          final updatedGoals = [newGoal, ..._goals];
          final updatedTasks = _generateTasksForGoals(updatedGoals);

          setState(() {
            _goals = updatedGoals;
            _tasks = updatedTasks;
          });

          // Persist Goal to PostgreSQL backend in Real Time
          await ApiService.createGoal(
            title: title,
            description: description,
            category: category,
            startDate: startDate,
            targetDate: targetDate,
          );
        },
      ),
    );
  }

  void _toggleTask(TaskItem task) {
    setState(() {
      task.completed = !task.completed;

      // Find matching Goal to update progress based on timeline duration
      final goalIndex = _goals.indexWhere((g) => g.id == task.goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final double increment = goal.dailyProgressIncrement;
        final double newProgress = task.completed
            ? (goal.progress + increment).clamp(0.0, 1.0)
            : (goal.progress - increment).clamp(0.0, 1.0);

        _goals[goalIndex] = goal.copyWith(progress: newProgress);

        // Sync with PostgreSQL
        ApiService.logProgress(
          goalId: goal.id,
          valueAdded: task.completed ? (increment * 100) : -(increment * 100),
          note: task.completed ? 'Completed daily task' : 'Unchecked daily task',
        );
      } else if (_goals.isNotEmpty) {
        // Fallback for general task toggle
        final goal = _goals.first;
        final double increment = goal.dailyProgressIncrement;
        final double newProgress = task.completed
            ? (goal.progress + increment).clamp(0.0, 1.0)
            : (goal.progress - increment).clamp(0.0, 1.0);
        _goals[0] = goal.copyWith(progress: newProgress);

        ApiService.logProgress(
          goalId: goal.id,
          valueAdded: task.completed ? (increment * 100) : -(increment * 100),
          note: 'Toggled task',
        );
      }
    });
  }

  void _deleteTask(TaskItem task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
  }

  void _deleteGoal(Goal goal) {
    setState(() {
      _goals.removeWhere((g) => g.id == goal.id);
      _tasks.removeWhere((t) => t.goalId == goal.id);
    });
  }

  void _toggleGoalComplete(Goal goal) {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        final isCurrentlyCompleted = goal.progress >= 1.0 || goal.status == 'completed';
        final double newProgress = isCurrentlyCompleted ? 0.0 : 1.0;
        final String newStatus = isCurrentlyCompleted ? 'active' : 'completed';

        _goals[index] = goal.copyWith(
          progress: newProgress,
          status: newStatus,
        );

        ApiService.logProgress(
          goalId: goal.id,
          valueAdded: isCurrentlyCompleted ? -100.0 : 100.0,
          note: isCurrentlyCompleted ? 'Marked active' : 'Marked complete',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Show Onboarding first if not seen
    if (!_hasSeenOnboarding) {
      return OnboardingScreen(
        onFinish: () => setState(() => _hasSeenOnboarding = true),
      );
    }
    // 2. Show Auth screen if not logged in
    if (!_isAuthenticated) {
      return AuthScreen(
        onLoginSuccess: (userMap, {bool isNewUser = false}) {
          setState(() {
            _user = UserProfile(
              name: userMap['name'] ?? 'Bharath B',
              email: userMap['email'] ?? 'bharath404074@gmail.com',
              greeting: 'Good morning',
              completionRate: 0,
              tasksCompleted: 0,
              focusHours: '0h 0m',
            );
            _isAuthenticated = true;
            _isSetupComplete = !isNewUser; // Skip onboarding wizard for returning users, show wizard for new signups!
          });
          _fetchBackendData();
        },
      );
    }

    // 3. Show 3-Step Account Setup Wizard before redirecting to dashboard
    if (!_isSetupComplete) {
      return AccountSetupScreen(
        user: _user,
        onSetupComplete: (updatedUser) {
          setState(() {
            _user = updatedUser;
            _isSetupComplete = true;
          });
          if (_goals.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _openCreateGoalModal();
            });
          }
        },
      );
    }

    // 3. Main Dashboard with Floating Bottom Navigation
    final Goal? todayFocusGoal = _goals.isNotEmpty
        ? _goals.firstWhere(
            (g) => g.isTodayFocus,
            orElse: () => _goals.first,
          )
        : null;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            // Tab 0: Home
            HomeTab(
              user: _user,
              goals: _goals,
              onStartFocus: () => _openFocusTimer(todayFocusGoal),
              onViewAllGoals: () => setState(() => _currentTabIndex = 2),
              onGoalTap: _openGoalDetail,
            ),

            // Tab 1: Today Tasks & Routines
            TodayTab(
              topPriorityGoal: todayFocusGoal ??
                  Goal(
                    id: 'placeholder',
                    title: 'Create your first goal to start tracking',
                    description: 'Tap + below to set up your primary goal',
                    category: 'Personal',
                    progress: 0.0,
                  ),
              tasks: _tasks,
              onToggleTask: _toggleTask,
              onDeleteTask: _deleteTask,
              onAddTask: _openCreateGoalModal,
              onCalendarTap: _openCalendar,
              onContinueGoal: () {
                if (todayFocusGoal != null) {
                  _openGoalDetail(todayFocusGoal);
                } else {
                  _openCreateGoalModal();
                }
              },
            ),

            // Tab 2: Goals
            GoalsTab(
              goals: _goals,
              onGoalTap: _openGoalDetail,
              onAddGoal: _openCreateGoalModal,
              onToggleGoalComplete: _toggleGoalComplete,
              onDeleteGoal: _deleteGoal,
            ),

            // Tab 3: Profile
            ProfileTab(
              user: _user,
              goals: _goals,
              tasks: _tasks,
              onLogOut: () => setState(() => _isAuthenticated = false),
              onViewGoals: () => setState(() => _currentTabIndex = 2),
              onToggleTheme: widget.onToggleTheme,
              onProfileUpdated: (updatedUser) {
                setState(() {
                  _user = updatedUser;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        onAddTap: _openCreateGoalModal,
      ),
    );
  }
}
