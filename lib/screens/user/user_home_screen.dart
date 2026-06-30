import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/expert_card.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../shared/search_results_screen.dart';
import 'user_bookings_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    UserBookingsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online_rounded), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().subscribeUserBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<SearchProvider>().search();
    context.read<BookingProvider>().subscribeUserBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              _buildSearchBar(),
              const SizedBox(height: 8),
              _buildCategorySection(),
              const SizedBox(height: 8),
              _buildTopExpertsSection(),
              const SizedBox(height: 8),
              _buildRecentBookingsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.userProfile;
        final name = user?.name ?? 'User';
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary,
                AppTheme.primaryDark,
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $name 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            user?.district ?? 'Your Location',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white24,
                    backgroundImage: user?.profilePhoto != null &&
                            user!.profilePhoto.isNotEmpty
                        ? NetworkImage(user.profilePhoto)
                        : null,
                    child: user?.profilePhoto == null ||
                            (user?.profilePhoto ?? '').isEmpty
                        ? Icon(Icons.person_rounded,
                            size: 28, color: Colors.white70)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Search for services...',
            hintStyle: GoogleFonts.nunito(
              fontSize: 14,
              color: AppTheme.textLight,
            ),
            prefixIcon: Icon(Icons.search_rounded,
                color: AppTheme.primary, size: 22),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: Colors.white, size: 18),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SearchResultsScreen(query: _searchController.text),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All',
                        style: GoogleFonts.nunito(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            CategoryGrid(
              categories: searchProvider.categories,
              onCategoryTap: (cat) {
                context.read<SearchProvider>().setCategory(cat.name);
                context.read<SearchProvider>().search();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchResultsScreen(query: cat.name),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopExpertsSection() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, _) {
        final experts = searchProvider.searchResults;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Experts',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('See All',
                        style: GoogleFonts.nunito(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (experts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('No experts available',
                    style: GoogleFonts.nunito(color: AppTheme.textLight)),
              )
            else
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: experts.length > 8 ? 8 : experts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final expert = experts[index];
                    return SizedBox(
                      width: 200,
                      child: ExpertCard(
                        expert: expert,
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/expert-detail',
                              arguments: expert);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRecentBookingsSection() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        final bookings = bookingProvider.userBookings;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Bookings',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final parent = context
                          .findAncestorStateOfType<_UserHomeScreenState>();
                      parent?.setState(() => parent._currentIndex = 1);
                    },
                    child: Text('See All',
                        style: GoogleFonts.nunito(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (bookings.isEmpty)
              EmptyState(
                icon: Icons.calendar_today_rounded,
                message: 'No bookings yet',
                subtitle: 'Book a service to get started',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bookings.length > 3 ? 3 : bookings.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingCard(
                    booking: booking,
                    onTap: () {
                      Navigator.pushNamed(context, '/booking-detail',
                          arguments: booking.id);
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
