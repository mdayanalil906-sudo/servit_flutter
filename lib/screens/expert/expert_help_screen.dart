import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/utils/constants.dart';
import 'package:servit_flutter/widgets/faq_widget.dart';

class ExpertHelpScreen extends StatelessWidget {
  const ExpertHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            ...Constants.expertFaqs.map((faq) => FaqWidget(
                  question: faq['q'] as String,
                  answer: faq['a'] as String,
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/expert/chat-support');
                },
                icon: const Icon(Icons.chat_rounded),
                label: Text(
                  'Chat with AI Support',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
}
