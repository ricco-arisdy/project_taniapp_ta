import 'package:flutter/material.dart';
import 'skeleton_card.dart';

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? itemMargin;
  final ScrollPhysics? physics;

  const SkeletonList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.itemMargin,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: physics ?? const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonCard(
          height: itemHeight,
          margin: itemMargin ??
              const EdgeInsets.only(bottom: 12, left: 18, right: 18),
        );
      },
    );
  }
}
