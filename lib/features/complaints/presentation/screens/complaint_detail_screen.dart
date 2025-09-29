import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'complaints_screen.dart' show ComplaintStatus;

class ComplaintLite {
  final String id;
  final String userId;
  final String title;
  final String description;
  final ComplaintStatus status;
  final DateTime timestamp;

  ComplaintLite({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.timestamp,
  });
}

class ComplaintDetailScreen extends StatefulWidget {
  final ComplaintLite complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final TextEditingController _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Complaint Details',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.iconColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildComplaintCard()],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard() {
    return Container(
      color: AppColors.white,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(8.r),
      //   // side: BorderSide(color: AppColors.primaryRed.withOpacity(0.2)),
      // ),
      // elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.complaint.title,
                    style: AppTextStyles.bodyMediumBold,
                  ),
                ),
                _LocalStatusChip(status: widget.complaint.status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(widget.complaint.description, style: AppTextStyles.bodySmall),
            SizedBox(height: 8.h),
            Text(
              'Submitted ${_formatTime(widget.complaint.timestamp)}',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
            SizedBox(height: 12.h),
            // User feedback text (if exists)
            StreamBuilder<DatabaseEvent>(
              stream:
                  FirebaseDatabase.instance
                      .ref(
                        'complaints/${widget.complaint.userId}/${widget.complaint.id}/feedback',
                      )
                      .onValue,
              builder: (context, snapshot) {
                final data = snapshot.data?.snapshot.value;
                if (data is Map) {
                  final comments = data['comments']?.toString() ?? '';
                  if (comments.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            const Icon(
                              Icons.reply,
                              size: 18,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Feedback',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comments,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                      ],
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            // Admin response (if any) now below feedback
            StreamBuilder<DatabaseEvent>(
              stream:
                  FirebaseDatabase.instance
                      .ref(
                        'complaints/${widget.complaint.userId}/${widget.complaint.id}/reply',
                      )
                      .onValue,
              builder: (context, snapshot) {
                final reply = snapshot.data?.snapshot.value?.toString();
                if (reply == null || reply.isEmpty)
                  return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.reply,
                          size: 18,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Admin Response',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reply,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black87,
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),
            // Owner-only feedback action: open modal
            Builder(
              builder: (context) {
                final currentUser = FirebaseAuth.instance.currentUser;
                final isOwner =
                    currentUser != null &&
                    currentUser.uid == widget.complaint.userId;
                if (!isOwner) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _openFeedbackModal,
                    icon: const Icon(Icons.reply, color: AppColors.primaryRed),
                    label: const Text('Add Feedback'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != widget.complaint.userId) return;
    setState(() => _submitting = true);
    try {
      await FirebaseDatabase.instance
          .ref(
            'complaints/${widget.complaint.userId}/${widget.complaint.id}/feedback',
          )
          .set({
            'comments': _commentCtrl.text.trim(),
            'userId': user.uid,
            'timestamp': DateTime.now().toIso8601String(),
          });
      if (!mounted) return;
      _commentCtrl.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feedback submitted')));
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openFeedbackModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
            top: 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.reply, color: AppColors.primaryRed),
                  const SizedBox(width: 8),
                  Text('Add Feedback', style: AppTextStyles.bodyMediumBold),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _commentCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Write your feedback... ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: _submitting ? null : _submitFeedback,
                  icon:
                      _submitting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.send),
                  label: Text(
                    _submitting ? 'Submitting...' : 'Submit Feedback',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
}

class _LocalStatusChip extends StatelessWidget {
  final ComplaintStatus status;
  const _LocalStatusChip({required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
