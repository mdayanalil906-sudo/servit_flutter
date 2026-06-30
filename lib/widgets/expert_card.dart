import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/expert.dart';
import 'star_rating.dart';

class ExpertCard extends StatelessWidget {
  final ExpertProfile expert;
  final VoidCallback? onTap;

  const ExpertCard({super.key, required this.expert, this.onTap});

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
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 4),
                    _buildCategory(),
                    const SizedBox(height: 6),
                    _buildMeta(),
                    const SizedBox(height: 8),
                    _buildBottomRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage: expert.avatarUrl != null
              ? NetworkImage(expert.avatarUrl!)
              : null,
          child: expert.avatarUrl == null
              ? Icon(Icons.person, size: 30, color: Colors.grey[400])
              : null,
        ),
        if (expert.isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            expert.name,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (expert.isVerified)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.verified_rounded,
                    size: 16, color: AppTheme.success),
              ),
            if (expert.isPremium)
              Icon(Icons.star_rounded, size: 16, color: AppTheme.elite),
          ],
        ),
      ],
    );
  }

  Widget _buildCategory() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        expert.category ?? 'General',
        style: GoogleFonts.nunito(
          fontSize: 11,
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        StarRating(rating: expert.rating, size: 14, readonly: true),
        const SizedBox(width: 4),
        Text(
          '${expert.rating.toStringAsFixed(1)}',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${expert.reviewCount})',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 13, color: Colors.grey[500]),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            [expert.district, expert.state]
                .whereType<String>()
                .join(', '),
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: Colors.grey[500],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '₹${expert.minPrice} - ₹${expert.maxPrice}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}
