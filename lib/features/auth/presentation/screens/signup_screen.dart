import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/features/auth/presentation/screens/login_screen.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/signup_checkbox.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _marketingOptIn = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Handle sign up with Firebase Auth
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      // Do not navigate manually; AuthWrapper listens to auth changes
      // and will show BottomNavScaffold automatically when signed in.
      // Keeping the screen as-is avoids creating duplicate bottom nav bars.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 50.w, 20.w, 20.h), // Added .w
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Account',
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
                  SizedBox(height: 48.h), // Added .h
                  CustomTextField(
                    label: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h), // Added .h
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
                  SizedBox(height: 16.h),
                  CustomTextField(
                    label: 'Confirm Password',
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
                  //////// checkbox //////////
                  SizedBox(height: 4.h),
                  SignUpCheckBox(
                    value: _marketingOptIn,
                    onChanged: (val) {
                      setState(() => _marketingOptIn = val ?? false);
                    },
                  ),

                  SizedBox(height: 4.h), // Added .h
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 👈 Left side
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            Text(
                              'New to Park View City?',
                              style: TextStyle(fontSize: 10.sp),
                            ),
                             SizedBox(width: 4.sp),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
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
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h), // Added .h
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _isLoading ? () {} : () => _handleSignUp(),
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 20.h), // Added .h
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
      ),
    );
  }
}

Widget _buildCircleIcon(String assetPath) {
  return CircleAvatar(
    radius: 34.r, // size of circle
    backgroundColor: Colors.white, // circle background
    child: ClipOval(
      child: Image.asset(assetPath, width: 48.w, height: 48.h, fit: BoxFit.contain),
    ),
  );
}
