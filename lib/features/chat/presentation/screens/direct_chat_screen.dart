import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DirectChatScreen extends StatefulWidget {
  final String sellerName;
  final String? sellerId;

  const DirectChatScreen({super.key, required this.sellerName, this.sellerId});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _threadId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      if (widget.sellerId != null) {
        _threadId = await AppChatService.createOrGetDmThreadWithSeller(
          widget.sellerId!,
          widget.sellerName,
        );
      }
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white.withOpacity(0.9),
              child: const Icon(Icons.person, color: AppColors.primaryRed, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              widget.sellerName,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _threadId != null
                      ? StreamBuilder<List<Map<String, dynamic>>>(
                          stream: AppChatService.streamThreadMessages(_threadId!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            final messages = snapshot.data!;
                            if (messages.isEmpty) {
                              return const Center(
                                child: Text('No messages yet. Start the conversation!'),
                              );
                            }
                            
                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isFromCurrentUser = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                                return _MessageBubble(
                                  text: message['text'] ?? '',
                                  isFromCurrentUser: isFromCurrentUser,
                                  timestamp: DateTime.fromMillisecondsSinceEpoch(
                                    message['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : const Center(child: Text('Unable to load chat')),
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
                  controller: _textEditingController,
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Type your message',
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

  void _handleSend() async {
    final String text = _textEditingController.text.trim();
    if (text.isEmpty || _threadId == null) return;

    _textEditingController.clear();

    try {
      await AppChatService.sendMessageToThread(_threadId!, text);
      
      // Mark thread as read for current user
      await AppChatService.markThreadAsRead(_threadId!);
      
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isFromCurrentUser;
  final DateTime timestamp;

  const _MessageBubble({
    required this.text,
    required this.isFromCurrentUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = isFromCurrentUser;
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(color: textColor),
            ),
            Text(
              _formatTime(timestamp),
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
