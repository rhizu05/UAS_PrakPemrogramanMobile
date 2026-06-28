import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/product_provider.dart';
import 'package:uas_prakpemrogramanmobile/providers/category_provider.dart';
import 'package:uas_prakpemrogramanmobile/widgets/product_card.dart';
import 'package:uas_prakpemrogramanmobile/widgets/shimmer_product_card.dart';
import 'package:uas_prakpemrogramanmobile/widgets/empty_state_widget.dart';
import 'package:uas_prakpemrogramanmobile/widgets/error_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      categoryProvider.fetchCategories();
      // Apply existing filter defaults on startup
      productProvider.updateFilters(
        search: _searchController.text,
        categoryId: categoryProvider.selectedCategoryId,
        sort: productProvider.selectedSort,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Near bottom, load more
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(refresh: false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      Provider.of<ProductProvider>(context, listen: false).updateFilters(
        search: query,
        categoryId: categoryProvider.selectedCategoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mobile Mart'),
        elevation: 0,
        backgroundColor: AppColors.card,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              categoryProvider.fetchCategories();
              productProvider.fetchProducts(refresh: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search, Filter Sort Header Section
          Container(
            color: AppColors.card,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.secondary),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.cardSoft,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Sorting & Label Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text(
                      'Pilih Kategori',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    // Sort Dropdown
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: productProvider.selectedSort,
                        icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primary, size: 20),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        onChanged: (String? newSort) {
                          if (newSort != null) {
                            productProvider.updateFilters(sort: newSort);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
                          DropdownMenuItem(value: 'price_asc', child: Text('Harga Terendah')),
                          DropdownMenuItem(value: 'price_desc', child: Text('Harga Tertinggi')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Horizontal Kategori Chips
          Container(
            height: 48,
            color: AppColors.card,
            child: categoryProvider.isLoading
                ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categoryProvider.categories.length + 1,
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final category = isAll ? null : categoryProvider.categories[index - 1];
                      
                      final catId = isAll ? null : category!.id;
                      final catName = isAll ? 'Semua' : category!.name;
                      final isSelected = categoryProvider.selectedCategoryId == catId;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(catName),
                          selected: isSelected,
                          selectedColor: AppColors.primarySoft,
                          backgroundColor: AppColors.cardSoft,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              categoryProvider.selectCategory(catId);
                              productProvider.updateFilters(categoryId: catId);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
          
          // Product List Grid
          Expanded(
            child: _buildProductsBody(productProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsBody(ProductProvider provider) {
    if (provider.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ShimmerProductCard(),
      );
    }

    if (provider.errorMessage != null) {
      return ErrorStateWidget(
        message: provider.errorMessage!,
        onRetry: () => provider.fetchProducts(refresh: true),
      );
    }

    if (provider.products.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off_rounded,
        message: 'Produk tidak ditemukan.',
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.products.length + (provider.isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index < provider.products.length) {
          return ProductCard(product: provider.products[index]);
        } else {
          return const ShimmerProductCard();
        }
      },
    );
  }
}
