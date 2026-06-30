import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/services/ai_service.dart';
import 'package:servit_flutter/services/chat_service.dart';
import 'package:servit_flutter/services/firebase_service.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/widgets/message_bubble.dart';

class ExpertChatScreen extends StatefulWidget {
  const ExpertChatScreen({super.key});

  @override
  State<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends State<ExpertChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  String? _supportChatId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final auth = context.read<AuthProvider>();
    final expert = auth.expertProfile;
    if (expert == null) return;
    setState(() {
      _messages.add({
        'text': 'Hello! How can I help you today?',
        'isMe': false,
        'timestamp': DateTime.now(),
      });
    });
    final chatId = 'support_${expert.uid}';
    _supportChatId = chatId;
    final existing = await FirebaseService.getDocument('support_chats', chatId);
    if (existing == null) {
      await ChatService.createSupportChat(chatId, {
        'userId': expert.uid,
        'userName': expert.name,
        'userEmail': expert.email,
        'status': 'open',
        'source': 'expert',
      });
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;
    _msgController.clear();
    final userMsg = {
      'text': text,
      'isMe': true,
      'timestamp': DateTime.now(),
    };
    setState(() => _messages.add(userMsg));
    _scrollToBottom();

    setState(() => _isSending = true);
    try {
      if (_supportChatId != null) {
        await ChatService.sendSupportMessage(_supportChatId!, {
          'chatId': _supportChatId,
          'text': text,
          'senderId': context.read<AuthProvider>().expertProfile?.uid ?? '',
          'senderRole': 'expert',
          'senderName': context.read<AuthProvider>().expertProfile?.name ?? '',
          'source': 'expert',
        });
      }
      final response = AIService.getResponse(text);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      final aiMsg = {
        'text': response['text'] as String,
        'isMe': false,
        'timestamp': DateTime.now(),
      };
      setState(() => _messages.add(aiMsg));
      _scrollToBottom();
      if (response['escalated'] == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        setState(() {
          _messages.add({
            'text':
                'This issue has been escalated to our support team. They will reach out to you shortly.',
            'isMe': false,
            'timestamp': DateTime.now(),
          });
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': 'Sorry, something went wrong. Please try again.',
          'isMe': false,
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _isSending = false);
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

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 10),
            Text('AI Support'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  message: msg['text'] as String,
                  isMe: msg['isMe'] as bool,
                  timestamp: msg['timestamp'] as DateTime,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type your question...',
                        hintStyle: GoogleFonts.nunito(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppTheme.borderDark
                            : AppTheme.bgLight,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
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
}
