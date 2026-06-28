import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardSoft,
      highlightColor: Colors.white,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey[300],
              ),
            ),
            
            // Text Placeholder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 10,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          color: Colors.grey[300],
                        ),
                        Container(
                          width: 30,
                          height: 12,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
