import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/models/product_model.dart';
import 'package:uas_prakpemrogramanmobile/screens/product/product_detail_screen.dart';

// Note: Ensure correct cached_network_image import below
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.cardSoft,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.cardSoft,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.secondary,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.cardSoft,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.secondary,
                            size: 40,
                          ),
                        ),
                ),
                // Positioned(
                //   top: 10,
                //   right: 10,
                //   child: Container(
                //     width: 30,
                //     height: 30,
                //     decoration: BoxDecoration(
                //       color: AppColors.card.withValues(alpha: 0.92),
                //       shape: BoxShape.circle,
                //       boxShadow: const [
                //         BoxShadow(
                //           color: Color(0x14000000),
                //           blurRadius: 10,
                //           offset: Offset(0, 4),
                //         ),
                //       ],
                //     ),
                //     // child: const Icon(
                //     //   Icons.favorite_border_rounded,
                //     //   size: 17,
                //     //   color: AppColors.secondary,
                //     // ),
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyHelper.formatRupiah(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.averageRating > 0
                            ? product.averageRating.toStringAsFixed(1)
                            : '0.0',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.totalReviews})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
