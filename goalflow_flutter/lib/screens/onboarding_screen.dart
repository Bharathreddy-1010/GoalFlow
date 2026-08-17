import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/mountain_painter.dart';
import '../widgets/background_video_widget.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'titleTop': 'Your goals.\nYour growth.',
      'titleHighlight': 'Every day.',
      'subtitle': 'Plan with purpose, stay consistent\nand achieve more.',
    },
    {
      'titleTop': 'Track progress.\nBuild habits.',
      'titleHighlight': 'Stay focused.',
      'subtitle': 'Turn daily actions into long-term habits\nwith smart streak tracking.',
    },
    {
      'titleTop': 'Achieve more.\nCelebrate wins.',
      'titleHighlight': 'Transform life.',
      'subtitle': 'Unlock your full potential with\npersonalized goal insights & reminders.',
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      setState(() => _currentPage++);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background Video Player (Web HTML5 + Mobile Native)
          Positioned.fill(
            child: BackgroundVideoWidget(
              assetPath: 'assets/videos/home_page.mp4',
              fallbackWidget: Container(
                color: AppTheme.bg,
                child: Center(
                  child: MountainIllustration(
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Soft Gradient Overlay to ensure premium readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.bg.withValues(alpha: 0.40),
                    AppTheme.bg.withValues(alpha: 0.10),
                    AppTheme.bg.withValues(alpha: 0.20),
                    AppTheme.bg.withValues(alpha: 0.55),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Foreground Content & Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // Top Bar: Logo + Skip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.greenBgSubtle,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border, width: 1),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              size: 18,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'GoalFlow',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: widget.onFinish,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          backgroundColor: AppTheme.surface.withValues(alpha: 0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: AppTheme.border, width: 1),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // Center Aligned Animated Text Switcher
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey<int>(_currentPage),
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: -1.0,
                              height: 1.2,
                              fontFamily: 'Inter',
                            ),
                            children: [
                              TextSpan(text: '${currentSlide['titleTop']}\n'),
                              TextSpan(
                                text: currentSlide['titleHighlight'],
                                style: const TextStyle(color: AppTheme.primaryGreen),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentSlide['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Bottom Controls: Carousel Dots + Floating Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 3 Dot Indicators
                      Row(
                        children: List.generate(3, (index) {
                          final isActive = index == _currentPage;
                          return GestureDetector(
                            onTap: () => setState(() => _currentPage = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 6),
                              width: isActive ? 24 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isActive ? AppTheme.primaryGreen : AppTheme.textMuted.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }),
                      ),

                      // Floating Circular Next Button
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _currentPage == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
