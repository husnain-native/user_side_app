import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/services/auth_service.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payments_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/favorites_screen.dart';
import 'package:park_chatapp/features/property/presentation/screens/property_explore_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:park_chatapp/features/security/presentation/screens/security_screen.dart';
import 'package:park_chatapp/features/complaints/presentation/screens/complaints_screen.dart';
import 'package:park_chatapp/features/lost_found/presentation/screens/lost_found_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/marketplace_screen.dart';
import 'package:park_chatapp/core/widgets/auth_wrapper.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
backgroundColor: const Color.fromARGB(255, 243, 234, 226),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(authService: _authService),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerTile(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.explore,
                    label: 'Explore Properties',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PropertyExploreScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.chat,
                    label: 'Chat',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChatListScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.payment,
                    label: 'Payments',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentsScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.security,
                    label: 'Security',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SecurityScreen()),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.feedback,
                    label: 'Complaints',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ComplaintsScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.find_in_page,
                    label: 'Lost & Found',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LostFoundScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.shopping_cart,
                    label: 'Marketplace',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MarketplaceScreen(),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.favorite,
                    
                    label: 'Favorites',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: AppColors.primaryRed),
                  _drawerTile(
                    context,
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      _showSnack(context, 'Settings coming soon');
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      _showSnack(context, 'Support coming soon');
                    },
                  ),
                  _drawerTile(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(12.w),
            //   child: Text(
            //     'Version 1.0.0',
            //     textAlign: TextAlign.center,
            //     style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: const Icon(Icons.circle, color: Colors.transparent),
      title: Row(
        children: [
          Icon(icon, color: AppColors.primaryRed),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.bold),
            ),

          ),
        ],
      ),
      onTap: onTap,
      horizontalTitleGap: 0,
      trailing: const Icon(Icons.chevron_right, color: AppColors.primaryRed),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _handleLogout(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.black),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Sign out and reset navigation to auth wrapper
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _DrawerHeader extends StatelessWidget {
  final AuthService authService;

  const _DrawerHeader({required this.authService});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryRed.withOpacity(0.1),
            AppColors.primaryRed.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.w,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            child: Icon(Icons.person, color: AppColors.primaryRed, size: 28.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  user?.displayName ?? 'User',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.black),
                ),
                SizedBox(height: 4.h),
                Text(
                  user?.email ?? 'user@example.com',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
