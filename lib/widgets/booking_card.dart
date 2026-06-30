import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/booking.dart';
import 'status_pill.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;

  const BookingCard({super.key, required this.booking, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDetails(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage: booking.avatarUrl != null
                    ? NetworkImage(booking.avatarUrl!)
                    : null,
                child: booking.avatarUrl == null
                    ? Icon(Icons.person, size: 20, color: Colors.grey[400])
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.partnerName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        StatusPill(status: booking.status),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        _DetailRow(
          icon: Icons.category_outlined,
          label: booking.category ?? 'Service',
        ),
        const SizedBox(height: 6),
        _DetailRow(
          icon: Icons.calendar_today_rounded,
          label: _formatDate(booking.createdAt),
        ),
        const SizedBox(height: 6),
        _DetailRow(
          icon: Icons.currency_rupee_rounded,
          label: '₹${booking.price.toStringAsFixed(0)}',
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(Icons.access_time_rounded, size: 13, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          _formatDate(booking.scheduledAt),
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        const Spacer(),
        Text(
          'Tap for details',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 16, color: AppTheme.primary),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
