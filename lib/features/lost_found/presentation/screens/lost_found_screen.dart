import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/core/widgets/sign_in_prompt.dart';
import 'dart:async';
import 'lost_found_detail_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:park_chatapp/features/lost_found/presentation/screens/register_lost_found_screen.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  final List<_LostFoundItem> _items = [];
  final Map<String, bool> _itemIds = {};
  bool _isLoadingItems = true;
  String? _itemsError;
  StreamSubscription<DatabaseEvent>? _itemsSubscription;
  Timer? _debounceTimer;

  // UI filter/search state
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';
  final Set<String> _filterTypes = <String>{};
  final Set<String> _filterCategories = <String>{};
  String _sortBy = 'Newest';
  bool _onlyMine = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadItems() {
    // Publicly load items for all users so guests can view
    FirebaseDatabase.instance
        .ref('lost_found')
        .get()
        .then((snapshot) {
          if (!mounted) return;
          _processItemSnapshot(snapshot);
        })
        .catchError((e) {
          if (!mounted) return;
          setState(() {
            _isLoadingItems = false;
            _itemsError = 'Failed to load items: $e';
          });
          print('Initial items fetch error: $e');
        });
    _itemsSubscription = FirebaseDatabase.instance
        .ref('lost_found')
        .onValue
        .listen(
          (event) {
            if (!mounted) return;
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 100), () {
              _processItemSnapshot(event.snapshot);
            });
          },
          onError: (e) {
            if (!mounted) return;
            setState(() {
              _isLoadingItems = false;
              _itemsError = 'Stream error: $e';
            });
            print('Items stream error: $e');
          },
        );

    Timer(const Duration(seconds: 10), () {
      if (!mounted || !_isLoadingItems) return;
      setState(() {
        _isLoadingItems = false;
        _itemsError = 'Loading items timed out';
      });
      print('Items loading timed out');
    });
  }

  void _processItemSnapshot(DataSnapshot snapshot) {
    try {
      print('Processing items snapshot');
      final snapshotValue = snapshot.value;
      final List<_LostFoundItem> items = [];
      _itemIds.clear();
      if (snapshotValue != null && snapshotValue is Map) {
        final Map<dynamic, dynamic> usersMap = snapshotValue;
        usersMap.forEach((userId, userItems) {
          if (userItems is Map) {
            userItems.forEach((key, value) {
              final id = key.toString();
              if (_itemIds.containsKey(id)) {
                print('Skipped duplicate item: $id');
                return;
              }
              try {
                final data = Map<String, dynamic>.from(value as Map);
                items.add(
                  _LostFoundItem(
                    id: id,
                    userId: userId.toString(),
                    title: data['title']?.toString() ?? '',
                    description: data['description']?.toString() ?? '',
                    location: data['location']?.toString() ?? '',
                    type: _parseType(data['type']?.toString() ?? 'Lost'),
                    category: data['category']?.toString() ?? 'Other',
                    timestamp: _parseTimestamp(data['timestamp']?.toString()),
                    contactName: data['contactName']?.toString(),
                    contactPhone: data['contactPhone']?.toString(),
                  ),
                );
                _itemIds[id] = true;
              } catch (e) {
                print('Error parsing item $id: $e');
              }
            });
          }
        });
      } else {
        print('No items data or empty');
      }
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        _items
          ..clear()
          ..addAll(items);
        _isLoadingItems = false;
        _itemsError = null;
        print('Updated items list: ${_items.length} items');
      });
    } catch (e) {
      setState(() {
        _isLoadingItems = false;
        _itemsError = 'Failed to process items: $e';
      });
      print('Items processing error: $e');
    }
  }

  DateTime _parseTimestamp(String? timestamp) {
    try {
      return timestamp != null ? DateTime.parse(timestamp) : DateTime.now();
    } catch (e) {
      print('Error parsing timestamp: $e');
      return DateTime.now();
    }
  }

  LostFoundType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'lost':
        return LostFoundType.lost;
      case 'found':
        return LostFoundType.found;
      default:
        return LostFoundType.lost;
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
                  'Lost & Found',
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
      body: SafeArea(child: _buildItemsTab(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!await ensureSignedIn(context)) return;
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterLostFoundScreen()),
          );
        },
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        label: const Text('Report Item'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemsTab(BuildContext context) {
    final filtered = _applyItemFilters(_items);
    if (_isLoadingItems) {
      return Center(
        child: SpinKitWave(color: AppColors.primaryRed, size: 42.w),
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (_itemsError != null)
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
                    _itemsError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        _buildItemsList(filtered),
      ],
    );
  }

  Widget _buildItemsList(List<_LostFoundItem> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Items', style: AppTextStyles.bodyMediumBold),
        SizedBox(height: 12.h),
        if (list.isEmpty && !_isLoadingItems)
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
                Text('No items found', style: AppTextStyles.bodyMediumBold),
                SizedBox(height: 4.h),
                Text(
                  'Try adjusting your filters or report an item.',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
              ],
            ),
          )
        else
          ...list.map((item) => _LostFoundCard(item: item)).toList(),
      ],
    );
  }

  List<_LostFoundItem> _applyItemFilters(List<_LostFoundItem> items) {
    Iterable<_LostFoundItem> out = items;
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      out = out.where(
        (item) =>
            item.title.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q) ||
            item.location.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q),
      );
    }
    if (_onlyMine && currentUid != null) {
      out = out.where((item) => item.userId == currentUid);
    } else if (_onlyMine && currentUid == null) {
      // If user not signed-in and filter is enabled, show none
      out = const <_LostFoundItem>[];
    }
    if (_filterTypes.isNotEmpty) {
      out = out.where((item) => _filterTypes.contains(_typeToText(item.type)));
    }
    if (_filterCategories.isNotEmpty) {
      out = out.where((item) => _filterCategories.contains(item.category));
    }
    final list = out.toList();
    if (_sortBy == 'Newest') {
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } else if (_sortBy == 'Oldest') {
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
    return list;
  }

  String _typeToText(LostFoundType type) {
    switch (type) {
      case LostFoundType.lost:
        return 'Lost';
      case LostFoundType.found:
        return 'Found';
    }
  }

  void _openFilterSheet() async {
    final types = ['Lost', 'Found'];
    final categories = [
      'Electronics',
      'Clothing',
      'Documents',
      'Jewelry',
      'Other',
    ];

    final tmpTypes = Set<String>.from(_filterTypes);
    final tmpCategories = Set<String>.from(_filterCategories);
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
                            'Filter Items',
                            style: AppTextStyles.headlineMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _filterTypes.clear();
                                _filterCategories.clear();
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
                            label: const Text('Only my items'),
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
                      Text('Type', style: AppTextStyles.bodyMediumBold),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children:
                            types
                                .map(
                                  (type) => FilterChip(
                                    label: Text(type),
                                    selected: tmpTypes.contains(type),
                                    selectedColor: AppColors.primaryRed
                                        .withOpacity(0.05),
                                    checkmarkColor: AppColors.iconColor,
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color:
                                          tmpTypes.contains(type)
                                              ? AppColors.iconColor
                                              : Colors.grey[700],
                                    ),
                                    onSelected: (sel) {
                                      setModalState(() {
                                        if (sel) {
                                          tmpTypes.add(type);
                                        } else {
                                          tmpTypes.remove(type);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                      SizedBox(height: 12.h),
                      Text('Category', style: AppTextStyles.bodyMediumBold),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 6.h,
                        children:
                            categories
                                .map(
                                  (category) => FilterChip(
                                    label: Text(category),
                                    selected: tmpCategories.contains(category),
                                    selectedColor: AppColors.primaryRed
                                        .withOpacity(0.05),
                                    checkmarkColor: AppColors.iconColor,
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color:
                                          tmpCategories.contains(category)
                                              ? AppColors.iconColor
                                              : Colors.grey[700],
                                    ),
                                    onSelected: (sel) {
                                      setModalState(() {
                                        if (sel) {
                                          tmpCategories.add(category);
                                        } else {
                                          tmpCategories.remove(category);
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
                              _filterTypes
                                ..clear()
                                ..addAll(tmpTypes);
                              _filterCategories
                                ..clear()
                                ..addAll(tmpCategories);
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

class _LostFoundCard extends StatelessWidget {
  final _LostFoundItem item;

  const _LostFoundCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => LostFoundDetailScreen(
                  item: LostFoundLite(
                    id: item.id,
                    userId: item.userId,
                    title: item.title,
                    description: item.description,
                    location: item.location,
                    type: item.type,
                    category: item.category,
                    timestamp: item.timestamp,
                    contactName: item.contactName,
                    contactPhone: item.contactPhone,
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
                      item.title,
                      style: AppTextStyles.bodyMediumBold.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  _TypeChip(type: item.type),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                item.description,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reported ${_formatTime(item.timestamp)}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                  FutureBuilder<DatabaseEvent>(
                    future:
                        FirebaseDatabase.instance
                            .ref('users/${item.userId}')
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

class _TypeChip extends StatelessWidget {
  final LostFoundType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (type) {
      case LostFoundType.lost:
        color = Colors.orange;
        text = 'Lost';
        break;
      case LostFoundType.found:
        color = Colors.green;
        text = 'Found';
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

class _LostFoundItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String location;
  final LostFoundType type;
  final String category;
  final DateTime timestamp;
  final String? contactName;
  final String? contactPhone;

  _LostFoundItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.category,
    required this.timestamp,
    this.contactName,
    this.contactPhone,
  });
}

enum LostFoundType { lost, found }
