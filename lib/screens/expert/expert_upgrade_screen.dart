import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/services/firestore_service.dart';

class ExpertUpgradeScreen extends StatefulWidget {
  const ExpertUpgradeScreen({super.key});

  @override
  State<ExpertUpgradeScreen> createState() => _ExpertUpgradeScreenState();
}

class _ExpertUpgradeScreenState extends State<ExpertUpgradeScreen> {
  bool _isProcessing = false;

  Future<void> _purchaseMembership(String type, double price) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Purchase',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          price > 0
              ? 'Buy $type membership for ₹${price.toStringAsFixed(0)}?'
              : 'Start your $type trial for ₹${price.toStringAsFixed(0)}?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Buy', style: TextStyle(color: AppTheme.primary))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isProcessing = true);
    try {
      final auth = context.read<AuthProvider>();
      final expert = auth.expertProfile;
      if (expert == null) return;

      final now = DateTime.now();
      final endDate = type == 'trial'
          ? now.add(const Duration(days: 4))
          : now.add(const Duration(days: 30));

      await FirestoreService.updateExpertProfile(expert.uid, {
        'membershipStatus': 'active',
        'membershipType': type == 'trial' ? 'trial' : 'elite',
        'membershipStartDate': now.toIso8601String(),
        'membershipEndDate': endDate.toIso8601String(),
        'isExpertPremium': true,
      });

      await auth.loadExpertProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${type == 'trial' ? 'Trial' : 'Elite'} membership activated!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;
    final auth = context.watch<AuthProvider>();
    final expert = auth.expertProfile;
    final hasActiveMembership = expert?.hasActiveMembership ?? false;
    final membershipType = expert?.membershipType ?? '';
    final daysLeft = expert?.daysLeft ?? 0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Elite Membership'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.elite, AppTheme.elite.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Elite Membership',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹149/month',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (hasActiveMembership) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$daysLeft days remaining',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (membershipType == 'trial')
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Trial Plan',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benefits',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _benefitItem(Icons.cancel_rounded, 'Waived Cancellation Fees'),
                  _benefitItem(
                      Icons.priority_high_rounded, 'Priority Order Access'),
                  _benefitItem(Icons.verified_rounded, 'Premium Badge'),
                  _benefitItem(Icons.trending_up_rounded, 'Higher Search Ranking'),
                  _benefitItem(Icons.support_agent_rounded, 'Priority Support'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!hasActiveMembership) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _purchaseMembership('elite', 149),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.elite,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Buy Elite - ₹149/month',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isProcessing
                      ? null
                      : () => _purchaseMembership('trial', 10),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.elite,
                    side: const BorderSide(color: AppTheme.elite),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Try for ₹10 (4 Days)',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            if (hasActiveMembership)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Membership is already active'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.success,
                    side: const BorderSide(color: AppTheme.success),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Membership Active',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _benefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.elite.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.elite),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.nunito(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
