import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
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
              'Privacy Policy',
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
              '1. Introduction',
              'Welcome to SERVIT. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, disclose, and safeguard your information when you use our platform.',
            ),
            _section(
              '2. Information We Collect',
              'We collect information you provide directly, such as your name, email address, phone number, and location data. We also automatically collect certain information when you use the platform, including device information, usage data, and cookies.',
            ),
            _section(
              '3. How We Use Your Information',
              'We use your information to provide, maintain, and improve our services; to process transactions; to send you technical notices and support messages; to communicate with you about products and services; and to monitor and analyze trends and usage.',
            ),
            _section(
              '4. Data Sharing and Disclosure',
              'We do not sell your personal information. We may share your data with service providers who perform services on our behalf, when required by law, or in connection with a business transfer. Experts on the platform may see your name and contact information when you book a service.',
            ),
            _section(
              '5. Data Security',
              'We implement appropriate technical and organizational security measures to protect your personal data. However, no method of transmission over the Internet is 100% secure, and we cannot guarantee absolute security.',
            ),
            _section(
              '6. Your Rights',
              'You have the right to access, update, or delete your personal information. You can object to processing of your data, request data portability, and withdraw consent at any time. Contact us to exercise these rights.',
            ),
            _section(
              '7. Data Retention',
              'We retain your personal information for as long as your account is active or as needed to provide you services. We will retain and use your information as necessary to comply with legal obligations, resolve disputes, and enforce our agreements.',
            ),
            _section(
              '8. Third-Party Services',
              'Our platform may contain links to third-party websites and services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies before providing any personal data.',
            ),
            _section(
              '9. Children\'s Privacy',
              'Our services are not directed to individuals under the age of 18. We do not knowingly collect personal information from children. If we become aware that a child has provided us with personal data, we will take steps to delete such information.',
            ),
            _section(
              '10. Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last updated" date. Your continued use of the platform after changes constitutes acceptance.',
            ),
            _section(
              '11. Contact Us',
              'If you have questions about this privacy policy, please contact us at support@servit.app or through the app\'s help section.',
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
