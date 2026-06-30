import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, tp, _) {
                    return SwitchListTile(
                      title: Text('Dark Mode', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
                      subtitle: Text('Toggle dark/light theme', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textLight)),
                      value: tp.isDark,
                      onChanged: (_) => tp.toggleTheme(),
                      activeColor: AppTheme.primary,
                      secondary: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tp.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 20, color: AppTheme.primary),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 72),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_forever_rounded, size: 20, color: AppTheme.error),
                  ),
                  title: Text('Delete Account', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.error)),
                  subtitle: Text('Permanently remove your account', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textLight)),
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Consumer<ThemeProvider>(
              builder: (context, tp, _) {
                return Text(
                  'App Version 1.0.0',
                  style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textLight),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textLight, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              'All your data will be permanently removed.',
              style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.error, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final uid = AuthService.currentUser?.uid;
              if (uid != null) {
                try {
                  await FirestoreService.users().doc(uid).delete();
                  await AuthService.currentUser?.delete();
                  if (context.mounted) {
                    context.read<AuthProvider>().logout();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting account: $e', style: GoogleFonts.nunito()), backgroundColor: AppTheme.error),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Delete', style: GoogleFonts.nunito()),
          ),
        ],
      ),
    );
  }
}
