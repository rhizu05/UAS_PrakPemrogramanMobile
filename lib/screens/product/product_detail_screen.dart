import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/date_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/product_provider.dart';
import 'package:uas_prakpemrogramanmobile/providers/cart_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_button.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_text_field.dart';
import 'package:uas_prakpemrogramanmobile/widgets/empty_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _reviewFormKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _inputRating = 5.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchProductDetail(widget.productId);
      provider.fetchProductReviews(widget.productId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitReview() async {
    if (!_reviewFormKey.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);
    try {
      final success = await provider.addReview(
        widget.productId,
        rating: _inputRating.toInt(),
        comment: _commentController.text,
      );

      if (!mounted) return;

      if (success) {
        _commentController.clear();
        setState(() {
          _inputRating = 5.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        elevation: 0,
        backgroundColor: AppColors.card,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildDetailBody(provider),
      bottomNavigationBar: _buildBottomCartSection(provider),
    );
  }

  Widget _buildDetailBody(ProductProvider provider) {
    if (provider.isLoadingDetail) {
      return const LoadingWidget();
    }

    if (provider.errorDetail != null) {
      return ErrorStateWidget(
        message: provider.errorDetail!,
        onRetry: () => provider.fetchProductDetail(widget.productId),
      );
    }

    final product = provider.detailProduct;
    if (product == null) {
      return const EmptyStateWidget(
        message: 'Data produk tidak ditemukan.',
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Image
          AspectRatio(
            aspectRatio: 1.2,
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.cardSoft,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.cardSoft,
                      child: const Icon(Icons.broken_image_outlined, size: 64, color: AppColors.secondary),
                    ),
                  )
                : Container(
                    color: AppColors.cardSoft,
                    child: const Icon(Icons.image_outlined, size: 64, color: AppColors.secondary),
                  ),
          ),
          
          // Info Container
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.categoryName ?? 'Kategori',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: product.stock > 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Price
                Text(
                  CurrencyHelper.formatRupiah(product.price),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                
                // Average Rating Overview
                if (product.totalReviews > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.averageRating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: AppColors.warning,
                        ),
                        itemCount: 5,
                        itemSize: 18.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${product.averageRating.toStringAsFixed(1)} (${product.totalReviews} Ulasan)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const Divider(height: 32, color: AppColors.border),
                
                // Description
                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'Tidak ada deskripsi untuk produk ini.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Form Review Section
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _reviewFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Berikan Ulasan Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Rating Input
                  RatingBar.builder(
                    initialRating: _inputRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.only(right: 8.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: AppColors.warning,
                    ),
                    onRatingUpdate: (rating) {
                      _inputRating = rating;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Comment Text Field
                  CustomTextField(
                    controller: _commentController,
                    labelText: 'Komentar Ulasan',
                    hintText: 'Tulis tanggapan Anda mengenai produk ini',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Komentar tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Submit Review Button
                  CustomButton(
                    text: 'Kirim Ulasan',
                    isLoading: provider.isAddingReview,
                    onPressed: _handleSubmitReview,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // List Reviews Section
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ulasan Pembeli',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildReviewsList(provider),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReviewsList(ProductProvider provider) {
    if (provider.isLoadingReviews) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.errorReviews != null) {
      return Center(
        child: Text(
          'Gagal mengambil ulasan: ${provider.errorReviews}',
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    if (provider.reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            'Belum ada ulasan untuk produk ini.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.reviews.length,
      separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: 24),
      itemBuilder: (context, index) {
        final review = provider.reviews[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.reviewerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateHelper.formatDate(review.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            RatingBarIndicator(
              rating: review.rating.toDouble(),
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: AppColors.warning,
              ),
              itemCount: 5,
              itemSize: 14.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(height: 8),
            if (review.comment != null && review.comment!.isNotEmpty)
              Text(
                review.comment!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBottomCartSection(ProductProvider provider) {
    final product = provider.detailProduct;
    if (product == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Total price estimate
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Harga',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  CurrencyHelper.formatRupiah(product.price),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Cart Button
          SizedBox(
            width: 180,
            child: Consumer<CartProvider>(
              builder: (consumerContext, cartProvider, child) {
                return CustomButton(
                  text: 'Beli Sekarang',
                  isLoading: cartProvider.isLoading,
                  onPressed: product.stock > 0
                      ? () async {
                          final success = await cartProvider.addToCart(product.id);
                          if (!mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Produk berhasil ditambahkan ke keranjang!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(cartProvider.errorMessage ?? 'Gagal menambahkan produk ke keranjang'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      : null, // Disabled if stock is 0
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
