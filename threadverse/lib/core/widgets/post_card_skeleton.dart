import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder for post cards while loading.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surfaceContainerHighest;
    final placeholderColor = surface.withOpacity(0.7);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Shimmer.fromColors(
        baseColor: surface.withOpacity(0.6),
        highlightColor: surface.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _block(width: 28, height: 28, radius: 14, color: placeholderColor),
                  const SizedBox(width: 8),
                  _block(width: 80, height: 10, color: placeholderColor),
                  const SizedBox(width: 8),
                  _block(width: 60, height: 10, color: placeholderColor),
                  const Spacer(),
                  _block(width: 20, height: 20, radius: 6, color: placeholderColor),
                ],
              ),
              const SizedBox(height: 12),
              _block(width: double.infinity, height: 14, color: placeholderColor),
              const SizedBox(height: 8),
              _block(width: double.infinity, height: 12, color: placeholderColor),
              const SizedBox(height: 8),
              _block(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 12,
                color: placeholderColor,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _block(
                  width: double.infinity,
                  height: 160,
                  color: placeholderColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _pill(width: 96, color: placeholderColor),
                  const SizedBox(width: 8),
                  _pill(width: 88, color: placeholderColor),
                  const SizedBox(width: 8),
                  _pill(width: 72, color: placeholderColor),
                  const Spacer(),
                  _block(width: 20, height: 20, radius: 6, color: placeholderColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _block({
    required double width,
    required double height,
    double radius = 8,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _pill({required double width, required Color color}) {
    return _block(width: width, height: 28, radius: 14, color: color);
  }
}
