import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import 'buy_membership_screen.dart';

class MyPlansScreen extends StatelessWidget {
  const MyPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('My Plans', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.userProfile;
          if (user == null) {
            return Center(child: Text('Please login', style: GoogleFonts.nunito(color: AppTheme.textLight)));
          }

          if (user.hasActiveMembership) {
            return _buildActivePlan(context, user);
          } else {
            return _buildNoPlan(context);
          }
        },
      ),
    );
  }

  Widget _buildActivePlan(BuildContext context, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.elite, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.membershipType} Member',
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${user.daysLeft} days remaining',
                  style: GoogleFonts.nunito(fontSize: 15, color: Colors.white70),
                ),
                if (user.membershipEndDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Expires on ${formatDate(user.membershipEndDate!)}',
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white60),
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
              color: AppTheme.cardLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Benefits', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 16),
                _benefitItem(Icons.verified_rounded, 'Priority Support'),
                const SizedBox(height: 12),
                _benefitItem(Icons.discount_rounded, 'Exclusive Discounts'),
                const SizedBox(height: 12),
                _benefitItem(Icons.flash_on_rounded, 'Fast Booking Confirmation'),
                const SizedBox(height: 12),
                _benefitItem(Icons.support_agent_rounded, '24/7 Premium Support'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.elite.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.elite),
        ),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textDark)),
      ],
    );
  }

  Widget _buildNoPlan(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_outlined, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No Active Plan',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Subscribe to a membership plan to unlock premium features and exclusive benefits.',
              style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textLight, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyMembershipScreen()));
                },
                icon: const Icon(Icons.shopping_cart_rounded),
                label: Text('Buy Membership', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
