import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme.dart';
import '../../models/rating.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/empty_state.dart';
import '../../utils/helpers.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('My Ratings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: uid == null
          ? Center(child: Text('Please login', style: GoogleFonts.nunito(color: AppTheme.textLight)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.ratings()
                  .where('userId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong', style: GoogleFonts.nunito(color: AppTheme.textLight)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const EmptyState(
                    icon: Icons.star_outline_rounded,
                    message: 'No ratings yet',
                    subtitle: 'Your ratings for completed services will appear here',
                  );
                }
                final ratings = docs.map((doc) => Rating.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ratings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rating = ratings[index];
                    return _RatingCard(rating: rating);
                  },
                );
              },
            ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final Rating rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  rating.userName.isNotEmpty ? rating.userName[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.userName.isNotEmpty ? rating.userName : 'Expert',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    if (rating.category.isNotEmpty)
                      Text(
                        rating.category,
                        style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.textLight),
                      ),
                  ],
                ),
              ),
              StarRating(rating: rating.stars.toDouble(), size: 16, readonly: true),
            ],
          ),
          if (rating.review.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              rating.review,
              style: GoogleFonts.nunito(fontSize: 13, color: AppTheme.textLight, height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            formatDate(rating.createdAt),
            style: GoogleFonts.nunito(fontSize: 11, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }
}
