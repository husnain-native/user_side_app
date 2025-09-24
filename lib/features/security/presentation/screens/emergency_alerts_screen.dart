import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class EmergencyAlertsScreen extends StatefulWidget {
  const EmergencyAlertsScreen({super.key});

  @override
  State<EmergencyAlertsScreen> createState() => _EmergencyAlertsScreenState();
}

class _EmergencyAlertsScreenState extends State<EmergencyAlertsScreen> {
  final List<_Alert> _alerts = <_Alert>[
    _Alert(
      title: 'Power outage',
      details: 'Expected restoration in 2 hours',
      time: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    _Alert(
      title: 'Gate incident',
      details: 'Traffic slowed near Gate 2',
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Emergency alerts',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final _Alert alert = _alerts[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.red,
              ),
              title: Text(alert.title, style: AppTextStyles.bodyMediumBold),
              subtitle: Text(alert.details),
              trailing: Text(
                _formatTime(alert.time),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(dt.hour);
    final minutes = twoDigits(dt.minute);
    return '$hours:$minutes';
  }
}

class _Alert {
  final String title;
  final String details;
  final DateTime time;

  _Alert({required this.title, required this.details, required this.time});
}
