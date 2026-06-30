import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';

class TrackExpertScreen extends StatefulWidget {
  final String bookingId;

  const TrackExpertScreen({super.key, required this.bookingId});

  @override
  State<TrackExpertScreen> createState() => _TrackExpertScreenState();
}

class _TrackExpertScreenState extends State<TrackExpertScreen> {
  final List<Map<String, dynamic>> _steps = [
    {'label': 'Pending', 'status': 'pending', 'icon': Icons.receipt_long_rounded},
    {'label': 'Accepted', 'status': 'accepted', 'icon': Icons.check_circle_outline_rounded},
    {'label': 'Arrived', 'status': 'arrived', 'icon': Icons.location_on_rounded},
    {'label': 'Working', 'status': 'working', 'icon': Icons.build_rounded},
    {'label': 'Completed', 'status': 'completed', 'icon': Icons.done_all_rounded},
  ];

  int _getCurrentStepIndex(String trackingStatus) {
    final index = _steps.indexWhere((s) => s['status'] == trackingStatus);
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Track Expert', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bp, _) {
          Booking? booking;
          try {
            booking = bp.userBookings.firstWhere(
              (b) => b.id == widget.bookingId || b.bookingId == widget.bookingId,
            );
          } catch (_) {}

          if (booking == null) {
            return Center(
              child: Text('Loading...', style: GoogleFonts.nunito(color: AppTheme.textLight)),
            );
          }

          final currentStep = _getCurrentStepIndex(booking.trackingStatus);

          return RefreshIndicator(
            onRefresh: () async => bp.subscribeUserBookings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildETAHeader(booking),
                  const SizedBox(height: 24),
                  _buildMapPlaceholder(),
                  const SizedBox(height: 24),
                  Text('Service Status', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                  const SizedBox(height: 16),
                  _buildStatusFlow(currentStep),
                  const SizedBox(height: 24),
                  _buildExpertInfo(booking),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildETAHeader(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimated Arrival', style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text('15-20 min', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.navigation_rounded, size: 32, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_car_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text('Approximately 3.2 km away', style: GoogleFonts.nunito(fontSize: 13, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_rounded, size: 30, color: AppTheme.primary),
          ),
          const SizedBox(height: 12),
          Text('Live Map', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text('Map integration requires native setup', style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textLight)),
        ],
      ),
    );
  }

  Widget _buildStatusFlow(int currentStep) {
    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isCompleted = index <= currentStep;
        final isCurrent = index == currentStep;
        final isLast = index == _steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppTheme.primary : AppTheme.borderLight,
                        border: isCurrent ? Border.all(color: AppTheme.primary, width: 3) : null,
                        boxShadow: isCurrent
                            ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8)]
                            : [],
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 16,
                        color: isCompleted ? Colors.white : AppTheme.textLight,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isCompleted ? AppTheme.primary : AppTheme.borderLight,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 32,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          step['label'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCompleted ? AppTheme.primary : AppTheme.textLight,
                          ),
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'In progress',
                          style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textLight),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildExpertInfo(Booking booking) {
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
          Text('Expert Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  (booking.expertName.isNotEmpty ? booking.expertName[0] : '?').toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.expertName, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 2),
                    Text(booking.category, style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textLight)),
                  ],
                ),
              ),
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
        ],
      ),
    );
  }
}
