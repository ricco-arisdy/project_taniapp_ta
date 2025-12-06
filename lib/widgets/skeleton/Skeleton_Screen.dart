import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonScreen extends StatelessWidget {
  final SkeletonType type;
  final int itemCount;

  const SkeletonScreen({
    Key? key,
    required this.type,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SkeletonType.home:
        return _buildHomeSkeleton();
      case SkeletonType.kebun:
        return _buildKebunSkeleton();
      case SkeletonType.card:
        return _buildCardSkeleton();
      case SkeletonType.list:
        return _buildListSkeleton();
      case SkeletonType.detail:
        return _buildDetailSkeleton();
    }
  }

  Widget _buildHomeSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Skeleton
        _buildHeaderSkeleton(),
        const SizedBox(height: 20),

        // Summary Card Skeleton
        _buildSummaryCardSkeleton(),
        const SizedBox(height: 20),

        // Quick Actions Skeleton
        _buildQuickActionsSkeleton(),
        const SizedBox(height: 20),

        // Recent Items Skeleton
        _buildRecentItemsSkeleton(),
      ],
    );
  }

  Widget _buildKebunSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Skeleton
        _buildHeaderSkeleton(),
        const SizedBox(height: 20),

        // Search Skeleton
        _buildSearchSkeleton(),
        const SizedBox(height: 20),

        // Statistics Card Skeleton
        _buildStatisticsSkeleton(),
        const SizedBox(height: 20),

        // kebun List Skeleton
        _buildKebunListSkeleton(),
      ],
    );
  }

  Widget _buildCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _buildShimmerBox(height: 120),
      ),
    );
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 18, right: 18),
          child: _buildShimmerBox(height: 80),
        ),
      ),
    );
  }

  Widget _buildDetailSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(height: 200), // Image placeholder
          const SizedBox(height: 16),
          _buildShimmerBox(height: 24, width: 200), // Title
          const SizedBox(height: 8),
          _buildShimmerBox(height: 16, width: 150), // Subtitle
          const SizedBox(height: 20),
          _buildShimmerBox(height: 100), // Description
          const SizedBox(height: 20),
          _buildShimmerBox(height: 60), // Action buttons
        ],
      ),
    );
  }

  // Helper methods for specific skeleton parts
  Widget _buildHeaderSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
      child: Row(
        children: [
          _buildShimmerCircle(radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(height: 18, width: 150),
                const SizedBox(height: 4),
                _buildShimmerBox(height: 14, width: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: _buildShimmerBox(height: 48),
    );
  }

  Widget _buildSummaryCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItemSkeleton(),
                _buildStatItemSkeleton(),
                _buildStatItemSkeleton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItemSkeleton(),
            _buildStatItemSkeleton(),
            _buildStatItemSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItemSkeleton() {
    return Column(
      children: [
        _buildShimmerCircle(radius: 10),
        const SizedBox(height: 8),
        _buildShimmerBox(height: 16, width: 40),
        const SizedBox(height: 4),
        _buildShimmerBox(height: 12, width: 60),
      ],
    );
  }

  Widget _buildQuickActionsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(height: 20, width: 120),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 80)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 80)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 80)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 80)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(height: 18, width: 100),
          const SizedBox(height: 12),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildShimmerBox(height: 60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKebunListSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildShimmerBox(height: 60, width: 60),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildShimmerBox(height: 16, width: 120),
                        const SizedBox(height: 4),
                        _buildShimmerBox(height: 14, width: 80),
                        const SizedBox(height: 8),
                        _buildShimmerBox(height: 12, width: 100),
                      ],
                    ),
                  ),
                  _buildShimmerBox(height: 24, width: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Base shimmer widgets
  Widget _buildShimmerBox({
    required double height,
    double? width,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildShimmerCircle({required double radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
      ),
    );
  }
}

enum SkeletonType {
  home,
  kebun,
  card,
  list,
  detail,
}
