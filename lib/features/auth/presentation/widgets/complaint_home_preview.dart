import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:park_chatapp/features/complaints/presentation/screens/complaints_screen.dart'
    show ComplaintStatus, ComplaintsScreen;
import 'package:park_chatapp/features/complaints/presentation/screens/complaint_detail_screen.dart';

/// Small home widget that shows a header row and a single recent complaint card.
/// Placed on Home beneath the payments banner.
class ComplaintHomePreview extends StatefulWidget {
  const ComplaintHomePreview({super.key});

  @override
  State<ComplaintHomePreview> createState() => _ComplaintHomePreviewState();
}

class _ComplaintHomePreviewState extends State<ComplaintHomePreview> {
  ComplaintLite? _latest;
  bool _loading = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadLatestComplaint();
  }

  Future<void> _loadLatestComplaint() async {
    try {
      final db = FirebaseDatabase.instance;
      final snapshot = await db.ref('complaints').get();
      final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

      final List<ComplaintLite> all = [];
      final value = snapshot.value;
      if (value is Map) {
        value.forEach((userId, userComplaints) {
          if (userComplaints is Map) {
            userComplaints.forEach((id, data) {
              try {
                final map = Map<String, dynamic>.from(data as Map);
                final tsString = map['timestamp']?.toString();
                final DateTime ts =
                    tsString != null
                        ? DateTime.tryParse(tsString) ?? DateTime.now()
                        : DateTime.now();
                final statusText = map['status']?.toString() ?? 'Pending';
                all.add(
                  ComplaintLite(
                    id: id.toString(),
                    userId: userId.toString(),
                    title: map['title']?.toString() ?? '',
                    description: map['description']?.toString() ?? '',
                    status: _parseStatus(statusText),
                    timestamp: ts,
                  ),
                );
              } catch (_) {}
            });
          }
        });
      }

      // Prefer the most recent complaint of the current user if available.
      all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      ComplaintLite? selected;
      if (currentUid != null) {
        try {
          selected = all.firstWhere((c) => c.userId == currentUid);
        } catch (_) {}
      }
      selected ??= all.isNotEmpty ? all.first : null;

      if (!mounted) return;
      setState(() {
        _latest = selected;
        _loading = false;
      });
      if (selected != null) {
        _loadUserName(selected.userId);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadUserName(String userId) async {
    try {
      final event = await FirebaseDatabase.instance.ref('users/$userId').once();
      final userData = event.snapshot.value;
      String name = 'User';
      if (userData is Map) {
        name =
            userData['name']?.toString() ??
            userData['displayName']?.toString() ??
            (userData['email']?.toString().split('@')[0]) ??
            'User';
      }
      if (!mounted) return;
      setState(() => _userName = name);
    } catch (_) {}
  }

  ComplaintStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ComplaintStatus.pending;
      case 'inprogress':
      case 'processing':
        return ComplaintStatus.inProgress;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'closed':
        return ComplaintStatus.closed;
      default:
        return ComplaintStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Text(
                  'Complaint',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Icon(Icons.arrow_forward, size: 18.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return Container(
        height: 110.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
        ),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_latest == null) {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
        ),
        child: Text('No complaints yet', style: AppTextStyles.bodySmall),
      );
    }

    final c = _latest!;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.r),
        side: BorderSide(color: AppColors.primaryRed.withOpacity(0.3)),
      ),
      elevation: 1,
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  c.status == ComplaintStatus.resolved
                      ? Icons.check_circle
                      : c.status == ComplaintStatus.inProgress
                      ? Icons.autorenew
                      : Icons.error_outline,
                  color:
                      c.status == ComplaintStatus.resolved
                          ? Colors.green
                          : c.status == ComplaintStatus.inProgress
                          ? Colors.blue
                          : Colors.orange,
                  size: 18.r,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    c.title.isEmpty ? 'Complaint' : c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMediumBold,
                  ),
                ),
                _StatusChipMini(status: c.status),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              c.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName ?? 'User',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Submitted ${_formatTime(c.timestamp)}',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ComplaintsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: AppColors.primaryRed, width: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      child: Text(
                        'Open Complaints',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryRed,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChipMini extends StatelessWidget {
  const _StatusChipMini({required this.status});
  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case ComplaintStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case ComplaintStatus.inProgress:
        color = Colors.blue;
        text = 'Processing';
        break;
      case ComplaintStatus.resolved:
        color = Colors.green;
        text = 'Resolved';
        break;
      case ComplaintStatus.closed:
        color = Colors.grey;
        text = 'Closed';
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final now = DateTime.now();
  final difference = now.difference(dt);
  if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  } else {
    return 'Just now';
  }
}
