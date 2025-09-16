import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_button.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _collegeController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  UserRole _selectedRole = UserRole.student;

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
                const SizedBox(height: 40),
                
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).moveX(begin: -20, duration: 400.ms),
                
                const SizedBox(height: 20),
                
                // App Logo and Welcome Text
                _buildHeader(),
                
                const SizedBox(height: 48),
                
                // Signup Form
                GlassContainer(
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        keyboardType: TextInputType.name,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your full name';
                          }
                          if (value!.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
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
                        prefixIcon: Icons.lock_outline,
                        onTogglePassword: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your password';
                          }
                          if (value!.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                            return 'Password must contain uppercase, lowercase, and number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        isPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        prefixIcon: Icons.lock_outline,
                        onTogglePassword: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // College Field
                      AuthTextField(
                        controller: _collegeController,
                        label: 'College Name',
                        prefixIcon: Icons.school,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter your college name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Role Selection
                      DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role.toString().split('.').last.toUpperCase(),
                            ),
                          );
                        }).toList(),
                        onChanged: (UserRole? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select your role';
                          }
                          return null;
                        },
                      ),
                      
                      // Terms and Conditions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: AppColors.accent,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _acceptTerms = !_acceptTerms;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      GradientButton(
                        onPressed: authState.isLoading ? null : _signup,
                        text: authState.isLoading ? 'Creating Account...' : 'Create Account',
                        isLoading: authState.isLoading,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(begin: 20, duration: 600.ms, delay: 200.ms),                      
                
                const SizedBox(height: 24),
                
                // Social Login
                _buildSocialLogin().animate().fadeIn(duration: 600.ms, delay: 400.ms).moveY(begin: 20, duration: 600.ms, delay: 400.ms),
                
                const SizedBox(height: 32),
                
                // Sign In Link
                _buildSignInLink().animate().fadeIn(duration: 600.ms, delay: 600.ms).moveY(begin: 20, duration: 600.ms, delay: 600.ms),
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
            Icons.person_add_outlined,
            size: 40,
            color: Colors.white,
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 24),
        
        Text(
          'Join Renty',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(begin: 20, duration: 600.ms, delay: 200.ms),
        
        const SizedBox(height: 8),
        
        Text(
          'Create your account and start sharing within your college community',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms).moveY(begin: 20, duration: 600.ms, delay: 300.ms),
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
          onPressed: _googleSignUp,
          icon: 'assets/icons/google.png',
          text: 'Continue with Google',
        ),
      ],
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Sign In'),
        ),
      ],
    );
  }

  void _signup() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await ref.read(authStateProvider.notifier).signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _selectedRole,
      _collegeController.text.trim(),
    );
    
    if (result.isSuccess && mounted) {
      context.go('/home');
    }
  }

  void _googleSignUp() async {
    final result = await ref.read(authStateProvider.notifier).signUpWithGoogle();
    
    if (result.isSuccess && mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
