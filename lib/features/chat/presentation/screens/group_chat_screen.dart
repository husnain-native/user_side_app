import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/features/chat/domain/models/group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper function to get user name from UID
  Future<String> _getUserName(String uid) async {
    try {
      // First try to get from users node
      final userSnap = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (userSnap.exists && userSnap.value is Map) {
        final userData = Map<dynamic, dynamic>.from(userSnap.value as Map);
        final displayName = userData['displayName'] as String?;
        if (displayName != null && displayName.trim().isNotEmpty) {
          return displayName.trim();
        }
        final email = userData['email'] as String?;
        if (email != null && email.trim().isNotEmpty) {
          return email.trim();
        }
      }
      
      // If not found in users, try admins node
      final adminSnap = await FirebaseDatabase.instance.ref('admins/$uid').get();
      if (adminSnap.exists && adminSnap.value is Map) {
        final adminData = Map<dynamic, dynamic>.from(adminSnap.value as Map);
        // Check for 'name' field first (as stored by AdminService)
        final name = adminData['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          return name.trim();
        }
        // Fallback to displayName if name not found
        final displayName = adminData['displayName'] as String?;
        if (displayName != null && displayName.trim().isNotEmpty) {
          return displayName.trim();
        }
        final email = adminData['email'] as String?;
        if (email != null && email.trim().isNotEmpty) {
          return email.trim();
        }
      }
      
      return uid; // Fallback to UID if no name/email found
    } catch (e) {
      return uid; // Fallback to UID on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
            Text(
              '${widget.group.members.length} members',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenu,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'group_info',
                    child: Text('Group info'),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear messages'),
                  ),
                  const PopupMenuItem(
                    value: 'leave',
                    child: Text('Leave group'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('groups/${widget.group.id}/messages')
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages yet'));
                }
                final raw = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final msgs = raw.entries.map((e) {
                  final m = Map<String, dynamic>.from(e.value as Map);
                  m['id'] = e.key.toString();
                  return m;
                }).toList()
                  ..sort((a, b) {
                    final int at = (a['createdAt'] ?? 0) is int ? a['createdAt'] as int : 0;
                    final int bt = (b['createdAt'] ?? 0) is int ? b['createdAt'] as int : 0;
                    return at.compareTo(bt);
                  });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final m = msgs[index];
                    final String type = (m['type'] ?? 'message') as String;
                    if (type == 'system') {
                      final String? actorId = m['actorId'] as String?;
                      final List<dynamic> targets = List<dynamic>.from(m['targets'] ?? []);
                      final Future<String>? actorFuture = actorId == null ? null : _getUserName(actorId);
                      
                      return FutureBuilder<String>(
                        future: actorFuture,
                        builder: (context, actorSnap) {
                          final actorName = actorSnap.data ?? 'Someone';
                          
                          if (targets.isEmpty) {
                            final textKey = (m['text'] ?? '') as String;
                            final display = textKey == 'added_to_group'
                                ? '$actorName added to group'
                                : textKey == 'removed_from_group'
                                    ? '$actorName removed from group'
                                    : textKey;
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  display,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          final Future<List<String>> targetNamesFuture = Future.wait(
                            targets.map((t) => _getUserName(t.toString())),
                          );
                          
                          return FutureBuilder<List<String>>(
                            future: targetNamesFuture,
                            builder: (context, tgtSnap) {
                              final targetNames = (tgtSnap.data ?? targets.map((e)=>e.toString()).toList());
                              final joined = targetNames.join(', ');
                              final textKey = (m['text'] ?? '') as String;
                              final display = textKey == 'added_to_group'
                                  ? '$actorName added $joined'
                                  : textKey == 'removed_from_group'
                                      ? '$actorName removed $joined'
                                      : textKey;
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    display,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                    final String senderId = (m['senderId'] ?? '') as String;
                    final bool isMe = senderId == _uid;
                    final Future<String>? nameFuture = isMe ? null : _getUserName(senderId);
                    return FutureBuilder<String>(
                      future: nameFuture,
                      builder: (context, snap) {
                        final String senderLabel = isMe ? 'You' : (snap.data ?? senderId);
                        return _GroupBubbleFirestore(
                          text: (m['text'] ?? '') as String,
                          isMe: isMe,
                          senderLabel: senderLabel,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Message',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primaryRed,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenu(String value) {
    switch (value) {
      case 'group_info':
        _showGroupInfo();
        break;
      case 'clear':
        setState(() => widget.group.messages.clear());
        break;
      case 'leave':
        Navigator.pop(context);
        break;
    }
  }

  void _handleSend() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final DatabaseReference groupRef = FirebaseDatabase.instance.ref('groups/${widget.group.id}');
    final DatabaseReference msgRef = groupRef.child('messages').push();
    await msgRef.set({
      'text': text,
      'senderId': _uid,
      'createdAt': ServerValue.timestamp,
    });

    // Update group metadata
    final DataSnapshot groupSnap = await groupRef.get();
    Map<dynamic, dynamic> unread = {};
    if (groupSnap.exists && groupSnap.value is Map) {
      final data = Map<dynamic, dynamic>.from(groupSnap.value as Map);
      unread = Map<dynamic, dynamic>.from(data['unreadCounts'] ?? {});
    }
    for (final member in widget.group.members) {
      if (member == _uid) continue;
      final int current = int.tryParse('${unread[member] ?? 0}') ?? 0;
      unread[member] = current + 1;
    }
    await groupRef.update({
      'lastMessage': text,
      'lastMessageAt': ServerValue.timestamp,
      'unreadCounts': unread,
    });
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Group info', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 12),
              Text(
                'Name: ${widget.group.name}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Members (${widget.group.members.length})',
                style: AppTextStyles.bodyMediumBold,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.group.members
                    .map((memberId) => FutureBuilder<String>(
                          future: _getUserName(memberId),
                          builder: (context, snapshot) {
                            final memberName = snapshot.data ?? memberId;
                            return Chip(
                              label: Text(memberName),
                              avatar: CircleAvatar(
                                backgroundColor: AppColors.primaryRed.withOpacity(0.2),
                                child: Text(
                                  memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _GroupMessageBubble extends StatelessWidget {
  final GroupMessage message;

  const _GroupMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.sender == 'You';
    final Color bubbleColor =
        isMe ? AppColors.primaryRed : Colors.grey.shade200;
    final Color textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  message.sender,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            Text(message.text, style: TextStyle(color: textColor)),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(dt.hour);
    final minutes = twoDigits(dt.minute);
    return '$hours:$minutes';
  }
}

class _GroupBubbleFirestore extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderLabel;

  const _GroupBubbleFirestore({
    required this.text,
    required this.isMe,
    required this.senderLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor =
        isMe ? AppColors.primaryRed : Colors.grey.shade200;
    final Color textColor = isMe ? Colors.white : Colors.black87;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isMe ? 60 : 12,
          right: isMe ? 12 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  senderLabel,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            Text(text, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}
