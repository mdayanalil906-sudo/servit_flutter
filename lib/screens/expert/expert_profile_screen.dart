import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/services/firestore_service.dart';
import 'package:servit_flutter/utils/helpers.dart';

class ExpertProfileScreen extends StatefulWidget {
  const ExpertProfileScreen({super.key});

  @override
  State<ExpertProfileScreen> createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends State<ExpertProfileScreen> {
  Future<void> _toggleOnline(bool value) async {
    final auth = context.read<AuthProvider>();
    final expert = auth.expertProfile;
    if (expert == null) return;
    await FirestoreService.updateExpertProfile(expert.uid, {'isOnline': value});
    auth.updateExpertProfile(expert.copyWith(isOnline: value));
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Logout', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final expert = auth.expertProfile;
          if (expert == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            backgroundImage:
                                expert.profilePhoto.isNotEmpty
                                    ? NetworkImage(expert.profilePhoto)
                                    : null,
                            child: expert.profilePhoto.isEmpty
                                ? Text(
                                    getInitials(expert.name),
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          if (expert.isExpertPremium)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.elite,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.auto_awesome_rounded,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        expert.name,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expert.email,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (expert.phone.isNotEmpty)
                        Text(
                          expert.phone,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          expert.category,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            expert.isOnline ? 'Online' : 'Offline',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: expert.isOnline,
                            activeColor: Colors.white,
                            activeTrackColor:
                                AppTheme.success.withValues(alpha: 0.6),
                            onChanged: _toggleOnline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StatTile(
                        icon: Icons.work_history_rounded,
                        label: 'Jobs',
                        value: '${expert.jobs}',
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        icon: Icons.star_rounded,
                        label: 'Rating',
                        value: expert.rating.toStringAsFixed(1),
                        color: AppTheme.warning,
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        icon: Icons.verified_rounded,
                        label: 'Verified',
                        value: expert.isVerified ? 'Yes' : 'No',
                        color: expert.isVerified
                            ? AppTheme.success
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _MenuCard(
                  items: [
                    _MenuItem(
                        Icons.edit_rounded, 'Edit Profile', () {
                      Navigator.pushNamed(context, '/expert/edit-profile');
                    }),
                    _MenuItem(
                        Icons.photo_library_rounded, 'Work Photos', () {
                      Navigator.pushNamed(context, '/expert/work-photos');
                    }),
                    _MenuItem(
                        Icons.verified_user_rounded, 'Verification', () {
                      Navigator.pushNamed(context, '/expert/verify');
                    }),
                    _MenuItem(
                        Icons.auto_awesome_rounded, 'Upgrade to Elite', () {
                      Navigator.pushNamed(context, '/expert/upgrade');
                    }),
                    _MenuItem(Icons.settings_rounded, 'Settings', () {
                      Navigator.pushNamed(context, '/expert/settings');
                    }),
                    _MenuItem(Icons.help_rounded, 'Help', () {
                      Navigator.pushNamed(context, '/expert/help');
                    }),
                    _MenuItem(Icons.chat_rounded, 'Chat Support', () {
                      Navigator.pushNamed(context, '/expert/chat-support');
                    }),
                    _MenuItem(Icons.privacy_tip_rounded, 'Privacy Policy', () {
                      Navigator.pushNamed(context, '/expert/privacy');
                    }),
                    _MenuItem(
                        Icons.description_rounded, 'Terms & Conditions', () {
                      Navigator.pushNamed(context, '/expert/terms');
                    }),
                    _MenuItem(Icons.logout_rounded, 'Logout', _logout,
                        isDestructive: true),
                  ],
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem(this.icon, this.title, this.onTap, {this.isDestructive = false});
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final bool isDark;
  final Color cardColor;
  final Color textColor;

  const _MenuCard({
    required this.items,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  item.icon,
                  color: item.isDestructive
                      ? AppTheme.error
                      : AppTheme.primary,
                  size: 22,
                ),
                title: Text(
                  item.title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: item.isDestructive
                        ? AppTheme.error
                        : textColor,
                  ),
                ),
                trailing: item.isDestructive
                    ? null
                    : Icon(Icons.chevron_right_rounded,
                        color: Colors.grey[400], size: 20),
                onTap: item.onTap,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minVerticalPadding: 0,
                dense: true,
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
            ],
          );
        }),
      ),
    );
  }
}
