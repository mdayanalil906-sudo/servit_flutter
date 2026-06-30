import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:servit_flutter/config/theme.dart';

class ExpertTermsScreen extends StatelessWidget {
  const ExpertTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: June 2025',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            _section(
              '1. Acceptance of Terms',
              'By accessing or using the SERVIT platform, you agree to be bound by these Terms & Conditions. If you do not agree with any part of these terms, you may not use our services. We reserve the right to update these terms at any time.',
            ),
            _section(
              '2. Description of Service',
              'SERVIT is a platform that connects users with verified service experts. We facilitate the booking and payment process but are not directly responsible for the quality of services provided by experts. All services are provided by independent professionals.',
            ),
            _section(
              '3. User Registration',
              'You must register for an account to use our services. You agree to provide accurate, current, and complete information during registration. You are responsible for maintaining the confidentiality of your account credentials and for all activities under your account.',
            ),
            _section(
              '4. Expert Obligations',
              'Experts listing on SERVIT must maintain accurate profiles, provide high-quality services, and comply with all applicable laws. Experts agree to complete booked services professionally and on time. Failure to do so may result in account suspension or termination.',
            ),
            _section(
              '5. User Obligations',
              'Users agree to treat experts with respect, provide accurate service requirements, and pay for services rendered. Users must not misuse the platform, engage in fraudulent activities, or violate any applicable laws while using SERVIT.',
            ),
            _section(
              '6. Payments and Fees',
              'Payments are processed through our secure payment gateway. Service fees are displayed before booking confirmation. SERVIT charges a service fee on each transaction. Refunds are subject to our refund policy and may vary based on the circumstances.',
            ),
            _section(
              '7. Cancellation and Refunds',
              'Users may cancel bookings according to the cancellation policy displayed at the time of booking. Refund eligibility depends on the timing of cancellation and the expert\'s policy. SERVIT will facilitate refunds in accordance with our refund policy.',
            ),
            _section(
              '8. Intellectual Property',
              'The SERVIT platform, including its design, logo, and content, is owned by SERVIT and protected by intellectual property laws. You may not reproduce, distribute, or create derivative works without our express written consent.',
            ),
            _section(
              '9. Limitation of Liability',
              'SERVIT is not liable for any indirect, incidental, special, or consequential damages arising from your use of the platform. Our total liability is limited to the amount you have paid to us in the 12 months preceding the claim.',
            ),
            _section(
              '10. Dispute Resolution',
              'Any disputes arising from these terms shall be resolved through binding arbitration in accordance with the laws of India. Both parties agree to attempt informal resolution before pursuing arbitration. The place of arbitration shall be the city of the user\'s state.',
            ),
            _section(
              '11. Termination',
              'We may terminate or suspend your account at any time for violation of these terms or for any other reason at our discretion. Upon termination, your right to use the platform ceases immediately. Provisions that should survive termination will remain in effect.',
            ),
            _section(
              '12. Governing Law',
              'These terms are governed by the laws of India. Any legal actions or proceedings relating to these terms shall be brought exclusively in the courts located in the user\'s respective state jurisdiction.',
            ),
            _section(
              '13. Contact Information',
              'For questions about these terms, please contact us at support@servit.app. You may also reach us through our help center within the app.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
