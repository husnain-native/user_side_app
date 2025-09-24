import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class FirebaseTestWidget extends StatefulWidget {
  const FirebaseTestWidget({super.key});

  @override
  State<FirebaseTestWidget> createState() => _FirebaseTestWidgetState();
}

class _FirebaseTestWidgetState extends State<FirebaseTestWidget> {
  final AuthService _authService = AuthService();
  String _status = 'Checking Firebase status...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  Future<void> _checkFirebaseStatus() async {
    try {
      // Check if Firebase is initialized
      final apps = Firebase.apps;
      if (apps.isNotEmpty) {
        setState(() {
          _status = '✅ Firebase is initialized (${apps.length} app(s))';
        });
      } else {
        setState(() {
          _status = '❌ Firebase is not initialized';
        });
      }

      // Check current user
      final user = _authService.currentUser;
      if (user != null) {
        setState(() {
          _status += '\n✅ User is signed in: ${user.email}';
        });
      } else {
        setState(() {
          _status += '\nℹ️ No user is signed in';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Firebase error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            const Text(
              'Firebase Authentication Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '• If you see "Firebase is initialized" - Firebase is working\n'
              '• If you see "User is signed in" - Authentication is working\n'
              '• The reCAPTCHA warnings in logs are normal for development\n'
              '• App Check warnings are also normal for development',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkFirebaseStatus,
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }
}
