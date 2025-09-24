import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/complaints/presentation/screens/feedback_screen.dart';
import 'package:park_chatapp/features/complaints/presentation/screens/register_complaint_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<_Complaint> _complaints = [];
  final List<_Feedback> _feedbacks = [];
  final Map<String, bool> _complaintIds = {};
  final Map<String, bool> _feedbackIds = {};
  bool _isLoadingComplaints = true;
  bool _isLoadingFeedback = true;
  String? _complaintsError;
  String? _feedbackError;
  StreamSubscription<DatabaseEvent>? _complaintsSubscription;
  StreamSubscription<DatabaseEvent>? _feedbackSubscription;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadComplaints();
    _loadFeedback();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _complaintsSubscription?.cancel();
    _feedbackSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadComplaints() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = 'Please sign in to view complaints';
      });
      print('No user signed in for complaints');
      return;
    }

    FirebaseDatabase.instance
        .ref('complaints/${user.uid}')
        .get()
        .then((snapshot) {
      if (!mounted) return;
      _processComplaintSnapshot(snapshot);
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = 'Failed to load complaints: $e';
      });
      print('Initial complaints fetch error: $e');
    });

    _complaintsSubscription = FirebaseDatabase.instance
        .ref('complaints/${user.uid}')
        .onValue
        .listen((event) {
      if (!mounted) return;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        _processComplaintSnapshot(event.snapshot);
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingComplaints = false;
        _complaintsError = 'Stream error: $e';
      });
      print('Complaints stream error: $e');
    });

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
        final Map<dynamic, dynamic> map = snapshotValue;
        map.forEach((key, value) {
          final id = key.toString();
          if (_complaintIds.containsKey(id)) {
            print('Skipped duplicate complaint: $id');
            return;
          }
          try {
            final data = Map<String, dynamic>.from(value as Map);
            complaints.add(_Complaint(
              id: id,
              title: data['title']?.toString() ?? '',
              category: data['category']?.toString() ?? '',
              description: data['description']?.toString() ?? '',
              status: _parseStatus(data['status']?.toString() ?? 'Pending'),
              timestamp: _parseTimestamp(data['timestamp']?.toString()),
              priority: data['priority']?.toString() ?? 'Medium',
            ));
            _complaintIds[id] = true;
            print('Added complaint: $id');
          } catch (e) {
            print('Error parsing complaint $id: $e');
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

  void _loadFeedback() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoadingFeedback = false;
        _feedbackError = 'Please sign in to view feedback';
      });
      print('No user signed in for feedback');
      return;
    }

    FirebaseDatabase.instance
        .ref('feedback/${user.uid}')
        .get()
        .then((snapshot) {
      if (!mounted) return;
      _processFeedbackSnapshot(snapshot);
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFeedback = false;
        _feedbackError = 'Failed to load feedback: $e';
      });
      print('Initial feedback fetch error: $e');
    });

    _feedbackSubscription = FirebaseDatabase.instance
        .ref('feedback/${user.uid}')
        .onValue
        .listen((event) {
      if (!mounted) return;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        _processFeedbackSnapshot(event.snapshot);
      });
    }, onError: (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFeedback = false;
        _feedbackError = 'Stream error: $e';
      });
      print('Feedback stream error: $e');
    });

    Timer(const Duration(seconds: 10), () {
      if (!mounted || !_isLoadingFeedback) return;
      setState(() {
        _isLoadingFeedback = false;
        _feedbackError = 'Loading feedback timed out';
      });
      print('Feedback loading timed out');
    });
  }

  void _processFeedbackSnapshot(DataSnapshot snapshot) {
    try {
      print('Processing feedback snapshot');
      final snapshotValue = snapshot.value;
      final List<_Feedback> feedbacks = [];
      _feedbackIds.clear();
      if (snapshotValue != null && snapshotValue is Map) {
        final Map<dynamic, dynamic> map = snapshotValue;
        map.forEach((key, value) {
          final id = key.toString();
          if (_feedbackIds.containsKey(id)) {
            print('Skipped duplicate feedback: $id');
            return;
          }
          try {
            final data = Map<String, dynamic>.from(value as Map);
            feedbacks.add(_Feedback(
              id: id,
              overallRating: (data['overallRating'] as num?)?.toDouble() ?? 3.0,
              maintenanceRating: (data['maintenanceRating'] as num?)?.toDouble() ?? 3.0,
              securityRating: (data['securityRating'] as num?)?.toDouble() ?? 3.0,
              cleanlinessRating: (data['cleanlinessRating'] as num?)?.toDouble() ?? 3.0,
              comments: data['comments']?.toString() ?? '',
              reply: data['reply']?.toString(),
              replyTimestamp: _parseTimestamp(data['replyTimestamp']?.toString()),
              timestamp: _parseTimestamp(data['timestamp']?.toString()),
            ));
            _feedbackIds[id] = true;
            print('Added feedback: $id');
          } catch (e) {
            print('Error parsing feedback $id: $e');
          }
        });
      } else {
        print('No feedback data or empty');
      }
      feedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {
        _feedbacks
          ..clear()
          ..addAll(feedbacks);
        _isLoadingFeedback = false;
        _feedbackError = null;
        print('Updated feedback list: ${_feedbacks.length} items');
      });
    } catch (e) {
      setState(() {
        _isLoadingFeedback = false;
        _feedbackError = 'Failed to process feedback: $e';
      });
      print('Feedback processing error: $e');
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

  ComplaintStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ComplaintStatus.pending;
      case 'inprogress':
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Complaints & Feedback',
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
          tabs: const [Tab(text: 'Complaints'), Tab(text: 'Feedback')],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildComplaintsTab(context), _buildFeedbackTab(context)],
        ),
      ),
    );
  }

  Widget _buildComplaintsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQuickActions(context),
        const SizedBox(height: 16),
        if (_isLoadingComplaints)
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 221, 211, 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 4),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Loading complaints...',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        if (_complaintsError != null)
          Container(
            width: double.infinity,
            color: Colors.red.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: Colors.red),
                const SizedBox(width: 8),
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
        _buildComplaintsList(),
      ],
    );
  }

  Widget _buildFeedbackTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFeedbackActions(context),
        const SizedBox(height: 16),
        if (_isLoadingFeedback)
          Container(
            width: double.infinity,
            color: Colors.yellow.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 4),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Loading feedback...',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        if (_feedbackError != null)
          Container(
            width: double.infinity,
            color: Colors.red.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _feedbackError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        _buildFeedbackList(),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.report_problem,
            title: 'Register Complaint',
            subtitle: 'Report maintenance, cleanliness issues',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterComplaintScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.rate_review,
            title: 'Submit Feedback',
            subtitle: 'Rate services or give suggestions',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackActions(BuildContext context) {
    return _ActionCard(
      icon: Icons.rate_review,
      title: 'Submit New Feedback',
      subtitle: 'Rate services or give suggestions',
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FeedbackScreen()),
        );
      },
    );
  }

  Widget _buildFeedbackList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Feedback', style: AppTextStyles.bodyMediumBold),
        const SizedBox(height: 12),
        if (_feedbacks.isEmpty && !_isLoadingFeedback)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No feedback submitted yet. Tap "Submit New Feedback" to get started.',
              ),
            ),
          )
        else
          ..._feedbacks.map((f) => _FeedbackCard(feedback: f)).toList(),
      ],
    );
  }

  Widget _buildComplaintsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Complaints', style: AppTextStyles.bodyMediumBold),
        const SizedBox(height: 12),
        if (_complaints.isEmpty && !_isLoadingComplaints)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No complaints yet. Tap "Register Complaint" to get started.',
              ),
            ),
          )
        else
          ..._complaints.map((c) => _ComplaintCard(complaint: c)).toList(),
      ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.bodyMediumBold),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final _Complaint complaint;

  const _ComplaintCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    complaint.title,
                    style: AppTextStyles.bodyMediumBold,
                  ),
                ),
                _StatusChip(status: complaint.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    complaint.category,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(complaint.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    complaint.priority,
                    style: TextStyle(
                      color: _getPriorityColor(complaint.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(complaint.description, style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Text(
              'Submitted ${_formatTime(complaint.timestamp)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

class _Complaint {
  final String id;
  final String title;
  final String category;
  final String description;
  final ComplaintStatus status;
  final DateTime timestamp;
  final String priority;

  _Complaint({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.status,
    required this.timestamp,
    required this.priority,
  });
}

enum ComplaintStatus { pending, inProgress, resolved, closed }

class _Feedback {
  final String id;
  final double overallRating;
  final double maintenanceRating;
  final double securityRating;
  final double cleanlinessRating;
  final String comments;
  final String? reply;
  final DateTime timestamp;
  final DateTime? replyTimestamp;

  _Feedback({
    required this.id,
    required this.overallRating,
    required this.maintenanceRating,
    required this.securityRating,
    required this.cleanlinessRating,
    required this.comments,
    this.reply,
    this.replyTimestamp,
    required this.timestamp,
  });
}

class _FeedbackCard extends StatelessWidget {
  final _Feedback feedback;

  const _FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Feedback Submitted',
                    style: AppTextStyles.bodyMediumBold.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${feedback.overallRating.toStringAsFixed(1)}/5',
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRatingRow('Overall', feedback.overallRating),
            _buildRatingRow('Maintenance', feedback.maintenanceRating),
            _buildRatingRow('Security', feedback.securityRating),
            _buildRatingRow('Cleanliness', feedback.cleanlinessRating),
            if (feedback.comments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Comments:',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feedback.comments,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Submitted ${_formatTime(feedback.timestamp)}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            if (feedback.reply != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 18,
                          color: AppColors.primaryRed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Admin Response',
                          style: AppTextStyles.bodyMediumBold.copyWith(
                            color: AppColors.primaryRed,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback.reply!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black87,
                        height: 1.3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Replied: ${_formatTime(feedback.replyTimestamp ?? DateTime.now())}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.floor()
                      ? Icons.star
                      : (index < rating.ceil() && rating % 1 != 0)
                          ? Icons.star_half
                          : Icons.star_border,
                  size: 16,
                  color: AppColors.primaryRed,
                );
              }),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              rating.toStringAsFixed(1),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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