import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:park_chatapp/features/chat/presentation/screens/direct_chat_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/core/widgets/auth_wrapper.dart';
import 'package:park_chatapp/features/chat/presentation/screens/create_group_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/group_chat_screen.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';
import 'package:park_chatapp/features/property/presentation/screens/AddEditPropertyScreen.dart';
import 'package:park_chatapp/features/property/presentation/screens/my_listings_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/utility_bills_reference_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/possession_charges_reference_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if not already initialized
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // Firebase might already be initialized, continue
    print('Firebase initialization: $e');
  }

  // Activate Firebase App Check with debug providers during development
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    // ignore: avoid_print
    print('AppCheck activation failed: $e');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // ignore: avoid_print
    print('FlutterError: \\n${details.exceptionAsString()}\\n${details.stack}');
  };

  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // ignore: avoid_print
    print('Uncaught zone error: $error');
    // ignore: avoid_print
    print(stack);
    return true; // handled
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        412,
        915,
      ), // Design dimensions (default is iPhone 13 size)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(),
          routes: {
            '/create_group': (context) => const CreateGroupScreen(),
            '/AddEditPropertyScreen':
                (context) => const AddEditPropertyScreen(),
            '/my_listings': (context) => const MyListingsScreen(),
            '/utility_bills': (context) => const UtilityBillReferenceScreen(),
            '/possession_charges':
                (context) => const PossessionChargesReferenceScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/group_chat') {
              final Group group = settings.arguments as Group;
              return MaterialPageRoute(
                builder: (_) => GroupChatScreen(group: group),
              );
            }
            if (settings.name == '/chat') {
              final Map<String, dynamic> args =
                  settings.arguments as Map<String, dynamic>;
              final String threadId = args['threadId'] as String;
              final String sellerName = args['sellerName'] as String;
              return MaterialPageRoute(
                builder: (_) => DirectChatScreen(sellerName: sellerName),
              );
            }
            return null;
          },
          home: child,
        );
      },
      child: AuthWrapper(), // Use auth wrapper to handle auth state
    );
  }
}
