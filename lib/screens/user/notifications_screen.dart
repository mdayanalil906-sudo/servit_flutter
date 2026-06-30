import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, np, _) {
              if (np.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () async {
                  await np.markAllAsRead();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('All marked as read', style: GoogleFonts.nunito())),
                    );
                  }
                },
                child: Text(
                  'Mark All Read',
                  style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, np, _) {
          final notifications = np.notifications;
          if (notifications.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_off_outlined,
              message: 'No notifications yet',
              subtitle: 'We\'ll let you know when something arrives',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final user = context.read<AuthProvider>()..loadUserProfile();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () => np.markAsRead(notification.id),
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
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'booking':
        return Icons.book_online_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'rating':
        return Icons.star_rounded;
      case 'chat':
        return Icons.chat_rounded;
      case 'membership':
        return Icons.workspace_premium_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read ? AppTheme.cardLight : AppTheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: notification.read ? null : Border.all(color: AppTheme.primary.withOpacity(0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.read ? AppTheme.bgLight : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(notification.icon),
                size: 20,
                color: notification.read ? AppTheme.textLight : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppTheme.textLight,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo(notification.createdAt),
                    style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
