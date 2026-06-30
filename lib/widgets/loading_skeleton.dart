import 'package:flutter/material.dart';
import '../config/theme.dart';

class LoadingSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final LoadingSkeletonType type;
  final int itemCount;

  const LoadingSkeleton({
    super.key,
    this.width,
    this.height,
    this.type = LoadingSkeletonType.card,
    this.itemCount = 5,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildSkeleton();
      },
    );
  }

  Widget _buildSkeleton() {
    switch (widget.type) {
      case LoadingSkeletonType.card:
        return _buildCardSkeleton();
      case LoadingSkeletonType.list:
        return _buildListSkeleton();
      case LoadingSkeletonType.circle:
        return _buildCircleSkeleton();
      case LoadingSkeletonType.text:
        return _buildTextSkeleton();
    }
  }

  Widget _buildShimmerOverlay(Widget child) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.4),
            Colors.transparent,
          ],
          stops: [
            _animation.value.clamp(0.0, 1.0) - 0.3,
            _animation.value.clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0) + 0.3,
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }

  Widget _buildCardSkeleton() {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildShimmerOverlay(
            Container(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 100,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity * 0.6,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity * 0.4,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity * 0.5,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[350],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _buildShimmerOverlay(
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity * 0.5,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity * 0.3,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCircleSkeleton() {
    return _buildShimmerOverlay(
      Container(
        width: widget.width ?? 80,
        height: widget.height ?? 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTextSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerOverlay(
          Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildShimmerOverlay(
          Container(
            width: (widget.width ?? double.infinity) * 0.8,
            height: widget.height ?? 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

enum LoadingSkeletonType { card, list, circle, text }
