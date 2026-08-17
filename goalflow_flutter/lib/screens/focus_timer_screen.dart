import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class FocusTimerScreen extends StatefulWidget {
  final Goal? focusGoal;
  final VoidCallback onBack;

  const FocusTimerScreen({
    super.key,
    this.focusGoal,
    required this.onBack,
  });

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  int _selectedMode = 0; // 0: Focus, 1: Break
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
        }
      });
      setState(() => _isRunning = true);
    }
  }

  void _switchMode(int mode) {
    _timer?.cancel();
    setState(() {
      _selectedMode = mode;
      _secondsRemaining = mode == 0 ? 25 * 60 : 5 * 60;
      _isRunning = false;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _selectedMode == 0 ? 25 * 60 : 5 * 60;
    final progress = 1.0 - (_secondsRemaining / totalSeconds);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Focus Timer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.settings_outlined, color: AppTheme.textSecondary, size: 22),
                ],
              ),

              const SizedBox(height: 20),

              // Focus / Break Mode Switcher Pill
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 1.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModePill(0, 'Focus'),
                    const SizedBox(width: 4),
                    _buildModePill(1, 'Break'),
                  ],
                ),
              ),

              const Spacer(),

              // Circular Dial with Concentric Depth
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Shadow Glow
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3931).withOpacity(0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 8,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                  ),

                  // Circular Arc Gauge
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: CircularProgressIndicator(
                      value: progress == 0 ? 0.02 : progress,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.borderSubtle,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                  ),

                  // Inner Time & Label Display
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_secondsRemaining),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedMode == 0 ? 'Focus Time' : 'Break Time',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),

                  // Floating Play/Pause Button at Bottom of Dial
                  Positioned(
                    bottom: 8,
                    child: GestureDetector(
                      onTap: _toggleTimer,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Today's Focus Bottom Card
              if (widget.focusGoal != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Today's Focus",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.getCategoryBg(widget.focusGoal!.category),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.spa_rounded,
                          size: 18,
                          color: AppTheme.getCategoryColor(widget.focusGoal!.category),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.focusGoal!.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.focusGoal!.percentage}%',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModePill(int mode, String label) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppTheme.border, width: 1) : null,
          boxShadow: isSelected ? AppTheme.softShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}
