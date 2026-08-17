import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/mountain_painter.dart';
import '../widgets/background_video_widget.dart';
import '../widgets/app_toast.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  final Function(Map<String, dynamic> user, {bool isNewUser}) onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUp = true;
  bool _isLoading = false;

  final List<Map<String, String>> _googleAccounts = [
    {
      'name': 'Bharath B',
      'email': 'bharath404074@gmail.com',
      'status': 'Active',
      'initial': 'B',
      'color': '0xFF3F51B5',
    },
    {
      'name': 'VINAY KUMAR DEVALARAJU',
      'email': 'devalarajuvinaykumar@gmail.com',
      'status': 'Signed out',
      'initial': 'V',
      'color': '0xFF009688',
    },
    {
      'name': 'Bharath Kumar Reddy B',
      'email': 'bharathkumarreddysurefy@gmail.com',
      'status': 'Signed out',
      'initial': 'B',
      'color': '0xFF0288D1',
    },
    {
      'name': 'Bharath Reddy',
      'email': 'bharathboss1005@gmail.com',
      'status': 'Signed out',
      'initial': 'B',
      'color': '0xFF7B1FA2',
    },
    {
      'name': 'M Vishnu Priya',
      'email': 'mswarrior2027@gmail.com',
      'status': 'Signed out',
      'initial': 'M',
      'color': '0xFFE64A19',
    },
  ];

  Future<void> _handleGoogleAuth() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildGoogleAccountChooserModal(ctx),
    );
  }

  Widget _buildGoogleAccountChooserModal(BuildContext modalCtx) {
    return Material(
      color: const Color(0xFF1E1E1E),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle bar
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Google Header: Logo + Title
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEA4335),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose an account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'to continue to GoalFlow',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 8),

              // Google Account List Options
              ..._googleAccounts.map((acc) {
                final String name = acc['name']!;
                final String email = acc['email']!;
                final String status = acc['status']!;
                final String initial = acc['initial']!;
                final Color avatarColor = Color(int.parse(acc['color']!));

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  onTap: () async {
                    Navigator.of(modalCtx).pop();
                    await _processSelectedGoogleAccount(name: name, email: email);
                  },
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarColor,
                    child: Text(
                      initial,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  subtitle: Text(
                    email,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                  trailing: status == 'Signed out'
                      ? const Text(
                          'Signed out',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        )
                      : const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 18),
                );
              }),

              const Divider(color: Colors.white12, height: 16),

              // Use another account option
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                onTap: () async {
                  Navigator.of(modalCtx).pop();
                  _showCustomEmailGoogleDialog();
                },
                leading: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                ),
                title: const Text(
                  'Use another account',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Before using this app, you can review GoalFlow’s Privacy Policy and Terms of Service.',
                style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomEmailGoogleDialog() {
    final customController = TextEditingController(text: 'bharath404074@gmail.com');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Google Sign-In', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your Google email address to verify and sign in:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: customController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'user@gmail.com',
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryGreen)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            onPressed: () async {
              final email = customController.text.trim();
              Navigator.of(ctx).pop();
              if (email.isNotEmpty) {
                await _processSelectedGoogleAccount(name: email.split('@')[0], email: email);
              }
            },
            child: const Text('Verify & Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processSelectedGoogleAccount({required String name, required String email}) async {
    setState(() => _isLoading = true);

    final result = await ApiService.googleAuth(
      email: email,
      name: name,
      googleId: 'google_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
    );

    if (mounted) {
      setState(() => _isLoading = false);
      AppToast.show(
        context,
        result['message'] ?? 'Account verified! Welcome email sent to $email.',
        icon: Icons.verified_user_rounded,
      );
      final bool isNewUser = (result['isNewUser'] == true) || _isSignUp;
      widget.onLoginSuccess({'name': name, 'email': email}, isNewUser: isNewUser);
    }
  }

  Future<void> _handleAppleAuth() async {
    setState(() => _isLoading = true);
    final result = await ApiService.appleAuth();
    if (mounted) {
      setState(() => _isLoading = false);
      AppToast.show(
        context,
        result['message'] ?? 'Apple JWT Auth successful! Welcome email sent.',
        icon: Icons.mark_email_read_rounded,
      );
      final bool isNewUser = (result['isNewUser'] == true) || _isSignUp;
      widget.onLoginSuccess({'name': 'Apple User', 'email': 'apple.user@icloud.com'}, isNewUser: isNewUser);
    }
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> result;
    if (_isSignUp) {
      result = await ApiService.register(name: name.isEmpty ? 'Bharath B' : name, email: email, password: password);
    } else {
      result = await ApiService.login(email: email, password: password);
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == false) {
        AppToast.show(
          context,
          result['message'] ?? 'This email is already registered. Please sign in.',
          isError: true,
        );
        return;
      }

      AppToast.show(
        context,
        result['message'] ?? (_isSignUp ? 'Account created! Welcome email sent.' : 'Signed in successfully!'),
        icon: Icons.mark_email_read_rounded,
      );
      widget.onLoginSuccess(
        {
          'name': result['user']?['name'] ?? (name.isEmpty ? 'Bharath B' : name),
          'email': result['user']?['email'] ?? email,
        },
        isNewUser: _isSignUp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),

              const SizedBox(height: 16),

              // Title & Subtitle
              Text(
                _isSignUp ? 'Create your account' : 'Welcome back',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? 'Start your journey towards a better you.'
                    : 'Sign in to continue your growth journey.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Inputs Container
              if (_isSignUp) ...[
                _buildLabel('Full Name'),
                _buildInputField(
                  controller: _nameController,
                  hintText: 'Enter your name',
                ),
                const SizedBox(height: 16),
              ],

              _buildLabel('Email'),
              _buildInputField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _buildLabel('Password'),
              _buildInputField(
                controller: _passwordController,
                hintText: 'Enter password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 28),

              // Create Account CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Or continue with divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
                ],
              ),

              const SizedBox(height: 20),

              // Social Login Buttons (Google & Apple)
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      iconColor: const Color(0xFFEA4335),
                      label: 'Google',
                      onTap: _handleGoogleAuth,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSocialButton(
                      icon: Icons.apple_rounded,
                      iconColor: Colors.black,
                      label: 'Apple',
                      onTap: _handleAppleAuth,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Switch Sign Up / Sign In
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isSignUp = !_isSignUp),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary, fontFamily: 'Inter'),
                      children: [
                        TextSpan(
                          text: _isSignUp
                              ? 'Already have an account? '
                              : "Don't have an account? ",
                        ),
                        TextSpan(
                          text: _isSignUp ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14.5, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
