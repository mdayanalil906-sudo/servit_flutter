import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class BuyMembershipScreen extends StatelessWidget {
  const BuyMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Buy Membership', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildPlanCard(
              name: 'Master Monthly',
              price: '₹149',
              period: '/month',
              color: AppTheme.elite,
              features: ['Premium Features', 'Priority Support', 'Exclusive Discounts'],
              onBuy: () => _buyPlan(context, 'Master Monthly', 149),
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              name: 'Trial',
              price: '₹10',
              period: ' / 4 days',
              color: AppTheme.success,
              features: ['Full Access for 4 Days'],
              onBuy: () => _buyPlan(context, 'Trial', 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required String period,
    required Color color,
    required List<String> features,
    required VoidCallback onBuy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(price, style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(period, style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textLight)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: color),
                    const SizedBox(width: 8),
                    Text(f, style: GoogleFonts.nunito(fontSize: 14, color: AppTheme.textDark)),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Buy Now', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _buyPlan(BuildContext context, String plan, double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$plan purchase initiated. Amount: ₹${amount.toInt()}', style: GoogleFonts.nunito()),
      ),
    );
  }
}
