import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/empty_state.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _tabs = const [
    {'key': 'all', 'label': 'All'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'active', 'label': 'Active'},
    {'key': 'completed', 'label': 'Completed'},
    {'key': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tab = _tabs[_tabController.index]['key']!;
        context.read<BookingProvider>().setActiveUserTab(tab);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer<BookingProvider>(
            builder: (context, bp, _) {
              return TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textLight,
                labelStyle: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.nunito(
                    fontWeight: FontWeight.w500, fontSize: 13),
                tabs: _tabs.map((t) {
                  final count = bp.countByStatus(t['key']!);
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t['label']!),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bp, _) {
          return TabBarView(
            controller: _tabController,
            children: _tabs.map((t) {
              final bookings = bp.filteredUserBookings;
              if (bookings.isEmpty) {
                return _buildEmptyState(t['label']!);
              }
              return RefreshIndicator(
                onRefresh: () async {
                  bp.subscribeUserBookings();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return BookingCard(
                      booking: booking,
                      onTap: () {
                        Navigator.pushNamed(
                            context, '/booking-detail',
                            arguments: booking.id);
                      },
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String tabLabel) {
    final iconMap = {
      'all': Icons.calendar_today_rounded,
      'pending': Icons.hourglass_empty_rounded,
      'active': Icons.engineering_rounded,
      'completed': Icons.check_circle_outline_rounded,
      'cancelled': Icons.cancel_outlined,
    };
    final messageMap = {
      'all': 'No bookings yet',
      'pending': 'No pending bookings',
      'active': 'No active bookings',
      'completed': 'No completed bookings',
      'cancelled': 'No cancelled bookings',
    };
    return EmptyState(
      icon: iconMap[tabLabel.toLowerCase()] ??
          Icons.calendar_today_rounded,
      message: messageMap[tabLabel.toLowerCase()] ?? 'No bookings',
      subtitle: 'Your $tabLabel bookings will appear here',
    );
  }
}
