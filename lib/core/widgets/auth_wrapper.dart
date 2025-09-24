import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import 'bottom_nav_scaffold.dart';
import '../../features/SplashScreen/Splash_screen.dart' as splash;
import '../../onboarding/screens/onboarding_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<bool> _hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }

  Future<bool> _isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('guest_mode') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSeenOnboarding(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState != ConnectionState.done) {
          return const splash.SplashScreen();
        }

        final hasSeenOnboarding = onboardingSnapshot.data ?? false;

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const splash.SplashScreen();
            }

            final user = authSnapshot.data;

            // If user is signed in, land on persistent bottom navigation scaffold
            if (user != null) {
              // Clear guest mode when a real user is signed in
              SharedPreferences.getInstance().then(
                (p) => p.setBool('guest_mode', false),
              );
              return const BottomNavScaffold();
            }

            // If not signed in, check if guest mode is enabled
            return FutureBuilder<bool>(
              future: _isGuestMode(),
              builder: (context, guestSnapshot) {
                if (guestSnapshot.connectionState != ConnectionState.done) {
                  return const splash.SplashScreen();
                }
                final isGuest = guestSnapshot.data ?? false;
                if (isGuest) {
                  return const BottomNavScaffold();
                }

                // If not signed in and onboarding not seen, show onboarding
                if (!hasSeenOnboarding) {
                  return const OnboardingScreen();
                }

                // Not signed in and already saw onboarding -> go to Login
                return const LoginScreen();
              },
            );
          },
        );
      },
    );
  }
}
