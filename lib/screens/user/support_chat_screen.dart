import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../services/ai_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/helpers.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _chatId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;
    final chatId = 'support_${user.uid}';
    setState(() => _chatId = chatId);

    final existing = await FirebaseService.supportChats().doc(chatId).get();
    if (!existing.exists) {
      await ChatService.createSupportChat(chatId, {
        'userId': user.uid,
        'userName': user.name,
        'userEmail': user.email,
        'status': 'open',
        'source': 'user',
      });
    }
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
    if (text.isEmpty || _chatId == null) return;

    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    final userMsgData = {
      'chatId': _chatId,
      'text': text,
      'senderId': user.uid,
      'senderRole': 'user',
      'senderName': user.name,
      'source': 'user',
      'escalated': false,
    };

    await ChatService.sendSupportMessage(_chatId!, userMsgData);

    final aiResponse = AIService.getResponse(text);

    final botMsgData = {
      'chatId': _chatId,
      'text': aiResponse['text'],
      'senderId': 'ai_bot',
      'senderRole': 'bot',
      'senderName': 'AI Support',
      'source': 'ai',
      'escalated': aiResponse['escalated'],
    };

    await ChatService.sendSupportMessage(_chatId!, botMsgData);

    if (aiResponse['escalated'] == true) {
      final escalationMsg = {
        'chatId': _chatId,
        'text': 'Your query has been escalated to our support team. They will get back to you shortly.',
        'senderId': 'system',
        'senderRole': 'system',
        'senderName': 'System',
        'source': 'system',
        'escalated': true,
      };
      await ChatService.sendSupportMessage(_chatId!, escalationMsg);
    }

    setState(() => _isSending = false);
    _scrollToBottom();
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primarySecondary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, size: 20, color: AppTheme.primarySecondary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Support', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                Text('We reply in seconds', style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.success)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatId == null
                ? Center(child: Text('Initializing chat...', style: GoogleFonts.nunito(color: AppTheme.textLight)))
                : StreamBuilder<QuerySnapshot>(
                    stream: ChatService.getSupportMessages(_chatId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading messages', style: GoogleFonts.nunito(color: AppTheme.textLight)));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_outlined, size: 48, color: AppTheme.textLight),
                              const SizedBox(height: 12),
                              Text('Send a message to get started', style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textLight)),
                            ],
                          ),
                        );
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final isMe = data['senderRole'] == 'user';
                          final isSystem = data['senderRole'] == 'system';
                          final text = data['text'] ?? '';

                          if (isSystem) {
                            return _buildSystemNotice(text);
                          }

                          return _buildMessageBubble(text, isMe, data);
                        },
                      );
                    },
                  ),
          ),
          if (_isSending)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                  const SizedBox(width: 8),
                  Text('AI is thinking...', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textLight)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, -4))],
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
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
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
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemNotice(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.support_agent_rounded, size: 18, color: AppTheme.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textDark, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, Map<String, dynamic> data) {
    final timestamp = data['timestamp'] != null ? DateTime.tryParse(data['timestamp']) : null;
    final escalated = data['escalated'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                data['senderName'] ?? 'AI',
                style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600),
              ),
            ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primary : AppTheme.cardLight,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isMe ? Colors.white : AppTheme.textDark,
                    height: 1.4,
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${timestamp.hour > 12 ? timestamp.hour - 12 : (timestamp.hour == 0 ? 12 : timestamp.hour)}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: isMe ? Colors.white.withOpacity(0.6) : Colors.grey[500],
                        ),
                      ),
                      if (escalated) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.warning_amber_rounded, size: 12, color: isMe ? Colors.white.withOpacity(0.6) : AppTheme.warning),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
