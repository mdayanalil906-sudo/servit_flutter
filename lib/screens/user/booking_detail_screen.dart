import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_pill.dart';
import '../../utils/helpers.dart';
import 'booking_chat_screen.dart';
import 'track_expert_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isCancelling = false;

  Booking? get _booking {
    final provider = context.read<BookingProvider>();
    final all = provider.userBookings;
    try {
      return all.firstWhere((b) => b.id == widget.bookingId || b.bookingId == widget.bookingId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Booking', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to cancel this booking?', style: GoogleFonts.nunito()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _isCancelling = true);
    final success = await context.read<BookingProvider>().updateStatus(
      booking.id,
      'cancelled',
      {'cancelledBy': 'user', 'updatedAt': DateTime.now().toIso8601String()},
    );
    setState(() => _isCancelling = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking cancelled', style: GoogleFonts.nunito())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Booking Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bp, _) {
          final booking = _booking;
          if (booking == null) {
            return Center(
              child: Text('Loading...', style: GoogleFonts.nunito(color: AppTheme.textLight)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => bp.subscribeUserBookings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(booking),
                  const SizedBox(height: 16),
                  _buildExpertCard(booking),
                  const SizedBox(height: 16),
                  _buildDetailCard(booking),
                  const SizedBox(height: 16),
                  _buildProblemCard(booking),
                  const SizedBox(height: 16),
                  _buildActionButtons(booking),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            booking.status == 'pending'
                ? AppTheme.warning
                : booking.status == 'active'
                    ? AppTheme.success
                    : booking.status == 'completed'
                        ? const Color(0xFF2196F3)
                        : AppTheme.error,
            AppTheme.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Booking ID', style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
              Text(
                '#${booking.bookingId.length > 8 ? booking.bookingId.substring(0, 8).toUpperCase() : booking.bookingId}',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking.status[0].toUpperCase() + booking.status.substring(1),
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            booking.status == 'pending'
                ? 'Awaiting confirmation'
                : booking.status == 'active'
                    ? 'Expert is on the way'
                    : booking.status == 'completed'
                        ? 'Service completed'
                        : 'Booking was cancelled',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            child: Text(
              getInitials(booking.expertName),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.expertName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(booking.category, style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textLight)),
              ],
            ),
          ),
          if (booking.expertUid.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone_rounded, color: AppTheme.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${booking.expertName}...', style: GoogleFonts.nunito())),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          _detailRow(Icons.calendar_today_rounded, 'Date', booking.bookingDate),
          const SizedBox(height: 8),
          _detailRow(Icons.access_time_rounded, 'Time', booking.bookingTime),
          const SizedBox(height: 8),
          _detailRow(Icons.category_outlined, 'Category', booking.category),
          if (booking.customerLocation.isNotEmpty) ...[
            const SizedBox(height: 8),
            _detailRow(Icons.location_on_rounded, 'Address', booking.customerLocation['address'] ?? 'Address provided'),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(label, style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textLight)),
        ),
        Expanded(
          child: Text(value.isNotEmpty ? value : 'N/A', style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildProblemCard(Booking booking) {
    if (booking.problemDescription.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Problem Description', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text(booking.problemDescription, style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textLight, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Booking booking) {
    if (booking.status == 'pending') {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: _isCancelling ? null : () => _cancelBooking(booking),
          icon: _isCancelling
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.cancel_outlined),
          label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Booking', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
        ),
      );
    }
    if (booking.status == 'active') {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TrackExpertScreen(bookingId: booking.id),
                  ));
                },
                icon: const Icon(Icons.navigation_rounded),
                label: Text('Track', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BookingChatScreen(
                      bookingId: booking.id,
                      expertName: booking.expertName,
                      expertId: booking.expertUid,
                      roomId: '${booking.userId}_${booking.expertUid}',
                    ),
                  ));
                },
                icon: const Icon(Icons.chat_rounded),
                label: Text('Chat', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (booking.status == 'completed') {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Rate your experience with ${booking.expertName}', style: GoogleFonts.nunito())),
            );
          },
          icon: const Icon(Icons.star_rounded),
          label: Text('Rate Service', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
