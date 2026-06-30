import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class StatusPill extends StatelessWidget {
  final String status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusConfig(
          backgroundColor: AppTheme.warning.withOpacity(0.12),
          borderColor: AppTheme.warning.withOpacity(0.3),
          textColor: AppTheme.warning,
          dotColor: AppTheme.warning,
        );
      case 'active':
      case 'confirmed':
        return _StatusConfig(
          backgroundColor: AppTheme.success.withOpacity(0.12),
          borderColor: AppTheme.success.withOpacity(0.3),
          textColor: AppTheme.success,
          dotColor: AppTheme.success,
        );
      case 'completed':
        return _StatusConfig(
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.12),
          borderColor: const Color(0xFF2196F3).withOpacity(0.3),
          textColor: const Color(0xFF2196F3),
          dotColor: const Color(0xFF2196F3),
        );
      case 'cancelled':
      case 'rejected':
        return _StatusConfig(
          backgroundColor: AppTheme.error.withOpacity(0.12),
          borderColor: AppTheme.error.withOpacity(0.3),
          textColor: AppTheme.error,
          dotColor: AppTheme.error,
        );
      default:
        return _StatusConfig(
          backgroundColor: Colors.grey[100]!,
          borderColor: Colors.grey[300]!,
          textColor: Colors.grey[600]!,
          dotColor: Colors.grey[500]!,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color dotColor;

  const _StatusConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.dotColor,
  });
}
