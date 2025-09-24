import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'report_incident_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  static const String _securityPhoneNumber = '+923001234567';
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<_Alert> _alerts = [];

  @override
  void initState() {
    super.initState();
    // Check authentication status
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to view Security & Alerts')),
        );
        // Optionally redirect to login screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      });
    } else {
      _fetchAlerts();
    }
  }

  void _fetchAlerts() {
    _database.child('alerts').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<_Alert> loadedAlerts = [];
      if (data != null) {
        data.forEach((key, value) {
          try {
            if (value['title'] == null || value['details'] == null) {
              print('Skipping invalid alert $key: missing required fields');
              return;
            }
            loadedAlerts.add(_Alert(
              id: key,
              title: value['title'] ?? '',
              details: value['details'] ?? '',
              time: DateTime.tryParse(value['timestamp'] ?? '') ?? DateTime.now(),
            ));
          } catch (e) {
            print('Error parsing alert $key: $e');
          }
        });
        // Sort by timestamp (newest first)
        loadedAlerts.sort((a, b) => b.time.compareTo(a.time));
      }
      setState(() {
        _alerts = loadedAlerts;
      });
    }, onError: (error) {
      print('Error fetching alerts: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching alerts: $error')),
      );
    });
  }

  Future<void> _callSecurity() async {
    final Uri uri = Uri(scheme: 'tel', path: _securityPhoneNumber);
    await launchUrl(uri);
  }

  String _formatTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(dt.hour);
    final minutes = twoDigits(dt.minute);
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Security & Alerts',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _QuickActionsRow(
            onCall: _callSecurity,
            onPanic: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportIncidentScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Emergency Alerts', style: AppTextStyles.bodyMediumBold),
          const SizedBox(height: 8),
          if (_alerts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No alerts available.'),
              ),
            )
          else
            ..._alerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Colors.red,
                    ),
                    title: Text(
                      alert.title,
                      style: AppTextStyles.bodyMediumBold,
                    ),
                    subtitle: Text(alert.details),
                    trailing: Text(
                      _formatTime(alert.time),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Alert {
  final String id;
  final String title;
  final String details;
  final DateTime time;

  _Alert({
    required this.id,
    required this.title,
    required this.details,
    required this.time,
  });
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onPanic;

  const _QuickActionsRow({required this.onCall, required this.onPanic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            color: AppColors.primaryRed,
            icon: Icons.call,
            title: 'Call Security',
            subtitle: 'Single tap to dial',
            onPressed: onCall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            color: AppColors.primaryRed,
            icon: Icons.report,
            title: 'Report Incident',
            subtitle: 'Tap to report quickly',
            onPressed: onPanic,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onPressed;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: onPressed,
                      child: Text(
                        actionText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}