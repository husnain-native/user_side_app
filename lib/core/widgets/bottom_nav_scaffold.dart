import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/features/auth/presentation/screens/home_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/unified_marketplace_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/favorites_screen.dart';

/// A persistent bottom navigation scaffold with nested navigators per tab.
///
/// - Uses an IndexedStack so tab state is preserved and not rebuilt each time.
/// - Each tab has its own Navigator allowing deep navigation inside a tab
///   while keeping the bottom bar visible.
class BottomNavScaffold extends StatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  int _currentIndex = 0;

  Future<bool> _onWillPop() async {
    final NavigatorState currentTabNavigator =
        _navigatorKeys[_currentIndex].currentState!;
    if (currentTabNavigator.canPop()) {
      currentTabNavigator.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildTabNavigator(0, HomeScreen()),
            _buildTabNavigator(1, const UnifiedMarketplaceScreen()),
            _buildTabNavigator(2, const FavoritesScreen()),
            _buildTabNavigator(3, const _BrandsScreen()),
            _buildTabNavigator(4, const _SettingsScreen()),
          ],
        ),
        bottomNavigationBar: _BottomBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) {
              _goHome();
              return;
            }
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildTabNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => child);
      },
    );
  }

  void _goHome() {
    setState(() => _currentIndex = 0);
    final NavigatorState homeNav = _navigatorKeys[0].currentState!;
    while (homeNav.canPop()) {
      homeNav.pop();
    }
  }
}

/// Custom bottom bar styled similar to the provided design.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12.r,
            offset: Offset(0, -2.h),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryRed,
          unselectedItemColor: const Color(0xFF4A4A68),
          onTap: onTap,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize_outlined),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: _BadgeIcon(icon: Icons.favorite_border, count: 2),
              activeIcon: _BadgeIcon(icon: Icons.favorite, count: 2),
              label: 'Favorite',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              label: 'Brands',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24.r),
        if (count > 0)
          Positioned(
            right: -8.w,
            top: -4.h,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings coming soon')),
    );
  }
}

class _BrandsScreen extends StatelessWidget {
  const _BrandsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brands')),
      body: const Center(child: Text('Brands showcase coming soon')),
    );
  }
}
