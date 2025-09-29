import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/quick_action_grid.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/category_grid.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/app_drawer.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/home_two_row_app_bar.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/society_details_section.dart';
import 'package:park_chatapp/features/property/domain/models/property.dart';
import 'package:park_chatapp/features/property/presentation/screens/property_explore_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/admin_chat_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:park_chatapp/features/auth/presentation/widgets/payments_banner.dart';
import 'package:park_chatapp/features/auth/presentation/widgets/marketplace_horizontal_list.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      drawer: const AppDrawer(),
      appBar: HomeTwoRowAppBar(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onProfileTap: () {},
        onNotificationsTap: () {},
        onCartTap: () {},
        onFilterTap: () {},
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            const PaymentsBanner(),
            // SizedBox(height: 16.h),
            // Image.asset(
            //   'assets/images/parkview.png',
            //   width: 500.w,
            //   height: 60.h,
            // ),
            // Welcome Banner
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: _sectionHeader('Quick Actions', Icons.flash_on_outlined),
            ),
            SizedBox(height: 12.h),
            const QuickActionGrid(),
            SizedBox(height: 12.h),
            // Categories Grid
            const MarketplaceHorizontalList(),
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: _sectionHeader('Explore Categories', Icons.grid_view),
            ),
            SizedBox(height: 12.h),
            CategoryGrid(
              items: [
                CategoryItem(
                  title: 'Commercial',
                  imageAssetPath: 'assets/images/slider1.jpg',
                  onTap:
                      () => _navigateToPropertyExplore(
                        context,
                        PropertyType.commercial,
                      ),
                ),
                CategoryItem(
                  title: 'Residential',
                  imageAssetPath: 'assets/images/slider2.jpg',
                  onTap:
                      () => _navigateToPropertyExplore(
                        context,
                        PropertyType.residential,
                      ),
                ),
                CategoryItem(
                  title: 'Buy Property',
                  imageAssetPath: 'assets/images/slider3.jpeg',
                  onTap:
                      () =>
                          _navigateToPropertyExplore(context, PropertyType.buy),
                ),
                CategoryItem(
                  title: 'Rent Property',
                  imageAssetPath: 'assets/images/new2.jpeg',
                  onTap:
                      () => _navigateToPropertyExplore(
                        context,
                        PropertyType.rent,
                      ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Align(
            //   alignment: Alignment.centerLeft,
            //   child: _sectionHeader('Quick Actions', Icons.flash_on_outlined),
            // ),
            // SizedBox(height: 12.h),
            // const QuickActionGrid(),
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: _sectionHeader(
                'Society Details',
                Icons.apartment_outlined,
              ),
            ),
            SizedBox(height: 12.h),
            SocietyDetailsSection.sample(),

            SizedBox(height: 24.h),
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: _sectionHeader('Location', Icons.location_on_outlined),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 220.h,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: ll.LatLng(33.7178631, 73.2152564),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.parkchatapp2',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: const ll.LatLng(33.7178631, 73.2152564),
                        width: 40.w,
                        height: 40.h,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 36.r,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdminChat(context),
        backgroundColor: AppColors.primaryRed,
        child: Icon(Icons.chat, color: Colors.white, size: 28.r),
      ),
    );
  }

  void _navigateToPropertyExplore(BuildContext context, PropertyType category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertyExploreScreen(initialCategory: category),
      ),
    );
  }

  void _navigateToAdminChat(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AdminChatScreen()));
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Icon(icon, size: 18.r, color: AppColors.primaryRed),
        SizedBox(width: 6.w),
        Text(
          title,
          style: AppTextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
