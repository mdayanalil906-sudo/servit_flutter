import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/helpers.dart';

class ExpertOrdersScreen extends StatefulWidget {
  const ExpertOrdersScreen({super.key});

  @override
  State<ExpertOrdersScreen> createState() => _ExpertOrdersScreenState();
}

class _ExpertOrdersScreenState extends State<ExpertOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().subscribeExpertBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bp, _) {
          final isDark = context.watch<ThemeProvider>().isDark;
          final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
          final textColor = isDark ? AppTheme.textDarkMode : AppTheme.textDark;

          final tabs = ['all', 'pending', 'active', 'completed', 'cancelled'];
          final selected = bp.activeExpertTab;

          return Column(
            children: [
              Container(
                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: tabs.map((tab) {
                      final isSelected = selected == tab;
                      final count = tab == 'all'
                          ? bp.expertBookings.length
                          : bp.expertCountByStatus(tab);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tab[0].toUpperCase() + tab.substring(1),
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.grey,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: GoogleFonts.nunito(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          selected: isSelected,
                          backgroundColor:
                              isDark ? AppTheme.cardDark : AppTheme.bgLight,
                          selectedColor:
                              AppTheme.primary.withValues(alpha: 0.1),
                          checkmarkColor: AppTheme.primary,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primary
                                : (isDark
                                    ? AppTheme.borderDark
                                    : AppTheme.borderLight),
                          ),
                          onSelected: (_) => bp.setActiveExpertTab(tab),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: bp.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : bp.filteredExpertBookings.isEmpty
                        ? _emptyState(selected, textColor)
                        : RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<BookingProvider>()
                                  .subscribeExpertBookings();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: bp.filteredExpertBookings.length,
                              itemBuilder: (context, index) {
                                final booking = bp.filteredExpertBookings[index];
                                return _BookingCard(
                                  booking: booking,
                                  isDark: isDark,
                                  textColor: textColor,
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(String tab, Color textColor) {
    IconData icon;
    String msg;
    switch (tab) {
      case 'pending':
        icon = Icons.hourglass_empty_rounded;
        msg = 'No pending orders';
        break;
      case 'active':
        icon = Icons.work_rounded;
        msg = 'No active orders';
        break;
      case 'completed':
        icon = Icons.check_circle_outline_rounded;
        msg = 'No completed orders';
        break;
      case 'cancelled':
        icon = Icons.cancel_outlined;
        msg = 'No cancelled orders';
        break;
      default:
        icon = Icons.inbox_rounded;
        msg = 'No orders yet';
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            msg,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  final bool isDark;
  final Color textColor;

  const _BookingCard({
    required this.booking,
    required this.isDark,
    required this.textColor,
  });

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
    final status = booking.status ?? 'pending';
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/expert/order-detail',
            arguments: booking.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.userName ?? 'Customer',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        booking.category ?? '',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  booking.bookingDate ?? '',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  booking.bookingTime ?? '',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if ((booking.estimatedPriceMin ?? 0) > 0 ||
                (booking.estimatedPriceMax ?? 0) > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.currency_rupee_rounded,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '₹${booking.estimatedPriceMin} - ₹${booking.estimatedPriceMax}',
                    style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
