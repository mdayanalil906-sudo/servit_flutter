import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import 'edit_profile_screen.dart';
import 'my_plans_screen.dart';
import 'my_ratings_screen.dart';
import 'buy_membership_screen.dart';
import 'settings_screen.dart';
import 'help_support_screen.dart';
import '../shared/privacy_policy_screen.dart';
import '../shared/terms_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.userProfile;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHero(context, user),
                const SizedBox(height: 16),
                _buildMenuList(context, user),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, dynamic user) {
    final name = user?.name ?? 'User';
    final email = user?.email ?? 'email@example.com';
    final phone = user?.phone ?? '';
    final photo = user?.profilePhoto ?? '';
    final membershipType = user?.membershipType ?? '';
    final isPremium = user?.isPremium ?? false;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white24,
                backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo.isEmpty
                    ? Text(
                        getInitials(name),
                        style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white),
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(name, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text(email, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 2),
          if (phone.isNotEmpty)
            Text(phone, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
          if (isPremium) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    membershipType.isNotEmpty ? '$membershipType Member' : 'Premium Member',
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, dynamic user) {
    final menuItems = <Map<String, dynamic>>[
      {'icon': Icons.edit_outlined, 'label': 'Edit Profile', 'page': EditProfileScreen()},
      {'icon': Icons.workspace_premium_outlined, 'label': 'My Plans', 'page': const MyPlansScreen()},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Buy Membership', 'page': const BuyMembershipScreen()},
      {'icon': Icons.star_outline_rounded, 'label': 'My Ratings', 'page': const MyRatingsScreen()},
      {'icon': Icons.settings_outlined, 'label': 'Settings', 'page': const SettingsScreen()},
      {'icon': Icons.help_outline_rounded, 'label': 'Help & Support', 'page': const HelpSupportScreen()},
      {'icon': Icons.privacy_tip_outlined, 'label': 'Privacy Policy', 'page': const PrivacyPolicyScreen()},
      {'icon': Icons.description_outlined, 'label': 'Terms & Conditions', 'page': const TermsScreen()},
      {'icon': Icons.logout_rounded, 'label': 'Logout', 'page': null, 'danger': true},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;
          final isDanger = item['danger'] == true;

          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'] as IconData, color: isDanger ? AppTheme.error : AppTheme.primary, size: 22),
                title: Text(
                  item['label'] as String,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDanger ? AppTheme.error : AppTheme.textDark,
                  ),
                ),
                trailing: isDanger
                    ? null
                    : const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight, size: 20),
                onTap: () {
                  if (isDanger) {
                    _showLogoutConfirmation(context);
                  } else if (item['page'] != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => item['page'] as Widget));
                  }
                },
              ),
              if (!isLast) Divider(height: 1, indent: 56, color: AppTheme.borderLight),
            ],
          );
        }),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.nunito())),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Logout', style: GoogleFonts.nunito()),
          ),
        ],
      ),
    );
  }
}


