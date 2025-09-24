import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:park_chatapp/core/widgets/auth_wrapper.dart';
import 'package:park_chatapp/features/auth/presentation/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Handle login with Firebase Auth
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Do not navigate manually; AuthWrapper listens to auth changes
      // and will show BottomNavScaffold automatically when signed in.
      // Keeping the screen as-is avoids creating duplicate bottom nav bars.
      // Optionally, you could pop to root, but not required here.
      // if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) await showAppErrorDialog(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle forgot password
  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      await showAppInfoDialog(context, 'Please enter your email first');
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      [
        if (mounted)
          await showAppInfoDialog(
            context,
            'Password reset email sent! Check your inbox.',
          ),
      ];
    } catch (e) {
      if (mounted) await showAppErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w), // Added .w
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 50.h),
                      Column(
                        children: [
                          Text(
                            'Sign In',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: AppColors.primaryRed,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Image.asset(
                            'assets/images/parkview.png',
                            width: 400.w,
                            height: 50.h,
                          ),
                          SizedBox(height: 3.h),
                          // Text('SignIn To Park View City'),
                        ],
                      ),
                      SizedBox(height: 48.h),
                      CustomTextField(
                        label: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h), // Added .h
                      CustomTextField(
                        label: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        obscureText: _obscurePassword,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 👈 Left side
                          Row(
                            children: [
                              Text(
                                'New to Park View City?',
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: AppTextStyles.linkText,
                                ),
                              ),
                            ],
                          ),

                          // 👉 Right side
                          GestureDetector(
                            onTap: _handleForgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.linkText,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h), // Added .h
                      CustomButton(
                        text: 'LOGIN',
                        onPressed: _isLoading ? () {} : () => _handleLogin(),
                        isLoading: _isLoading,
                      ),
                      SizedBox(height: 24.h), // Added .h
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('guest_mode', true);
                              if (!mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const AuthWrapper(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Text(
                              'Guest Sign In',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                          // 👇 Divider between the two
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4.h,
                              horizontal: 60.w,
                            ), // spacing
                            child: Divider(
                              color: AppColors.grey, // line color
                              thickness: 0.6, // line thickness
                            ),
                          ),
                          Text(
                            'or Connect with',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 26.h), // Added .h
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircleIcon('assets/images/facebook.jpg'),
                            _buildCircleIcon('assets/images/insta.jpg'),
                            _buildCircleIcon('assets/images/google.jpg'),
                            _buildCircleIcon('assets/images/apple.png'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildCircleIcon(String assetPath) {
  return CircleAvatar(
    radius: 34, // size of circle
    backgroundColor: Colors.white, // circle background
    child: ClipOval(
      child: Image.asset(assetPath, width: 48, height: 48, fit: BoxFit.contain),
    ),
  );
}
