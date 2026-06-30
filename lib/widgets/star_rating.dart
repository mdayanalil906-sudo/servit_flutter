import 'package:flutter/material.dart';
import '../config/theme.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool readonly;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 20,
    this.readonly = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readonly
          ? null
          : () {
              if (onRatingChanged != null) {
                _showRatingPicker(context);
              }
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          final starIndex = index + 1;
          final isFull = rating >= starIndex;
          final isHalf = !isFull && rating >= starIndex - 0.5;

          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              isFull
                  ? Icons.star_rounded
                  : isHalf
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: size,
              color: AppTheme.gold,
            ),
          );
        }),
      ),
    );
  }

  void _showRatingPicker(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          title: const Text('Rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setDialogState) {
                  double tempRating = rating;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => tempRating = starIndex.toDouble());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            tempRating >= starIndex
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 36,
                            color: AppTheme.gold,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
