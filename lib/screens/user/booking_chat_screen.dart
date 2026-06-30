import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/message_bubble.dart';
import '../../services/chat_service.dart';

class BookingChatScreen extends StatefulWidget {
  final String roomId;
  final String bookingId;
  final String expertName;
  final String expertId;

  const BookingChatScreen({
    super.key,
    required this.roomId,
    required this.bookingId,
    required this.expertName,
    required this.expertId,
  });

  @override
  State<BookingChatScreen> createState() => _BookingChatScreenState();
}

class _BookingChatScreenState extends State<BookingChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().subscribeMessages(widget.roomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;

    _messageController.clear();

    final msgData = {
      'roomId': widget.roomId,
      'senderId': user.uid,
      'senderRole': 'user',
      'senderName': user.name,
      'text': text,
      'type': 'text',
      'read': false,
    };

    final success = await context.read<ChatProvider>().sendMessage(widget.roomId, msgData);
    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(
                widget.expertName.isNotEmpty ? widget.expertName[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.expertName, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('Online', style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.success)),
              ],
            ),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, cp, _) {
          final messages = cp.messages;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (messages.isNotEmpty) _scrollToBottom();
          });

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text('No messages yet. Start a conversation!', style: GoogleFonts.nunito(color: AppTheme.textLight)),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderRole == 'user';
                          return MessageBubble(
                            message: msg.text,
                            isMe: isMe,
                            timestamp: msg.timestamp,
                            isRead: msg.read,
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardLight,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, -4)),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.bgLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textLight),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              border: InputBorder.none,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            maxLines: 4,
                            minLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
