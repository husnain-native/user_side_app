import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
// feedback_screen removed
import 'package:park_chatapp/features/complaints/presentation/screens/register_complaint_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/core/widgets/sign_in_prompt.dart';
import 'dart:async';
import 'complaint_detail_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final List<_Complaint> _complaints = [];
  final Map<String, bool> _complaintIds = {};
  bool _isLoadingComplaints = true;
  String? _complaintsError;
  StreamSubscription<DatabaseEvent>? _complaintsSubscription;
  Timer? _debounceTimer;

  // UI filter/search state
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';
  final Set<String> _filterStatuses = <String>{};
  final Set<String> _filterCategories = <String>{};
  final Set<String> _filterPriorities = <String>{};
  String _sortBy = 'Newest';
  bool _onlyMine = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  @override
  void dispose() {
    _complaintsSubscription?.cancel();
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadComplaints() {
    // Publicly load complaints for all users so guests can view
    FirebaseDatabase.instance
        .ref('complaints')
        .get()
        .then((snapshot) {
          if (!mounted) return;
          _processComplaintSnapshot(snapshot);
        })
        .catchError((e) {
          if (!mounted) return;
          setState(() {
            _isLoadingComplaints = false;
            _complaintsError = 'Failed to load complaints: $e';
          });
          print('Initial complaints fetch error: $e');
        });
    _complaintsSubscription = FirebaseDatabase.instance
        .ref('complaints')
        .onValue
        .listen(
          (event) {
            if (!mounted) return;
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 100), () {
              _processComplaintSnapshot(event.snapshot);
            });
          },
          onError: (e) {
            if (!mounted) return;
            setState(() {
              _isLoadingComplaints = false;
              _complaintsError = 'Stream error: $e';
            });
            print('Complaints stream error: $e');
          },
        );

    Timer(const Duration(seconds: 10), () {
      if (!mounted || !_isLoadingComplaints) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = 'Loading complaints timed out';
      });
      print('Complaints loading timed out');
    });
  }

  void _processComplaintSnapshot(DataSnapshot snapshot) {
    try {
      print('Processing complaints snapshot');
      final snapshotValue = snapshot.value;
      final List<_Complaint> complaints = [];
      _complaintIds.clear();
      if (snapshotValue != null && snapshotValue is Map) {
        final Map<dynamic, dynamic> usersMap = snapshotValue;
        usersMap.forEach((userId, userComplaints) {
          if (userComplaints is Map) {
            userComplaints.forEach((key, value) {
              final id = key.toString();
              if (_complaintIds.containsKey(id)) {
                print('Skipped duplicate complaint: $id');
                return;
              }
              try {
                final data = Map<String, dynamic>.from(value as Map);
                complaints.add(
                  _Complaint(
                    id: id,
                    userId: userId.toString(),
                    title: data['title']?.toString() ?? '',
                    category: data['category']?.toString() ?? '',
                    description: data['description']?.toString() ?? '',
                    status: _parseStatus(
                      data['status']?.toString() ?? 'Pending',
                    ),
                    timestamp: _parseTimestamp(data['timestamp']?.toString()),
                    priority: data['priority']?.toString() ?? 'Medium',
                  ),
                );
                _complaintIds[id] = true;
              } catch (e) {
                print('Error parsing complaint $id: $e');
              }
            });
          }
        });
      } else {
        print('No complaints data or empty');
      }
      complaints.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        _complaints
          ..clear()
          ..addAll(complaints);
        _isLoadingComplaints = false;
        _complaintsError = null;
        print('Updated complaints list: ${_complaints.length} items');
      });
    } catch (e) {
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = 'Failed to process complaints: $e';
      });
      print('Complaints processing error: $e');
    }
  }

  // Removed feedback loading; feedback feature deprecated

  // Removed feedback processing; feedback feature deprecated

  DateTime _parseTimestamp(String? timestamp) {
    try {
      return timestamp != null ? DateTime.parse(timestamp) : DateTime.now();
    } catch (e) {
      print('Error parsing timestamp: $e');
      return DateTime.now();
    }
  }

  ComplaintStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ComplaintStatus.pending;
      case 'inprogress':
        return ComplaintStatus.inProgress;
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(109.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row - white background, centered title
            Container(
              color: Colors.white,
              child: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.iconColor,
                    size: 20.sp,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'Complaints',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.iconColor,
                  ),
                ),
                toolbarHeight: 36.h,
                iconTheme: const IconThemeData(color: Colors.black),
              ),
            ),
            // Second row - match HomeTwoRowAppBar search row exactly
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 0.h),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40.w,
                        height: 31.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_sharp,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 31.h,
                      decoration: BoxDecoration(
                        color: AppColors.fillColor,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.iconColor,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Search',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged:
                                  (v) => setState(() => _searchText = v.trim()),
                            ),
                          ),
                          Icon(
                            Icons.mic_none_rounded,
                            color: AppColors.iconColor,
                            size: 18.sp,
                            weight: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: Container(
                      width: 40.h,
                      height: 31.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(Icons.tune, color: Color(0xFF2A2A2A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: _buildComplaintsTab(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!await ensureSignedIn(context)) return;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterComplaintScreen()),
          );
        },
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        label: const Text('Register Complaint'),
        icon: const Icon(Icons.report_problem),
      ),
    );
  }

  Widget _buildComplaintsTab(BuildContext context) {
    final filtered = _applyComplaintFilters(_complaints);
    if (_isLoadingComplaints) {
      return Center(
        child: SpinKitWave(color: AppColors.primaryRed, size: 42.w),
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (_complaintsError != null)
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
                    _complaintsError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        _buildComplaintsList(filtered),
      ],
    );
  }

  // Feedback tab removed

  // Former long Register Complaint action card removed in favor of bottom-right FAB

  // Removed old feedback action card in favor of floating action button

  // Feedback list removed

  Widget _buildComplaintsList(List<_Complaint> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Complaints', style: AppTextStyles.bodyMediumBold),
        SizedBox(height: 12.h),
        if (list.isEmpty && !_isLoadingComplaints)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100.h),
                SizedBox(
                  height: 200.h,
                  width: 250.w,
                  child: Image.asset(
                    'assets/images/not_found.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.search_off,
                        size: 64.sp,
                        color: Colors.grey.shade400,
                      );
                    },
                  ),
                ),
                // SizedBox(height: 12.h),
                Text(
                  'No complaints found',
                  style: AppTextStyles.bodyMediumBold,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Try adjusting your filters or register a complaint.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
              ],
            ),
          )
        else
          ...list.map((c) => _ComplaintCard(complaint: c)).toList(),
      ],
    );
  }

  List<_Complaint> _applyComplaintFilters(List<_Complaint> items) {
    Iterable<_Complaint> out = items;
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      out = out.where(
        (c) =>
            c.title.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q),
      );
    }
    if (_onlyMine && currentUid != null) {
      out = out.where((c) => c.userId == currentUid);
    } else if (_onlyMine && currentUid == null) {
      // If user not signed-in and filter is enabled, show none
      out = const <_Complaint>[];
    }
    if (_filterStatuses.isNotEmpty) {
      out = out.where((c) => _filterStatuses.contains(_statusToText(c.status)));
    }
    if (_filterCategories.isNotEmpty) {
      out = out.where((c) => _filterCategories.contains(c.category));
    }
    if (_filterPriorities.isNotEmpty) {
      out = out.where((c) => _filterPriorities.contains(c.priority));
    }
    final list = out.toList();
    if (_sortBy == 'Newest') {
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_sortBy == 'Oldest') {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } else if (_sortBy == 'Priority High→Low') {
      int prio(String p) =>
          {'High': 3, 'Urgent': 4, 'Medium': 2, 'Low': 1}[p] ?? 0;
      list.sort((a, b) => prio(b.priority).compareTo(prio(a.priority)));
    }
    return list;
  }

  String _statusToText(ComplaintStatus s) {
    switch (s) {
      case ComplaintStatus.pending:
        return 'Pending';
      case ComplaintStatus.inProgress:
        return 'Processing';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }

  void _openFilterSheet() async {
    // Minimal filter: Status and Sort only
    final statuses = ['Pending', 'Processing', 'Resolved'];

    final tmpStatuses = Set<String>.from(_filterStatuses);
    String tmpSort = _sortBy;
    bool tmpOnlyMine = _onlyMine;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: BoxDecoration(color: AppColors.white),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  12.h,
                  16.w,
                  16.h + MediaQuery.of(ctx).padding.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Filter Complaints',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _filterStatuses.clear();
                                _sortBy = 'Newest';
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text('Visibility', style: AppTextStyles.bodyMediumBold),
                      Wrap(
                        spacing: 8.w,
                        children: [
                          ChoiceChip(
                            label: const Text('Only my complaints'),
                            selected: tmpOnlyMine,
                            selectedColor: AppColors.primaryRed.withOpacity(
                              0.05,
                            ),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  tmpOnlyMine
                                      ? AppColors.iconColor
                                      : Colors.grey[700],
                            ),
                            onSelected:
                                (_) => setModalState(
                                  () => tmpOnlyMine = !tmpOnlyMine,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text('Status', style: AppTextStyles.bodyMediumBold),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,

                        children:
                            statuses
                                .map(
                                  (s) => FilterChip(
                                    label: Text(s),
                                    selected: tmpStatuses.contains(s),
                                    selectedColor: AppColors.primaryRed
                                        .withOpacity(0.05),
                                    checkmarkColor: AppColors.iconColor,
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color:
                                          tmpStatuses.contains(s)
                                              ? AppColors.iconColor
                                              : Colors.grey[700],
                                    ),
                                    onSelected: (sel) {
                                      setModalState(() {
                                        if (sel) {
                                          tmpStatuses.add(s);
                                        } else {
                                          tmpStatuses.remove(s);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(height: 12.h),
                      Text('Sort by', style: AppTextStyles.bodyMediumBold),
                      Wrap(
                        spacing: 8.w,
                        children:
                            ['Newest', 'Oldest']
                                .map(
                                  (s) => ChoiceChip(
                                    label: Text(s),
                                    selected: tmpSort == s,
                                    selectedColor: AppColors.primaryRed
                                        .withOpacity(0.05),
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color:
                                          tmpSort == s
                                              ? AppColors.iconColor
                                              : Colors.grey[700],
                                    ),
                                    onSelected:
                                        (_) => setModalState(() => tmpSort = s),
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _filterStatuses
                                ..clear()
                                ..addAll(tmpStatuses);
                              _sortBy = tmpSort;
                              _onlyMine = tmpOnlyMine;
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Removed _ActionCard; not used anymore

class _ComplaintCard extends StatelessWidget {
  final _Complaint complaint;

  const _ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ComplaintDetailScreen(
                  complaint: ComplaintLite(
                    id: complaint.id,
                    userId: complaint.userId,
                    title: complaint.title,
                    description: complaint.description,
                    status: complaint.status,
                    timestamp: complaint.timestamp,
                  ),
                ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
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
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  _StatusChip(status: complaint.status),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                complaint.description,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted ${_formatTime(complaint.timestamp)}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                  FutureBuilder<DatabaseEvent>(
                    future:
                        FirebaseDatabase.instance
                            .ref('users/${complaint.userId}')
                            .once(),
                    builder: (context, snapshot) {
                      final userData = snapshot.data?.snapshot.value;
                      String name = 'User';
                      if (userData is Map) {
                        name =
                            userData['name']?.toString() ??
                            userData['displayName']?.toString() ??
                            userData['email']?.toString().split('@')[0] ??
                            'User';
                      }
                      return Text(
                        name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.iconColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Removed: priority chip coloring; category/priority hidden on list

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

class _StatusChip extends StatelessWidget {
  final ComplaintStatus status;

  const _StatusChip({required this.status});

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
        text = 'In Progress';
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Complaint {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String description;
  final ComplaintStatus status;
  final DateTime timestamp;
  final String priority;

  _Complaint({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.priority,
  });
}

enum ComplaintStatus { pending, inProgress, resolved, closed }
