import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/services/auth_service.dart';
import 'package:park_chatapp/core/services/property_service.dart';
import 'package:park_chatapp/features/property/domain/models/property.dart';
import 'package:park_chatapp/features/property/presentation/screens/property_detail_screen.dart';
import 'package:firebase_database/firebase_database.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final AuthService _authService = AuthService();
  final List<Property> _properties = [];
  final List<Property> _allProperties = []; // Store all properties for filtering
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    final user = _authService.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _error = 'Please sign in to view your listings';
      });
      return;
    }
    PropertyService.getPropertiesStream().listen((event) {
      try {
        final Object? raw = event.snapshot.value;
        if (raw == null) {
          setState(() {
            _allProperties.clear();
            _properties.clear();
            _isLoading = false;
          });
          return;
        }
        final Map<dynamic, dynamic> map = raw as Map<dynamic, dynamic>;
        final List<Property> userProperties = [];
        map.forEach((key, value) {
          try {
            final Property p = Property.fromMap(key.toString(), Map<String, dynamic>.from(value as Map));
            if (p.createdBy == user.uid && p.imageUrls.isNotEmpty) {
              userProperties.add(p);
            }
          } catch (e) {
            print('Error parsing property $key: $e');
          }
        });
        userProperties.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          _allProperties
            ..clear()
            ..addAll(userProperties);
          // Apply filter
          _properties
            ..clear()
            ..addAll(_selectedFilter == 'All'
                ? userProperties
                : userProperties.where((p) {
                    switch (_selectedFilter) {
                      case 'Rejected':
                        return p.approvalStatus == PropertyApprovalStatus.rejected;
                      case 'Pending':
                        return p.approvalStatus == PropertyApprovalStatus.pending;
                      case 'Approved':
                        return p.approvalStatus == PropertyApprovalStatus.approved;
                      default:
                        return true;
                    }
                  }).toList());
          _isLoading = false;
          _error = null;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load properties: $e';
        });
      }
    }, onError: (e) {
      setState(() {
        _isLoading = false;
        _error = 'Stream error: $e';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'My Listings',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: Icon(Icons.filter_list, color: Colors.white, size: 20.r),
              underline: const SizedBox(),
              dropdownColor: AppColors.primaryRed,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              items: ['All', 'Rejected', 'Pending', 'Approved'].map((String filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                    // Reapply filter to _properties
                    _properties
                      ..clear()
                      ..addAll(_selectedFilter == 'All'
                          ? _allProperties
                          : _allProperties.where((p) {
                              switch (_selectedFilter) {
                                case 'Rejected':
                                  return p.approvalStatus == PropertyApprovalStatus.rejected;
                                case 'Pending':
                                  return p.approvalStatus == PropertyApprovalStatus.pending;
                                case 'Approved':
                                  return p.approvalStatus == PropertyApprovalStatus.approved;
                                default:
                                  return true;
                              }
                            }).toList());
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoading)
              Container(
                width: double.infinity,
                color: Colors.yellow.shade100,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Loading your listings...',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade100,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _error!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _properties.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64.r, color: Colors.grey),
                          SizedBox(height: 16.h),
                          Text('No listings found', style: AppTextStyles.bodyMediumBold),
                          SizedBox(height: 8.h),
                          Text(
                            'Add a new property to get started',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _properties.length,
                      itemBuilder: (context, index) {
                        final property = _properties[index];
                        // Determine border and status text color based on approval status
                        final statusColor = property.approvalStatus == PropertyApprovalStatus.rejected
                            ? AppColors.red
                            : property.approvalStatus == PropertyApprovalStatus.pending
                                ? Colors.orange
                                : const Color.fromARGB(255, 15, 85, 17);
                        return Card(
                          color: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.r),
                            side: BorderSide(color: statusColor, width: 0.5.w),
                          ),
                          child: ListTile(
                            leading: property.imageUrls.isNotEmpty
                                ? Image.asset(
                                    property.imageUrls[0],
                                    width: 80.w,
                                    height: 80.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 24.r),
                                  )
                                : Icon(Icons.image, size: 24.r),
                            title: Text(property.title, style: AppTextStyles.bodyMediumBold),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${property.approvalStatus.label}',
                                  style: AppTextStyles.bodySmall.copyWith(color: statusColor),
                                ),
                                Text(property.formattedPrice, style: AppTextStyles.bodySmall),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailScreen(property: property),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddEditPropertyScreen').then((result) {
            if (result == true) {
              _loadProperties();
            }
          });
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}