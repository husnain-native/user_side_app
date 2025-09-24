import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<_LostFoundItem> _lostItems = [];
  List<_LostFoundItem> _foundItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Check authentication status
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to access Lost & Found')),
        );
        // Optionally redirect to login screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      });
    } else {
      _fetchItems();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch lost and found items from Firebase RTDB
  void _fetchItems() {
    // Fetch lost items
    _database.child('lost').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<_LostFoundItem> loadedLostItems = [];
      if (data != null) {
        data.forEach((key, value) {
          try {
            // Skip items with missing or invalid data
            if (value['title'] == null || value['uid'] == null) {
              print('Skipping invalid lost item $key: missing required fields');
              return;
            }
            loadedLostItems.add(_LostFoundItem(
              id: key,
              title: value['title'] ?? '',
              description: value['description'] ?? '',
              location: value['location'] ?? '',
              timestamp: DateTime.tryParse(value['timestamp'] ?? '') ?? DateTime.now(),
              isLost: true,
              contactName: value['contactName'],
              contactPhone: value['contactPhone'],
              uid: value['uid'] ?? '',
            ));
          } catch (e) {
            print('Error parsing lost item $key: $e');
          }
        });
        // Sort by timestamp (newest first)
        loadedLostItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      setState(() {
        _lostItems = loadedLostItems;
      });
    }, onError: (error) {
      print('Error fetching lost items: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching lost items: $error')),
      );
    });

    // Fetch found items
    _database.child('found').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<_LostFoundItem> loadedFoundItems = [];
      if (data != null) {
        data.forEach((key, value) {
          try {
            // Skip items with missing or invalid data
            if (value['title'] == null || value['uid'] == null) {
              print('Skipping invalid found item $key: missing required fields');
              return;
            }
            loadedFoundItems.add(_LostFoundItem(
              id: key,
              title: value['title'] ?? '',
              description: value['description'] ?? '',
              location: value['location'] ?? '',
              timestamp: DateTime.tryParse(value['timestamp'] ?? '') ?? DateTime.now(),
              isLost: false,
              contactName: value['contactName'],
              contactPhone: value['contactPhone'],
              uid: value['uid'] ?? '',
            ));
          } catch (e) {
            print('Error parsing found item $key: $e');
          }
        });
        // Sort by timestamp (newest first)
        loadedFoundItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      setState(() {
        _foundItems = loadedFoundItems;
      });
    }, onError: (error) {
      print('Error fetching found items: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching found items: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Lost & Found',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: AppTextStyles.bodyMediumBold.copyWith(fontSize: 16),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
          tabs: const [Tab(text: 'Lost Items'), Tab(text: 'Found Items')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLostTab(context), _buildFoundTab(context)],
      ),
    );
  }

  Widget _buildLostTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ActionCard(
          icon: Icons.search,
          title: 'Report Lost Item',
          subtitle: 'Create a notice for a lost item',
          onTap: () => _showReportDialog(context, isLost: true),
        ),
        const SizedBox(height: 16),
        _buildSection('Recent Lost Reports', _lostItems),
      ],
    );
  }

  Widget _buildFoundTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ActionCard(
          icon: Icons.check_circle,
          title: 'Report Found Item',
          subtitle: 'Let others know you found something',
          onTap: () => _showReportDialog(context, isLost: false),
        ),
        const SizedBox(height: 16),
        _buildSection('Recently Found', _foundItems),
      ],
    );
  }

  Widget _buildSection(String heading, List<_LostFoundItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: AppTextStyles.bodyMediumBold),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No entries yet.'),
            ),
          )
        else
          ...items.map((i) => _LostFoundCard(item: i)).toList(),
      ],
    );
  }

  Future<void> _showReportDialog(
    BuildContext context, {
    required bool isLost,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final contactNameController = TextEditingController();
    final contactPhoneController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isLost ? 'Report Lost Item' : 'Report Found Item'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  TextFormField(
                    controller: contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Name',
                    ),
                  ),
                  TextFormField(
                    controller: contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please sign in to submit an item')),
                  );
                  Navigator.pop(ctx);
                  return;
                }
                final newItem = _LostFoundItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  location: locationController.text.trim(),
                  timestamp: DateTime.now(),
                  isLost: isLost,
                  contactName: contactNameController.text.trim(),
                  contactPhone: contactPhoneController.text.trim(),
                  uid: user.uid,
                );

                // Save to Firebase RTDB
                try {
                  final ref = _database.child(isLost ? 'lost' : 'found').child(newItem.id);
                  await ref.set({
                    'title': newItem.title,
                    'description': newItem.description,
                    'location': newItem.location,
                    'timestamp': newItem.timestamp.toIso8601String(),
                    'isLost': newItem.isLost,
                    'contactName': newItem.contactName,
                    'contactPhone': newItem.contactPhone,
                    'uid': newItem.uid,
                  });
                  Navigator.pop(ctx);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving item: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryRed.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMediumBold),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LostFoundItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime timestamp;
  final bool isLost;
  final String? contactName;
  final String? contactPhone;
  final String? uid;

  _LostFoundItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.isLost,
    this.contactName,
    this.contactPhone,
    this.uid,
  });
}

class _LostFoundCard extends StatelessWidget {
  final _LostFoundItem item;

  const _LostFoundCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color chipColor = item.isLost ? Colors.orange : Colors.green;
    final String chipText = item.isLost ? 'Lost' : 'Found';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.title, style: AppTextStyles.bodyMediumBold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chipText,
                    style: TextStyle(
                      color: chipColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.description.isNotEmpty)
              Text(item.description, style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.location,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatTime(item.timestamp),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            if ((item.contactName?.isNotEmpty ?? false) ||
                (item.contactPhone?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      [
                        item.contactName,
                        item.contactPhone,
                      ].where((e) => (e ?? '').isNotEmpty).join(' • '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
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