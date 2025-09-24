// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/features/auth/presentation/screens/signup_screen.dart';
import '../config/onboarding_config.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // PageView controller to manage pages programmatically
  final PageController _pageController = PageController();

  // Track current page index
  int _currentPage = 0;

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    _pageController.dispose();
    super.dispose();
  }

  // Navigate to next page or finish onboarding
  void _onNextPressed() {
    if (_currentPage < OnboardingConfig.totalPages - 1) {
      // Go to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - go to home screen
      _navigateToHome();
    }
  }

  // Skip onboarding and go directly to home
  void _onSkipPressed() {
    _navigateToHome();
  }

  // Navigate to sign up screen after onboarding
  void _navigateToHome() {
    _markOnboardingSeen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  // Update current page index when user swipes
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Column(
          children: [
            // Main PageView - takes most of the screen
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: OnboardingConfig.totalPages,
                itemBuilder: (context, index) {
                  final pageData = OnboardingConfig.getPage(index);

                  return OnboardingPage(
                    data: pageData,
                    currentPage: _currentPage,
                    totalPages: OnboardingConfig.totalPages,
                    onNextPressed: _onNextPressed,

                    onSkipPressed: _onSkipPressed,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
