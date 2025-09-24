import 'package:flutter/material.dart';
import 'package:park_chatapp/constants/app_colors.dart';
import 'package:park_chatapp/constants/app_text_styles.dart';
import 'package:park_chatapp/core/services/chat_service.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _threadId;

  @override
  void initState() {
    super.initState();
    _ensureThread();
  }

  Future<void> _ensureThread() async {
    final id = await AppChatService.createOrGetDmThreadWithAdmin();
    if (mounted) setState(() => _threadId = id);
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
              child: const Icon(
                Icons.admin_panel_settings,
                color: AppColors.primaryRed,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Admin Support',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _threadId == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: AppChatService.streamThreadMessages(_threadId!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final msgs = snapshot.data!;
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: msgs.length,
                          itemBuilder: (context, index) {
                            final m = msgs[index];
                            final isMe =
                                m['senderId'] == AppChatService.currentUid;
                            return _MessageBubble(
                              message: _ChatMessage(
                                text: (m['text'] ?? '') as String,
                                isFromCurrentUser: isMe,
                                timestamp: _parseTs(m['createdAt']),
                              ),
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

  DateTime _parseTs(dynamic v) {
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    return DateTime.now();
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
                    hintText: 'Type your message...',
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

  Future<void> _handleSend() async {
    final String text = _textEditingController.text.trim();
    if (text.isEmpty) return;
    _textEditingController.clear();

    if (_threadId == null) await _ensureThread();
    if (_threadId != null) {
      await AppChatService.sendMessageToThread(_threadId!, text);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getAdminResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('payment') || message.contains('bill')) {
      return 'For payment related queries, please visit the Payments section in the app or contact our billing department at +92-300-1234567.';
    } else if (message.contains('complaint') || message.contains('issue')) {
      return 'I\'m sorry to hear about the issue. Please use the Complaints section to register your complaint, and we\'ll address it promptly.';
    } else if (message.contains('security') || message.contains('emergency')) {
      return 'For security emergencies, please call our security hotline immediately at +92-300-1234567. For non-emergency security matters, use the Security & Alerts section.';
    } else if (message.contains('property') ||
        message.contains('house') ||
        message.contains('apartment')) {
      return 'For property related queries, please check the Property section in the app or visit our sales office. You can also explore available properties in the marketplace.';
    } else if (message.contains('hello') || message.contains('hi')) {
      return 'Hello! How can I assist you today? You can ask me about payments, complaints, security, property, or any other community-related matters.';
    } else {
      return 'Thank you for your message. I\'ll forward this to the relevant department and get back to you soon. For immediate assistance, please use the appropriate sections in the app.';
    }
  }
}

class _ChatMessage {
  final String text;
  final bool isFromCurrentUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isFromCurrentUser,
    required this.timestamp,
  });
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isFromCurrentUser;
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
            Text(
              message.text,
              style: AppTextStyles.bodyMedium.copyWith(color: textColor),
            ),
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
