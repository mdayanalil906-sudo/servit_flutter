import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:servit_flutter/config/theme.dart';
import 'package:servit_flutter/models/booking.dart';
import 'package:servit_flutter/providers/auth_provider.dart';
import 'package:servit_flutter/providers/booking_provider.dart';
import 'package:servit_flutter/providers/theme_provider.dart';
import 'package:servit_flutter/services/firestore_service.dart';
import 'package:servit_flutter/utils/helpers.dart';

class ExpertOrderDetailScreen extends StatefulWidget {
  final String bookingId;

  const ExpertOrderDetailScreen({super.key, required this.bookingId});

  @override
  State<ExpertOrderDetailScreen> createState() =>
      _ExpertOrderDetailScreenState();
}

class _ExpertOrderDetailScreenState extends State<ExpertOrderDetailScreen> {
  Booking? _booking;

  @override
  void initState() {
    super.initState();
    _findBooking();
  }

  void _findBooking() {
    final bp = context.read<BookingProvider>();
    final bookings = bp.expertBookings;
    for (final b in bookings) {
      if (b.bookingId == widget.bookingId || b.id == widget.bookingId) {
        _booking = b;
        return;
      }
    }
  }

  Future<void> _acceptBooking() async {
    if (_booking == null) return;
    final auth = context.read<AuthProvider>();
    final expert = auth.expertProfile;
    if (expert == null) return;
    final success = await context
        .read<BookingProvider>()
        .updateStatus(_booking!.id, 'active', {
      'expertUid': expert.uid,
      'expertName': expert.name,
      'expertId': expert.expertId,
    });
    if (!mounted) return;
    if (success) {
      await FirestoreService.sendNotification(
        userId: _booking!.userId,
        title: 'Booking Accepted',
        body: '${expert.name} has accepted your booking.',
      );
      setState(() {
        _booking?.status = 'active';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking accepted successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _rejectBooking() async {
    if (_booking == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject Booking',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to reject this booking?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Reject', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await context
        .read<BookingProvider>()
        .updateStatus(_booking!.id, 'cancelled', null);
    if (!mounted) return;
    if (success) {
      await FirestoreService.sendNotification(
        userId: _booking!.userId,
        title: 'Booking Rejected',
        body: 'Your booking has been rejected by the expert.',
      );
      setState(() {
        _booking?.status = 'cancelled';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking rejected'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _completeJob() async {
    if (_booking == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Complete Job',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Mark this job as completed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Complete',
                  style: TextStyle(color: AppTheme.success))),
        ],
      ),
    );
    if (confirm != true) return;
    final success = await context
        .read<BookingProvider>()
        .updateStatus(_booking!.id, 'completed', null);
    if (!mounted) return;
    if (success) {
      setState(() {
        _booking?.status = 'completed';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job marked as completed'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warning;
      case 'active':
        return AppTheme.primary;
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final cardColor = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

    if (_booking == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(title: Text('Order Detail')),
        body: Center(
          child: Text('Booking not found',
              style: GoogleFonts.nunito(color: Colors.grey)),
        ),
      );
    }

    final b = _booking!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Order Detail'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor(b.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              b.status[0].toUpperCase() + b.status.substring(1),
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _statusColor(b.status),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.person_rounded,
                        size: 32, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    b.userName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Details',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  const SizedBox(height: 12),
                  _infoRow(Icons.person_rounded, 'Name', b.userName),
                  if (b.customerLocation['phone'] != null)
                    _infoRow(
                        Icons.phone_rounded, 'Phone', b.customerLocation['phone']),
                  if (b.customerLocation['address'] != null)
                    _infoRow(Icons.location_on_rounded, 'Address',
                        b.customerLocation['address']),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Details',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  const SizedBox(height: 12),
                  _infoRow(Icons.category_rounded, 'Category', b.category),
                  _infoRow(Icons.calendar_today_rounded, 'Date', b.bookingDate),
                  _infoRow(Icons.access_time_rounded, 'Time', b.bookingTime),
                  if (b.problemDescription.isNotEmpty)
                    _infoRow(Icons.description_rounded, 'Problem',
                        b.problemDescription),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pricing',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  const SizedBox(height: 12),
                  if (b.estimatedPriceMin > 0 || b.estimatedPriceMax > 0)
                    _infoRow(
                      Icons.currency_rupee_rounded,
                      'Estimated Price',
                      '₹${b.estimatedPriceMin.toStringAsFixed(0)} - ₹${b.estimatedPriceMax.toStringAsFixed(0)}',
                    ),
                  if (b.finalPrice > 0)
                    _infoRow(Icons.payments_rounded, 'Final Price',
                        '₹${b.finalPrice.toStringAsFixed(0)}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (b.status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _acceptBooking,
                        icon: const Icon(Icons.check_rounded),
                        label: Text('Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _rejectBooking,
                        icon: const Icon(Icons.close_rounded),
                        label: Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (b.status == 'active') ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _completeJob,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text('Complete Job'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/expert/booking-chat',
                            arguments: {
                              'bookingId': b.bookingId,
                              'roomId':
                                  '${b.bookingId}_chat',
                              'userId': b.userId,
                              'userName': b.userName,
                            },
                          );
                        },
                        icon: const Icon(Icons.chat_rounded),
                        label: Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (b.status == 'completed' || b.status == 'cancelled')
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _statusColor(b.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    b.status == 'completed'
                        ? 'This job has been completed'
                        : 'This booking was cancelled',
                    style: GoogleFonts.nunito(
                      color: _statusColor(b.status),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.watch<ThemeProvider>().isDark
                    ? AppTheme.textDarkMode
                    : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
