import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:park_chatapp/core/services/auth_service.dart';
import 'package:park_chatapp/core/services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _marketingEmails = false;
  bool _smsAlerts = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('pref_notifications') ?? true;
      _marketingEmails = prefs.getBool('pref_marketing_emails') ?? false;
      _smsAlerts = prefs.getBool('pref_sms_alerts') ?? false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _onSignOut() async {
    try {
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      _showSnack('Sign out failed: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Settings'), centerTitle: true, backgroundColor: AppColors.white,),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          _SectionHeader('Account'),
          _UserTile(user: user),
          SizedBox(height: 8.h),
          _CardWrap(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showSnack('Profile editing coming soon');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showSnack('Password change coming soon');
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),
          _SectionHeader('Appearance'),
          _CardWrap(
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeService.instance.themeModeNotifier,
                builder: (context, mode, _) {
                  return ListTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: const Text('Theme'),
                    subtitle: Text(
                      mode == ThemeMode.dark
                          ? 'Dark'
                          : mode == ThemeMode.light
                          ? 'Light'
                          : 'System',
                    ),
                    trailing: DropdownButton<ThemeMode>(
                      value: mode,
                      underline: const SizedBox.shrink(),
                      dropdownColor: AppColors.white,
                      onChanged: (val) {
                        if (val != null) {
                          ThemeService.instance.setThemeMode(val);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),
          _SectionHeader('Notifications'),
          _CardWrap(
            children: [
              SwitchListTile(
                value: _notificationsEnabled,
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Enable notifications'),
                onChanged: (v) {
                  setState(() => _notificationsEnabled = v);
                  _savePref('pref_notifications', v);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: _marketingEmails,
                secondary: const Icon(Icons.email_outlined),
                title: const Text('Marketing emails'),
                onChanged: (v) {
                  setState(() => _marketingEmails = v);
                  _savePref('pref_marketing_emails', v);
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                value: _smsAlerts,
                secondary: const Icon(Icons.sms_outlined),
                title: const Text('SMS alerts'),
                onChanged: (v) {
                  setState(() => _smsAlerts = v);
                  _savePref('pref_sms_alerts', v);
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),
          _SectionHeader('Support'),
          _CardWrap(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showSnack('Help & Support coming soon');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showSnack('Privacy Policy coming soon');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showSnack('Terms coming soon');
                },
              ),
            ],
          ),

          SizedBox(height: 16.h),
          _SignOutButton(onPressed: _onSignOut),
          SizedBox(height: 8.h),
          Center(
            child: Text('v1.0.0', style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final display =
        user?.displayName?.isNotEmpty == true
            ? user!.displayName!
            : (user?.email ?? 'Guest');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24.r,
        child: Text(
          display.isNotEmpty ? display[0].toUpperCase() : '?',
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
      title: Text(display),
      subtitle: Text(user?.email ?? 'Signed in as Guest'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 4.h),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CardWrap extends StatelessWidget {
  const _CardWrap({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(children: children),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout),
        label: const Text('Sign out'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}
