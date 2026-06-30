import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/models/notification_model.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/providers/notification_provider.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/utils/helpers.dart';

class ExpertNotificationsScreen extends StatefulWidget {
  const ExpertNotificationsScreen({super.key});

  @override
  State<ExpertNotificationsScreen> createState() =>
      _ExpertNotificationsScreenState();
}

class _ExpertNotificationsScreenState
    extends State<ExpertNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.expertProfile != null) {
        context.read<NotificationProvider>().subscribe(auth.expertProfile!.uid);
      }
    });
  }

  Future<void> _markAllRead() async {
    await context.read<NotificationProvider>().markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, np, _) {
              if (np.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: _markAllRead,
                child: Text(
                  'Mark All Read',
                  style: GoogleFonts.nunito(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, np, _) {
          if (np.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No notifications yet',
                    style: GoogleFonts.nunito(
                        fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthProvider>();
              if (auth.expertProfile != null) {
                context
                    .read<NotificationProvider>()
                    .subscribe(auth.expertProfile!.uid);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: np.notifications.length,
              itemBuilder: (context, index) {
                final notification = np.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  isDark: isDark,
                  textColor: textColor,
                  cardColor: cardColor,
                  onTap: () {
                    if (!notification.read) {
                      np.markAsRead(notification.id);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final Color textColor;
  final Color cardColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.textColor,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read ? cardColor : AppTheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.read
                ? (isDark ? AppTheme.borderDark : AppTheme.borderLight)
                : AppTheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.read
                    ? Colors.grey.withValues(alpha: 0.1)
                    : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForType(notification.icon),
                size: 20,
                color: notification.read ? Colors.grey : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: notification.read
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo(notification.createdAt),
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                margin: const EdgeInsets.only(left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String icon) {
    switch (icon) {
      case 'booking':
        return Icons.event_rounded;
      case 'payment':
        return Icons.payments_rounded;
      case 'message':
        return Icons.chat_rounded;
      case 'system':
        return Icons.info_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
