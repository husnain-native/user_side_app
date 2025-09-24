// Updated file: `lib/features/home/presentation/widgets/quick_action_grid.dart`
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:park_chatapp/features/auth/presentation/screens/payments_screen.dart';
import 'package:park_chatapp/features/security/presentation/screens/security_screen.dart';
import 'package:park_chatapp/features/complaints/presentation/screens/complaints_screen.dart';
import 'package:park_chatapp/features/lost_found/presentation/screens/lost_found_screen.dart';
import 'package:park_chatapp/features/marketplace/presentation/screens/marketplace_screen.dart';
// import 'package:park_chatapp/features/payments/presentation/screens/payments_screen.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.1,
      mainAxisSpacing: 4.h,
      crossAxisSpacing: 6.w,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      children: [
        _buildGridItem(
          icon: Icons.chat,
          title: 'Chat',
          color: const Color.fromARGB(255, 95, 212, 0),
          onTap: () => _navigateToChat(context),
        ),
        _buildGridItem(
          icon: Icons.payment,
          title: 'Payments',
          color: const Color(0xFF4285F4),
          onTap: () => _navigateToPayments(context), // Added navigation
        ),
        _buildGridItem(
          icon: Icons.security,
          title: 'Security',
          color: const Color(0xFFEA4335),
          onTap: () => _navigateToSecurity(context),
        ),
        _buildGridItem(
          icon: Icons.feedback,
          title: 'Complaints',
          color: const Color(0xFFFBBC05),
          onTap: () => _navigateToComplaints(context),
        ),
        _buildGridItem(
          icon: Icons.find_in_page,
          title: 'Lost & Found',
          color: const Color(0xFFFF9800),
          onTap: () => _navigateToLostFound(context),
        ),
        _buildGridItem(
          icon: Icons.shopping_cart,
          title: 'Marketplace',
          color: const Color(0xFFE91E63),
          onTap: () => _navigateToMarketplace(context),
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToPayments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentsScreen()),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatListScreen()),
    );
  }

  void _navigateToSecurity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecurityScreen()),
    );
  }

  void _navigateToComplaints(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ComplaintsScreen()),
    );
  }

  void _navigateToBookings(BuildContext context) {
    // Implement bookings navigation
  }

  void _navigateToCommunity(BuildContext context) {
    // Implement community navigation
  }

  void _navigateToLostFound(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LostFoundScreen()),
    );
  }

  void _navigateToMarketplace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MarketplaceScreen()),
    );
  }

  void _navigateToServices(BuildContext context) {
    // Implement services navigation
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap, // Added onTap parameter
  }) {
    return InkWell(
      onTap: onTap, // Added onTap
      borderRadius: BorderRadius.circular(8.r),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20.w, color: color),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
