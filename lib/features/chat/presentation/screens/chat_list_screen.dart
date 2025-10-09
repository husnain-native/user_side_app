import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:park_chatapp/features/chat/presentation/screens/admin_chat_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/direct_chat_screen.dart';
import 'package:park_chatapp/features/chat/presentation/screens/group_chat_screen.dart';
import 'package:park_chatapp/core/services/chat_service.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  String? _uid = FirebaseAuth.instance.currentUser?.uid;
  late TabController _tabController;
  String? _adminThreadId;
  Map<String, int> _unreadCounts = {};
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Update UI when tab changes
    });
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _uid = user?.uid;
      });
    });
    _initializeAdminChat();
  }

  Future<void> _initializeAdminChat() async {
    try {
      _adminThreadId = await AppChatService.createOrGetDmThreadWithAdmin();
    } catch (e) {
      print('Error initializing admin chat: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Text(
          'Chats',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
        ),
      ),
      body:
          _uid == null
              ? const Center(child: Text('Please sign in'))
              : Column(
                children: [
                  // Custom Tab Bar with horizontal scroll
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTab('All', 0),
                          const SizedBox(width: 8),
                          _buildTab('Chats', 1),
                          const SizedBox(width: 8),
                          _buildTab('Unread', 2),
                          const SizedBox(width: 8),
                          _buildTab('Groups', 3),
                        ],
                      ),
                    ),
                  ),
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllTab(),
                        _buildChatsTab(),
                        _buildUnreadTab(),
                        _buildGroupsTab(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {}); // Force rebuild to update active state
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 26),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryRedOpacity : Colors.white,
          border: Border.all(
            color: isActive ? AppColors.primaryRed : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isActive ? AppColors.primaryRed : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance.ref("threads").onValue.asBroadcastStream(),
      builder: (context, threadsSnapshot) {
        if (threadsSnapshot.hasError) {
          return Center(child: Text('Error: ${threadsSnapshot.error}'));
        }

        return StreamBuilder<DatabaseEvent>(
          stream:
              FirebaseDatabase.instance
                  .ref("groups")
                  .onValue
                  .asBroadcastStream(),
          builder: (context, groupsSnapshot) {
            if (groupsSnapshot.hasError) {
              return Center(child: Text('Error: ${groupsSnapshot.error}'));
            }

            final allChats = <Map<String, dynamic>>[];

            // Add threads (DMs and admin chat)
            if (threadsSnapshot.hasData &&
                threadsSnapshot.data!.snapshot.value != null) {
              final threadsData =
                  threadsSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              threadsData.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  final chat = Map<String, dynamic>.from(value);
                  final participants = chat["participants"];
                  List<String> participantList = [];

                  if (participants is Map<dynamic, dynamic>) {
                    participantList =
                        participants.keys.map((e) => e.toString()).toList();
                  } else if (participants is List) {
                    participantList =
                        participants.map((e) => e.toString()).toList();
                  }

                  if (participantList.contains(_uid)) {
                    final isGroup = (chat["isGroup"] as bool?) ?? false;
                    final bool adminFlag =
                        (chat["isAdminThread"] as bool?) == true ||
                        chat.containsKey('adminName');
                    final isAdminChat = adminFlag && !isGroup;

                    if (isAdminChat) {
                      // Admin chat should be first
                      allChats.insert(0, {"id": key, ...chat, "isAdmin": true});
                    } else {
                      allChats.add({"id": key, ...chat, "isAdmin": false});
                    }
                  }
                }
              });
            }

            // Add groups
            if (groupsSnapshot.hasData &&
                groupsSnapshot.data!.snapshot.value != null) {
              final groupsData =
                  groupsSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              groupsData.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  final group = Map<String, dynamic>.from(value);
                  final members = group["members"];
                  List<String> memberList = [];

                  if (members is Map<dynamic, dynamic>) {
                    memberList = members.keys.map((e) => e.toString()).toList();
                  } else if (members is List) {
                    memberList = members.map((e) => e.toString()).toList();
                  }

                  if (memberList.contains(_uid)) {
                    allChats.add({"id": key, ...group, "isGroup": true});
                  }
                }
              });
            }

            if (allChats.isEmpty) {
              return _buildEmptyListView();
            }

            return ListView.builder(
              itemCount: allChats.length,
              itemBuilder: (context, index) {
                final chat = allChats[index];
                final isAdmin = chat["isAdmin"] as bool? ?? false;
                final isGroup = chat["isGroup"] as bool? ?? false;

                if (isAdmin) {
                  return _AdminChatTile(
                    lastMessage: chat["lastMessage"] ?? "No messages yet",
                    lastMessageTime: _parseTimestamp(chat["lastMessageAt"]),
                    unreadCount: _getUnreadCount(chat["unreadCounts"]),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminChatScreen(),
                        ),
                      );
                    },
                  );
                } else if (isGroup) {
                  return _buildGroupTile(chat);
                } else {
                  return _buildDmTile(chat);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatsTab() {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance.ref("threads").onValue.asBroadcastStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildEmptyListView();
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final dmChats = <Map<String, dynamic>>[];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final chat = Map<String, dynamic>.from(value);
            final isGroup = (chat["isGroup"] as bool?) ?? false;
            if (isGroup) return; // Skip groups in chats tab

            final participants = chat["participants"];
            List<String> participantList = [];

            if (participants is Map<dynamic, dynamic>) {
              participantList =
                  participants.keys.map((e) => e.toString()).toList();
            } else if (participants is List) {
              participantList = participants.map((e) => e.toString()).toList();
            }

            if (participantList.contains(_uid)) {
              final isAdminChat =
                  (chat["isAdminThread"] as bool?) == true ||
                  chat.containsKey('adminName');

              if (isAdminChat) {
                // Admin chat should be first
                dmChats.insert(0, {"id": key, ...chat, "isAdmin": true});
              } else {
                dmChats.add({"id": key, ...chat, "isAdmin": false});
              }
            }
          }
        });

        if (dmChats.isEmpty) {
          return _buildEmptyListView();
        }

        return ListView.builder(
          itemCount: dmChats.length,
          itemBuilder: (context, index) {
            final chat = dmChats[index];
            final isAdmin = chat["isAdmin"] as bool? ?? false;

            if (isAdmin) {
              return _AdminChatTile(
                lastMessage: chat["lastMessage"] ?? "No messages yet",
                lastMessageTime: _parseTimestamp(chat["lastMessageAt"]),
                unreadCount: _getUnreadCount(chat["unreadCounts"]),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminChatScreen()),
                  );
                },
              );
            } else {
              return _buildDmTile(chat);
            }
          },
        );
      },
    );
  }

  Widget _buildUnreadTab() {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance.ref("threads").onValue.asBroadcastStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildEmptyListView();
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final unreadChats = <Map<String, dynamic>>[];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final chat = Map<String, dynamic>.from(value);
            final participants = chat["participants"];
            List<String> participantList = [];

            if (participants is Map<dynamic, dynamic>) {
              participantList =
                  participants.keys.map((e) => e.toString()).toList();
            } else if (participants is List) {
              participantList = participants.map((e) => e.toString()).toList();
            }

            if (participantList.contains(_uid)) {
              final unreadCounts =
                  chat["unreadCounts"] as Map<dynamic, dynamic>? ?? {};
              final userUnreadCount =
                  int.tryParse('${unreadCounts[_uid] ?? 0}') ?? 0;

              if (userUnreadCount > 0) {
                final isAdmin =
                    (chat["isAdminThread"] as bool?) == true ||
                    chat.containsKey('adminName');
                if (isAdmin) {
                  unreadChats.insert(0, {"id": key, ...chat, "isAdmin": true});
                } else {
                  unreadChats.add({"id": key, ...chat, "isAdmin": false});
                }
              }
            }
          }
        });

        if (unreadChats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No unread messages',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'All caught up!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: unreadChats.length,
          itemBuilder: (context, index) {
            final chat = unreadChats[index];
            final isAdmin = chat["isAdmin"] as bool? ?? false;

            if (isAdmin) {
              return _AdminChatTile(
                lastMessage: chat["lastMessage"] ?? "No messages yet",
                lastMessageTime: _parseTimestamp(chat["lastMessageAt"]),
                unreadCount: _getUnreadCount(chat["unreadCounts"]),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminChatScreen()),
                  );
                },
              );
            } else if ((chat["isGroup"] as bool?) ?? false) {
              return _buildGroupTile(chat);
            } else {
              return _buildDmTile(chat);
            }
          },
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance.ref("groups").onValue.asBroadcastStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildEmptyListView();
        }

        final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
        final groups = <Map<String, dynamic>>[];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic>) {
            final group = Map<String, dynamic>.from(value);
            final members = group["members"];
            List<String> memberList = [];

            if (members is Map<dynamic, dynamic>) {
              memberList = members.keys.map((e) => e.toString()).toList();
            } else if (members is List) {
              memberList = members.map((e) => e.toString()).toList();
            }

            if (memberList.contains(_uid)) {
              groups.add({"id": key, ...group});
            }
          }
        });

        if (groups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No groups yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Create a group to get started!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) => _buildGroupTile(groups[index]),
        );
      },
    );
  }

  Widget _buildDmTile(Map<String, dynamic> thread) {
    final participants = thread["participants"];
    List<String> participantList = [];

    if (participants is Map<dynamic, dynamic>) {
      participantList = participants.keys.map((e) => e.toString()).toList();
    } else if (participants is List) {
      participantList = participants.map((e) => e.toString()).toList();
    }

    // Get the other participant's ID (not current user)
    final otherParticipantId = participantList.firstWhere(
      (id) => id != _uid,
      orElse: () => 'unknown',
    );

    // Get seller name if available, otherwise use participant ID
    final sellerName = thread["sellerName"] ?? otherParticipantId;

    final unreadCounts = thread["unreadCounts"] as Map<dynamic, dynamic>? ?? {};
    final userUnreadCount = int.tryParse('${unreadCounts[_uid] ?? 0}') ?? 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryRed,
        child: Text(
          sellerName.isNotEmpty ? sellerName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        sellerName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        thread["lastMessage"] ?? "No messages yet",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          userUnreadCount > 0
              ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  userUnreadCount > 9 ? '9+' : userUnreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : Text(
                _formatTime(_parseTimestamp(thread["lastMessageAt"])),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
      onTap: () async {
        if (userUnreadCount > 0) {
          await AppChatService.markThreadAsRead(thread["id"]);
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => DirectChatScreen(
                  sellerName: sellerName,
                  sellerId: otherParticipantId,
                ),
          ),
        );
      },
    );
  }

  Widget _buildGroupTile(Map<String, dynamic> group) {
    final unreadCounts = group["unreadCounts"] as Map<dynamic, dynamic>? ?? {};
    final userUnreadCount = int.tryParse('${unreadCounts[_uid] ?? 0}') ?? 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.group, color: Colors.white),
      ),
      title: Text(
        group["name"] ?? "Unnamed Group",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        group["lastMessage"] ?? "No messages yet",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          userUnreadCount > 0
              ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  userUnreadCount > 9 ? '9+' : userUnreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : Text(
                _formatTime(_parseTimestamp(group["lastMessageAt"])),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
      onTap: () async {
        if (userUnreadCount > 0) {
          // Mark group as read - wrap in try-catch to handle permission errors
          try {
            final groupRef = FirebaseDatabase.instance.ref(
              "groups/${group["id"]}/unreadCounts",
            );
            await groupRef.child(_uid!).set(0);
          } catch (e) {
            print('Error marking group as read: $e');
            // Continue with navigation even if marking as read fails
          }
        }

        // Create Group object from the data - handle both Map and List types
        List<String> memberList = [];
        final members = group["members"];
        if (members is Map<dynamic, dynamic>) {
          memberList = members.keys.map((e) => e.toString()).toList();
        } else if (members is List) {
          memberList = members.map((e) => e.toString()).toList();
        }

        final groupObj = Group(
          id: group["id"],
          name: group["name"] ?? "Unnamed Group",
          members: memberList,
          isAuthor: false,
        );

        // Use MaterialPageRoute directly instead of named route to avoid potential issues
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupChatScreen(group: groupObj)),
        );
      },
    );
  }

  Widget _buildEmptyListView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No chats yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            'Start a conversation!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  int _getUnreadCount(Map<dynamic, dynamic>? unreadCounts) {
    if (unreadCounts == null) return 0;
    return int.tryParse('${unreadCounts[_uid] ?? 0}') ?? 0;
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class _AdminChatTile extends StatelessWidget {
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final VoidCallback onTap;

  const _AdminChatTile({
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
      ),
      title: const Text(
        'Park View City',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing:
          unreadCount > 0
              ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : Text(
                _formatTime(lastMessageTime),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
