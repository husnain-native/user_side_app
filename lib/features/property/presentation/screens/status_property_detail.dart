import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/services/auth_service.dart';
import 'package:park_chatapp/features/property/domain/models/property.dart';
import 'package:firebase_database/firebase_database.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final AuthService _authService = AuthService();
  String? _rejectionMessage;
  bool _isLoadingMessage = false;
  String? _messageError;

  @override
  void initState() {
    super.initState();
    _loadRejectionMessage();
  }

  void _loadRejectionMessage() {
    if (widget.property.approvalStatus != PropertyApprovalStatus.rejected) {
      return; // Only load message for rejected properties
    }
    final user = _authService.currentUser;
    if (user == null || user.uid != widget.property.createdBy) {
      setState(() {
        _messageError = 'Unauthorized to view rejection message';
      });
      return;
    }
    final messageRef = FirebaseDatabase.instance.ref('messages/${user.uid}/${widget.property.id}');
    setState(() {
      _isLoadingMessage = true;
    });
    messageRef.onValue.listen((event) {
      if (!mounted) return;
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            _rejectionMessage = data['message']?.toString();
            _isLoadingMessage = false;
            _messageError = null;
          });
        } else {
          setState(() {
            _isLoadingMessage = false;
            _messageError = 'No rejection message found';
          });
        }
      } catch (e) {
        setState(() {
          _isLoadingMessage = false;
          _messageError = 'Failed to load rejection message: $e';
        });
      }
    }, onError: (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMessage = false;
        _messageError = 'Error loading message: $e';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          property.title,
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rejection Message (if rejected)
              if (property.approvalStatus == PropertyApprovalStatus.rejected) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rejection Reason',
                        style: AppTextStyles.bodyMediumBold.copyWith(color: Colors.red),
                      ),
                      SizedBox(height: 8.h),
                      if (_isLoadingMessage)
                        Row(
                          children: [
                            SizedBox(
                              width: 14.w,
                              height: 14.h,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8.w),
                            Text('Loading rejection message...', style: AppTextStyles.bodySmall),
                          ],
                        )
                      else if (_messageError != null)
                        Text(
                          _messageError!,
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                        )
                      else if (_rejectionMessage != null)
                        Text(
                          _rejectionMessage!,
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.black87),
                        )
                      else
                        Text(
                          'No rejection message available',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              // Property Images
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey.shade200,
                ),
                child: property.imageUrls.isNotEmpty
                    ? PageView.builder(
                        itemCount: property.imageUrls.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              property.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.broken_image,
                                size: 48.r,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(child: Icon(Icons.image, size: 48.r, color: Colors.grey)),
              ),
              SizedBox(height: 16.h),
              // Property Details
              Text(
                property.title,
                style: AppTextStyles.bodyLarge,
              ),
              SizedBox(height: 8.h),
              Text(
                property.formattedPrice,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryRed),
              ),
              SizedBox(height: 8.h),
              Text(
                'Status: ${property.approvalStatus.label}',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 8.h),
              Text(
                'Type: ${property.type.label}',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 8.h),
              Text(
                'Location: ${property.location}',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.king_bed, size: 20.r, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    '${property.bedrooms} Bedrooms',
                    style: AppTextStyles.bodyMedium,
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.bathtub, size: 20.r, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    '${property.bathrooms} Bathrooms',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Area: ${property.area} sq ft',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 16.h),
              // Description
              Text(
                'Description',
                style: AppTextStyles.bodyMediumBold,
              ),
              SizedBox(height: 8.h),
              Text(
                property.description,
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 16.h),
              // Amenities
              if (property.amenities.isNotEmpty) ...[
                Text(
                  'Amenities',
                  style: AppTextStyles.bodyMediumBold,
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: property.amenities.entries.map((entry) {
                    return Chip(
                      label: Text(
                        '${entry.key}: ${entry.value}',
                        style: AppTextStyles.bodySmall,
                      ),
                      backgroundColor: Colors.grey.shade100,
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
              ],
              // Agent Info
              Text(
                'Agent',
                style: AppTextStyles.bodyMediumBold,
              ),
              SizedBox(height: 8.h),
              Text(
                'Name: ${property.agentName}',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 16.h),
              // Created At
              Text(
                'Posted: ${property.timeAgo}',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}