import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../models/expert.dart';
import '../../widgets/star_rating.dart';

class ExpertDetailScreen extends StatelessWidget {
  final ExpertProfile expert;

  const ExpertDetailScreen({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildBody(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_rounded,
              size: 18, color: AppTheme.textDark),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white24,
                  backgroundImage: expert.avatarUrl != null
                      ? NetworkImage(expert.avatarUrl!)
                      : null,
                  child: expert.avatarUrl == null
                      ? Icon(Icons.person, size: 48, color: Colors.white.withOpacity(0.7))
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  expert.name,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                StarRating(
                  rating: expert.rating,
                  size: 18,
                  readonly: true,
                ),
                const SizedBox(height: 4),
                Text(
                  '${expert.rating.toStringAsFixed(1)} (${expert.reviewCount} reviews)',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (expert.isVerified)
                      _Badge(
                        label: 'Verified',
                        color: AppTheme.success,
                        icon: Icons.verified_rounded,
                      ),
                    if (expert.isPremium)
                      _Badge(
                        label: 'Premium',
                        color: AppTheme.elite,
                        icon: Icons.star_rounded,
                      ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildInfoRow(),
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          const SizedBox(height: 8),
          _buildAboutSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Services & Pricing'),
          const SizedBox(height: 8),
          _buildPricingSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Location'),
          const SizedBox(height: 8),
          _buildLocationSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _InfoChip(
            icon: Icons.category_outlined,
            label: expert.category,
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.work_outline,
            label: '${expert.experienceYears} yrs exp',
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.currency_rupee_rounded,
            label: '₹${expert.minPrice} - ₹${expert.maxPrice}',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          expert.description ?? 'No description provided.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _PricingRow(
              service: 'Basic Consultation',
              price: '₹${expert.minPrice}',
            ),
            const Divider(height: 24),
            _PricingRow(
              service: 'Standard Service',
              price: '₹${((expert.minPrice + expert.maxPrice) / 2).round()}',
            ),
            const Divider(height: 24),
            _PricingRow(
              service: 'Premium Service',
              price: '₹${expert.maxPrice}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (expert.state != null || expert.district != null)
                    Text(
                      [expert.district, expert.state]
                          .whereType<String>()
                          .join(', '),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (expert.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      expert.address!,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/booking', arguments: expert);
            },
            icon: const Icon(Icons.calendar_today_rounded, size: 20),
            label: Text(
              'Book Now',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  final String service;
  final String price;

  const _PricingRow({required this.service, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          service,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          price,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
