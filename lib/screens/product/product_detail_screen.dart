import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/currency_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/helpers/date_helper.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/auth_provider.dart';
import 'package:uas_prakpemrogramanmobile/providers/product_provider.dart';
import 'package:uas_prakpemrogramanmobile/providers/cart_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_button.dart';
import 'package:uas_prakpemrogramanmobile/widgets/custom_text_field.dart';
import 'package:uas_prakpemrogramanmobile/widgets/empty_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/loading_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/product_card.dart'; // For getCategoryBgColor, getCategoryFgColor
import 'package:uas_prakpemrogramanmobile/screens/auth/login_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/auth/register_screen.dart';

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

  void _showLoginRequiredBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Light green circle with Profile Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF1FBF0), // light green-50
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              "Masuk Diperlukan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              "Silakan masuk atau daftar untuk melanjutkan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Buttons
            Row(
              children: [
                // Masuk Button (Solid Green)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                // Daftar Button (Outlined Green)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Daftar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Future<void> _confirmDeleteReview(ProductProvider provider, String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Ulasan'),
        content: const Text('Apakah Anda yakin ingin menghapus ulasan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final success = await provider.deleteReview(widget.productId, reviewId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan berhasil dihapus!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
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

    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Content Area (Scrollable product image + info container sheet)
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Width Image at the top
                SizedBox(
                  height: 380,
                  width: double.infinity,
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
                
                // Form/Info Bottom Sheet Container (Overlays top section via translate / spacing)
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Price & Rating Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyHelper.formatRupiah(product.price),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  product.averageRating > 0
                                      ? product.averageRating.toStringAsFixed(1)
                                      : '0.0',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${product.totalReviews})',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Stock Status Badge
                        _buildStockBadge(product.stock),
                        const SizedBox(height: 24),

                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 20),

                        // Description Section
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description ?? 'Tidak ada deskripsi untuk produk ini.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 20),

                        // List Reviews Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ulasan Pembeli',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (product.totalReviews > 0)
                              Text(
                                "★ ${product.averageRating.toStringAsFixed(1)} / 5",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildReviewsList(provider),
                        const SizedBox(height: 24),

                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 20),

                        // Form Review Section
                        Builder(
                          builder: (context) {
                            final isGuest = !context.watch<AuthProvider>().isAuthenticated;
                            
                            if (isGuest) {
                              // Figma guest review card (10:4808)
                              return GestureDetector(
                                onTap: _showLoginRequiredBottomSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC), // slate-50
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFDCFCE7), // light green-50
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.person_outline_rounded,
                                          color: AppColors.primary,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Tulis Ulasan",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              "Masuk untuk membagikan pendapatmu",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Form(
                              key: _reviewFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tulis Ulasan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Star Selection (5/5)
                                  RatingBar.builder(
                                    initialRating: _inputRating,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: false,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.only(right: 8.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.warning,
                                    ),
                                    onRatingUpdate: (rating) {
                                      setState(() {
                                        _inputRating = rating;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Comment input
                                  CustomTextField(
                                    controller: _commentController,
                                    labelText: 'Komentar Ulasan',
                                    showLabel: false,
                                    hintText: 'Bagikan pendapatmu tentang produk ini.',
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Komentar tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Kirim button
                                  CustomButton(
                                    text: 'Kirim Ulasan',
                                    isLoading: provider.isAddingReview,
                                    onPressed: _handleSubmitReview,
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top Navigation Overlays (Melayang)
        // 1. Back button (top left overlay)
        Positioned(
          left: 16,
          top: topPadding + 10,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),

        // 2. Category badge (top right overlay)
        Positioned(
          right: 16,
          top: topPadding + 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: getCategoryBgColor(product.categoryName),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              product.categoryName ?? 'Kategori',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: getCategoryFgColor(product.categoryName),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Stock status helper badge
  Widget _buildStockBadge(int stock) {
    Color bg;
    Color fg;
    String label;

    if (stock > 10) {
      bg = const Color(0xFFDCFCE7); // green-50
      fg = const Color(0xFF16A34A); // green-600
      label = "Stok Tersedia";
    } else if (stock > 0) {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFEA580C); // orange-600
      label = "Sisa $stock item";
    } else {
      bg = const Color(0xFFFEE2E2); // red-50
      fg = const Color(0xFFDC2626); // red-600
      label = "Stok Habis";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
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

    final user = context.read<AuthProvider>().user;
    final currentUserId = user?.id;
    final remaining = provider.reviewTotal - provider.reviews.length;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.reviews.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = provider.reviews[index];
            final isOwnReview = currentUserId != null &&
                review.reviewerId != null &&
                review.reviewerId == currentUserId;
            final initials = _getInitials(review.reviewerName);

            // Figma styled review card
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFc),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Reviewer Avatar Circle
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      // Name and Stars
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.reviewerName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RatingBarIndicator(
                              rating: review.rating.toDouble(),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star_rounded,
                                color: AppColors.warning,
                              ),
                              itemCount: 5,
                              itemSize: 14.0,
                              direction: Axis.horizontal,
                            ),
                          ],
                        ),
                      ),
                      
                      // Date and delete action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateHelper.formatDate(review.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (isOwnReview) ...[
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: provider.isDeletingReview
                                  ? null
                                  : () => _confirmDeleteReview(provider, review.id),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Comment body
                  if (review.comment != null && review.comment!.isNotEmpty)
                    Text(
                      review.comment!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (provider.isLoadingMoreReviews)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (provider.reviewHasMore)
          OutlinedButton(
            onPressed: () => provider.fetchMoreReviews(widget.productId),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Muat ${remaining > 5 ? 5 : remaining} ulasan lainnya',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          )
        else if (provider.reviewTotal > 5)
          Center(
            child: Text(
              'Menampilkan semua ${provider.reviewTotal} ulasan',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomCartSection(ProductProvider provider) {
    final product = provider.detailProduct;
    if (product == null) return const SizedBox.shrink();

    final isOutOfStock = product.stock == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: Consumer<CartProvider>(
          builder: (consumerContext, cartProvider, child) {
            return ElevatedButton(
              onPressed: isOutOfStock
                  ? null
                  : () async {
                      final isGuest = !context.read<AuthProvider>().isAuthenticated;
                      if (isGuest) {
                        _showLoginRequiredBottomSheet();
                        return;
                      }

                      final success = await cartProvider.addToCart(product.id);
                      if (!mounted) return;
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} berhasil ditambahkan!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(cartProvider.errorMessage ?? 'Gagal menambahkan ke keranjang'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isOutOfStock ? Colors.grey.shade300 : AppColors.primary,
                foregroundColor: isOutOfStock ? Colors.grey.shade500 : Colors.white,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOutOfStock ? Icons.remove_shopping_cart : Icons.shopping_cart_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOutOfStock ? "Stok Habis" : "Tambah ke Keranjang",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
