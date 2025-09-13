import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // App Logo and Welcome Text
                _buildHeader(),
                
                const SizedBox(height: 48),
                
                // Login Form
                GlassContainer(
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePassword: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your password';
                          }
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      GradientButton(
                        onPressed: authState.isLoading ? null : _login,
                        text: authState.isLoading ? 'Signing In...' : 'Sign In',
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(begin: 20, duration: 600.ms, delay: 200.ms),                
                const SizedBox(height: 24),
                
                // Social Login
                _buildSocialLogin().animate().fadeIn(duration: 600.ms, delay: 400.ms).moveY(begin: 20, duration: 600.ms, delay: 400.ms),
                
                const SizedBox(height: 32),
                
                // Sign Up Link
                _buildSocialLogin().animate().fadeIn(duration: 600.ms, delay: 400.ms).moveY(begin: 20, duration: 600.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.handshake_outlined,
            size: 40,
            color: Colors.white,
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 24),
        
        Text(
          'Welcome to Renty',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(begin: 20, duration: 600.ms, delay: 200.ms),
        
        const SizedBox(height: 8),
        
        Text(
          'Rent and share items within your college community',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(begin: 20, duration: 600.ms, delay: 200.ms),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.divider)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(child: Divider(color: AppColors.divider)),
          ],
        ),
        
        const SizedBox(height: 24),
        
        SocialAuthButton(
          onPressed: _googleSignIn,
          icon: 'assets/icons/google.png',
          text: 'Continue with Google',
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () => context.go('/signup'),
          child: const Text('Sign Up'),
        ),
      ],
    );
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final result = await ref.read(authStateProvider.notifier).signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (result.isSuccess && mounted) {
        context.go('/home');
      }
    }
  }

  void _googleSignIn() async {
    final result = await ref.read(authStateProvider.notifier).signInWithGoogle();
    
    if (result.isSuccess && mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}