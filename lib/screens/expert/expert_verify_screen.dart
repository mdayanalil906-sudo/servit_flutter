import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/services/firestore_service.dart';
import 'package:servit_flutter/services/storage_service.dart';

class ExpertVerifyScreen extends StatefulWidget {
  const ExpertVerifyScreen({super.key});

  @override
  State<ExpertVerifyScreen> createState() => _ExpertVerifyScreenState();
}

class _ExpertVerifyScreenState extends State<ExpertVerifyScreen> {
  File? _idProofFile;
  File? _selfieFile;
  bool _isSubmitting = false;

  String _verificationStatus = '';
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final expert = auth.expertProfile;
    if (expert != null) {
      _verificationStatus = expert.verificationStatus;
      _isVerified = expert.isVerified;
    }
  }

  Future<void> _pickIdProof() async {
    final picked = await StorageService.pickImage();
    if (picked != null) {
      setState(() => _idProofFile = File(picked.path));
    }
  }

  Future<void> _pickSelfie() async {
    final picked = await StorageService.captureImage();
    if (picked != null) {
      setState(() => _selfieFile = File(picked.path));
    }
  }

  Future<void> _submitVerification() async {
    if (_idProofFile == null || _selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload both ID proof and selfie'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final auth = context.read<AuthProvider>();
      final expert = auth.expertProfile;
      if (expert == null) return;

      final idProofUrl = await StorageService.uploadFile(
        _idProofFile!,
        'verification/${expert.uid}/id_proof.${_idProofFile!.path.split('.').last}',
      );
      final selfieUrl = await StorageService.uploadFile(
        _selfieFile!,
        'verification/${expert.uid}/selfie.${_selfieFile!.path.split('.').last}',
      );

      await FirestoreService.updateExpertProfile(expert.uid, {
        'verificationStatus': 'pending',
        'idProofUrl': idProofUrl,
        'selfieUrl': selfieUrl,
      });

      await auth.loadExpertProfile();
      if (!mounted) return;
      setState(() {
        _verificationStatus = 'pending';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification documents submitted for review'),
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
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

    final bool notSubmitted = _verificationStatus.isEmpty;
    final bool isPending = _verificationStatus == 'pending';
    final bool isApproved = _isVerified || _verificationStatus == 'approved';
    final bool isRejected = _verificationStatus == 'rejected';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Icon(
                    isApproved
                        ? Icons.verified_rounded
                        : isRejected
                            ? Icons.cancel_rounded
                            : isPending
                                ? Icons.hourglass_empty_rounded
                                : Icons.verified_user_rounded,
                    size: 64,
                    color: isApproved
                        ? AppTheme.success
                        : isRejected
                            ? AppTheme.error
                            : isPending
                                ? AppTheme.warning
                                : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isApproved
                        ? 'Approved'
                        : isRejected
                            ? 'Rejected'
                            : isPending
                                ? 'Pending Review'
                                : 'Not Submitted',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isApproved
                          ? AppTheme.success
                          : isRejected
                              ? AppTheme.error
                              : isPending
                                  ? AppTheme.warning
                                  : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isApproved
                        ? 'Your identity has been verified successfully'
                        : isRejected
                            ? 'Your verification was rejected. Please resubmit.'
                            : isPending
                                ? 'Your documents are being reviewed by admin'
                                : 'Submit your ID proof and selfie to get verified',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (notSubmitted || isRejected) ...[
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
                      'Upload Documents',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _uploadBox(
                      title: 'ID Proof (Aadhaar / PAN / DL)',
                      file: _idProofFile,
                      onPick: _pickIdProof,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _uploadBox(
                      title: 'Selfie Photo',
                      file: _selfieFile,
                      onPick: _pickSelfie,
                      isDark: isDark,
                      useCamera: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitVerification,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : Text(
                                'Submit for Verification',
                                style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isPending)
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Please wait while we review your documents',
                    style: GoogleFonts.nunito(
                      color: AppTheme.warning,
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

  Widget _uploadBox({
    required String title,
    required File? file,
    required VoidCallback onPick,
    required bool isDark,
    bool useCamera = false,
  }) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.borderDark : AppTheme.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppTheme.success : AppTheme.borderLight,
            style: file != null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
              color: file != null ? AppTheme.success : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.textDarkMode : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    file != null
                        ? file.path.split('/').last
                        : useCamera
                            ? 'Tap to take a selfie'
                            : 'Tap to upload file',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
