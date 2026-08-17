import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class AccountSetupScreen extends StatefulWidget {
  final UserProfile user;
  final Function(UserProfile updatedUser) onSetupComplete;

  const AccountSetupScreen({
    super.key,
    required this.user,
    required this.onSetupComplete,
  });

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  int _currentStep = 0; // 0, 1, 2

  // Page 1 state
  late TextEditingController _nameController;
  String _selectedGreeting = 'Good morning';
  final List<String> _greetings = ['Good morning', 'Welcome back', 'Hello', 'Greetings'];

  // Page 2 state
  final List<String> _availableAreas = [
    'Fitness & Health',
    'Learning & Education',
    'Career Growth',
    'Personal Finance',
    'Mindfulness & Wellness',
    'Creative Projects',
  ];
  final Set<String> _selectedAreas = {'Fitness & Health', 'Learning & Education'};

  // Page 3 state
  String _selectedMorningTime = '7:00 AM';
  final List<String> _morningTimes = ['6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM'];

  String _selectedFocusTarget = '1h 30m';
  final List<String> _focusTargets = ['30 min/day', '1 hour/day', '1h 30m', '2 hours/day'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _selectedGreeting = widget.user.greeting;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _finishSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _finishSetup() async {
    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : widget.user.name,
      greeting: _selectedGreeting,
      preferredAreas: _selectedAreas.toList(),
      morningTime: _selectedMorningTime,
      dailyFocusTarget: _selectedFocusTarget,
    );

    // Save to PostgreSQL via API
    await ApiService.updateProfile(
      email: updatedUser.email,
      name: updatedUser.name,
      greeting: updatedUser.greeting,
      preferredAreas: updatedUser.preferredAreas,
      morningTime: updatedUser.morningTime,
      dailyFocusTarget: updatedUser.dailyFocusTarget,
    );

    widget.onSetupComplete(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textPrimary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  else
                    const SizedBox(width: 24),
                  Text(
                    'Step ${_currentStep + 1} of 3',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 24),
                ],
              ),

              const SizedBox(height: 12),

              // Animated Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3.0,
                  minHeight: 6,
                  backgroundColor: AppTheme.borderSubtle,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
              ),

              const SizedBox(height: 28),

              // Step Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildStepContent(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentStep == 2 ? 'Complete Setup 🎉' : 'Continue',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
      default:
        return _buildStep3();
    }
  }

  // Step 1: Personal Identity & Name
  Widget _buildStep1() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.greenBgSubtle,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 32, color: AppTheme.primaryGreen),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'What should we call you?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.4),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Personalize your GoalFlow experience and daily greeting.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 32),

        // Name Text Field
        const Text('Your Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.primaryGreen, size: 20),
          ),
        ),

        const SizedBox(height: 24),

        // Preferred Greeting Choice
        const Text('Preferred Greeting', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _greetings.map((g) {
            final isSelected = _selectedGreeting == g;
            return ChoiceChip(
              label: Text(g),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedGreeting = g);
              },
              selectedColor: AppTheme.primaryGreen,
              backgroundColor: AppTheme.surfaceElevated,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? AppTheme.primaryGreen : AppTheme.border),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 2: Preferred Goal Focus Areas
  Widget _buildStep2() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD6A856).withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.explore_outlined, size: 32, color: Color(0xFFD6A856)),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Which areas do you prefer?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.4),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Select goal domains that match your personal aspirations.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 28),

        // Domain Selection Cards
        Column(
          children: _availableAreas.map((area) {
            final isSelected = _selectedAreas.contains(area);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedAreas.length > 1) _selectedAreas.remove(area);
                  } else {
                    _selectedAreas.add(area);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.greenBgSubtle : AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryGreen : AppTheme.border,
                    width: isSelected ? 1.6 : 1.1,
                  ),
                  boxShadow: isSelected ? AppTheme.softShadow : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textMuted,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        area,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 3: Daily Routine & Schedule
  Widget _buildStep3() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5FC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF3D6F9D).withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.access_time_rounded, size: 32, color: Color(0xFF3D6F9D)),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Configure your Routine',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.4),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Set your morning check-in time and daily focus target.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 28),

        // Morning Reminder Selector
        const Text('Morning Check-In Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _morningTimes.map((time) {
            final isSelected = _selectedMorningTime == time;
            return ChoiceChip(
              label: Text(time),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedMorningTime = time);
              },
              selectedColor: AppTheme.primaryGreen,
              backgroundColor: AppTheme.surfaceElevated,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? AppTheme.primaryGreen : AppTheme.border),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // Daily Focus Target Selector
        const Text('Daily Focus Goal Target', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _focusTargets.map((target) {
            final isSelected = _selectedFocusTarget == target;
            return ChoiceChip(
              label: Text(target),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFocusTarget = target);
              },
              selectedColor: AppTheme.primaryGreen,
              backgroundColor: AppTheme.surfaceElevated,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? AppTheme.primaryGreen : AppTheme.border),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
