import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/models/product_model.dart';
import 'package:uas_prakpemrogramanmobile/screens/product/product_detail_screen.dart';
import 'package:uas_prakpemrogramanmobile/providers/cart_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

Color getCategoryBgColor(String? categoryName) {
  final name = categoryName?.toLowerCase() ?? '';
  if (name.contains('elektronik')) return const Color(0xFFE0F2FE);
  if (name.contains('fashion')) return const Color(0xFFF3E8FF);
  if (name.contains('kesehatan')) return const Color(0xFFFEE2E2);
  if (name.contains('kecantikan')) return const Color(0xFFFCE7F3);
  if (name.contains('makanan')) return const Color(0xFFFFEDD5);
  if (name.contains('minuman')) return const Color(0xFFE0F7FA);
  if (name.contains('rumah')) return const Color(0xFFDCFCE7);
  return const Color(0xFFF1F5F9);
}

Color getCategoryFgColor(String? categoryName) {
  final name = categoryName?.toLowerCase() ?? '';
  if (name.contains('elektronik')) return const Color(0xFF0284C7);
  if (name.contains('fashion')) return const Color(0xFF7C3AED);
  if (name.contains('kesehatan')) return const Color(0xFFDC2626);
  if (name.contains('kecantikan')) return const Color(0xFFDB2777);
  if (name.contains('makanan')) return const Color(0xFFEA580C);
  if (name.contains('minuman')) return const Color(0xFF00ACC1);
  if (name.contains('rumah')) return const Color(0xFF16A34A);
  return const Color(0xFF475569);
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stock == 0;

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
            // Image Section
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    if (isOutOfStock)
                      ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.33, 0.33, 0.33, 0, 0,
                          0.33, 0.33, 0.33, 0, 0,
                          0.33, 0.33, 0.33, 0, 0,
                          0, 0, 0, 0.6, 0,
                        ]),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.cardSoft,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
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
                        ),
                      )
                    else
                      CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.cardSoft,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                  else
                    Container(
                      color: AppColors.cardSoft,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ),
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Stok Habis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: getCategoryBgColor(product.categoryName),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.categoryName ?? 'Kategori',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: getCategoryFgColor(product.categoryName),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Product Name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isOutOfStock ? AppColors.textSecondary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Rating Row
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: isOutOfStock ? AppColors.textSecondary : AppColors.warning,
                        size: 15,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.averageRating > 0
                            ? product.averageRating.toStringAsFixed(1)
                            : '0.0',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isOutOfStock ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.totalReviews})',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Price and Add button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          CurrencyHelper.formatRupiah(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isOutOfStock ? AppColors.textSecondary : AppColors.primary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: isOutOfStock
                            ? null
                            : () async {
                                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                                final success = await cartProvider.addToCart(product.id);
                                if (context.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.name} berhasil ditambahkan!'),
                                        backgroundColor: AppColors.success,
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(cartProvider.errorMessage ?? 'Gagal menambahkan'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isOutOfStock ? AppColors.border : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.add,
                            size: 16,
                            color: isOutOfStock ? AppColors.textSecondary : Colors.white,
                          ),
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
