import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/screens/login_screen.dart';

/// Full-screen placeholder shown when a feature requires authentication.
class SignInRequired extends StatelessWidget {
  const SignInRequired({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 56.r, color: Colors.grey),
            SizedBox(height: 12.h),
            Text(
              message ?? 'Sign in to continue',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            const Text(
              'This feature is available for signed-in users.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                // foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(1),

                  side: BorderSide.none,
                ),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              ),
              onPressed: () => _goToLogin(context),
              icon: Icon(Icons.login, size: 18.r),
              label: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }
}

/// Call this before performing an action that requires auth. Returns true if
/// the user is signed in. Otherwise shows a bottom sheet prompting sign-in and
/// returns false.
Future<bool> ensureSignedIn(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) return true;

  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Icon(Icons.lock_outline, size: 40.r, color: Colors.grey),
            SizedBox(height: 12.h),
            const Text(
              'Sign in to continue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6.h),
            const Text(
              'You need an account to use this feature.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Sign in'),
              ),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Not now'),
            ),
          ],
        ),
      );
    },
  );

  return false;
}
