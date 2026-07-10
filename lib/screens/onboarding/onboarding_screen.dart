import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/core/services/storage_service.dart';
import 'package:uas_prakpemrogramanmobile/screens/auth/login_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/customer/customer_main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(Widget targetScreen) async {
    await StorageService.saveOnboardingCompleted(true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Lewati (Skip) button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _completeOnboarding(const CustomerMainNavigationScreen()),
                child: const Text(
                  "Lewati",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            
            // Slider content (PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    visual: _buildSlide1Visual(),
                    title: "Semua Kebutuhan dalam Satu Aplikasi",
                    subtitle: "Temukan berbagai produk mulai dari elektronik, fashion, kecantikan, kesehatan, makanan, minuman, hingga kebutuhan rumah tangga.",
                  ),
                  _buildPage(
                    visual: _buildSlide2Visual(),
                    title: "Belanja Lebih Mudah",
                    subtitle: "Cari produk, pilih kategori, dan urutkan harga dengan mudah sesuai kebutuhan belanja Anda.",
                  ),
                  _buildPage(
                    visual: _buildSlide3Visual(),
                    title: "Checkout dan Pesanan",
                    subtitle: "Tambahkan produk ke keranjang, buat pesanan, dan pantau status pesanan langsung dari aplikasi.",
                  ),
                ],
              ),
            ),

            // Page Indicator (Dots) & Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  
                  // Primary Actions
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _currentPage == 2
                        ? Column(
                            key: const ValueKey('slide3_buttons'),
                            children: [
                              // Mulai Belanja (Primary button, goes to Guest Home Screen)
                              ElevatedButton(
                                onPressed: () => _completeOnboarding(const CustomerMainNavigationScreen()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 56),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Mulai Belanja",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Masuk (Secondary outlined button, goes to Login)
                              OutlinedButton(
                                onPressed: () => _completeOnboarding(const LoginScreen()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            key: const ValueKey('slide1_2_button'),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lanjut",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
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

  // Common Slide Page Builder
  Widget _buildPage({
    required Widget visual,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Illustration visual container
          Expanded(
            flex: 6,
            child: Center(child: visual),
          ),
          const SizedBox(height: 16),
          // Heading title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.6,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle text
          Expanded(
            flex: 3,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Visual Illustrations ---

  // Slide 1: Categories Floating around Smartphone Mockup
  Widget _buildSlide1Visual() {
    return SizedBox(
      width: 340,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Central Smartphone Frame Mockup
          Container(
            width: 156,
            height: 256,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.grey.shade200, width: 4.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Column(
                children: [
                  // App Mock Header
                  Container(
                    color: AppColors.primary,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LimeCart",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Selamat datang!",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 7.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // App Mock Content
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade50,
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Fake Search
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Fake chips
                          Row(
                            children: [
                              _phoneChip("Elek"),
                              const SizedBox(width: 3),
                              _phoneChip("Fash"),
                              const SizedBox(width: 3),
                              _phoneChip("Kec"),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Grid placeholders
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(4, (index) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(height: 3, width: 20, color: Colors.grey.shade200),
                                  ],
                                ),
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating Category Bubbles (coordinates mapped closely to Figma)
          // 1. Fashion (Top)
          Positioned(
            top: 35,
            left: 50,
            child: _floatingBubble(
              icon: Icons.checkroom,
              label: "Fashion",
              bg: const Color(0xFFF3E8FF),
              fg: const Color(0xFF7C3AED),
            ),
          ),
          // 2. Kecantikan (Top Right)
          Positioned(
            top: 40,
            right: 15,
            child: _floatingBubble(
              icon: Icons.auto_awesome,
              label: "Kecantikan",
              bg: const Color(0xFFFCE7F3),
              fg: const Color(0xFFDB2777),
            ),
          ),
          // 3. Makanan (Middle Right)
          Positioned(
            top: 120,
            right: 10,
            child: _floatingBubble(
              icon: Icons.restaurant,
              label: "Makanan",
              bg: const Color(0xFFFFEDD5),
              fg: const Color(0xFFEA580C),
            ),
          ),
          // 4. Rumah (Bottom Right)
          Positioned(
            bottom: 40,
            right: 25,
            child: _floatingBubble(
              icon: Icons.home,
              label: "Rumah",
              bg: const Color(0xFFDCFCE7),
              fg: const Color(0xFF16A34A),
            ),
          ),
          // 5. Minuman (Bottom)
          Positioned(
            bottom: 0,
            left: 105,
            child: _floatingBubble(
              icon: Icons.local_cafe,
              label: "Minuman",
              bg: const Color(0xFFE0F7FA),
              fg: const Color(0xFF00ACC1),
            ),
          ),
          // 6. Kesehatan (Bottom Left)
          Positioned(
            bottom: 35,
            left: 15,
            child: _floatingBubble(
              icon: Icons.favorite,
              label: "Kesehatan",
              bg: const Color(0xFFFEE2E2),
              fg: const Color(0xFFDC2626),
            ),
          ),
          // 7. Elektronik (Middle Left)
          Positioned(
            top: 120,
            left: 15,
            child: _floatingBubble(
              icon: Icons.devices,
              label: "Elektronik",
              bg: const Color(0xFFE0F2FE),
              fg: const Color(0xFF0284C7),
            ),
          ),
        ],
      ),
    );
  }

  // Slide 2: Search, Category Filters and Products
  Widget _buildSlide2Visual() {
    return Container(
      width: 290,
      height: 256,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search box
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Chips
          Row(
            children: [
              _filterChip("Semua", active: true),
              const SizedBox(width: 6),
              _filterChip("Elektronik"),
              const SizedBox(width: 6),
              _filterChip("Fashion"),
            ],
          ),
          const SizedBox(height: 12),
          
          // Meta & Sort
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "8 produk ditemukan",
                style: TextStyle(fontSize: 10, color: AppColors.secondary),
              ),
              Row(
                children: [
                  Icon(Icons.swap_vert, size: 12, color: AppColors.primary),
                  const SizedBox(width: 2),
                  const Text(
                    "Urutkan",
                    style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Grid products mockup
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _productCard(
                    title: "iPhone 15 Pro",
                    tag: "Elektronik",
                    tagBg: const Color(0xFFE0F2FE),
                    tagFg: const Color(0xFF0284C7),
                    price: "Rp 21.999.000",
                    gradient: const LinearGradient(
                      colors: [Color(0xFF93C5FD), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.phone_iphone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _productCard(
                    title: "Nike Air Max",
                    tag: "Fashion",
                    tagBg: const Color(0xFFF3E8FF),
                    tagFg: const Color(0xFF7C3AED),
                    price: "Rp 1.899.000",
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC084FC), Color(0xFF818CF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    icon: Icons.run_circle_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Slide 3: Checkout and Order Status Tracking
  Widget _buildSlide3Visual() {
    return Container(
      width: 290,
      height: 256,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Product summary tile
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.phone_iphone, size: 24, color: Colors.blueGrey),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "iPhone 15 Pro Max",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Rp 21.999.000",
                      style: TextStyle(fontSize: 10, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const Text(
                "x1",
                style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),
          
          // Timeline Tracker
          Expanded(
            child: Stack(
              children: [
                // Connecting vertical line
                Positioned(
                  left: 13,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                  ),
                ),
                
                // Steps
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _timelineStep(
                      icon: Icons.shopping_cart,
                      title: "Menunggu Pembayaran",
                      badge: "Pending",
                      bg: const Color(0xFFFFF3E0),
                      fg: const Color(0xFFFF9800),
                    ),
                    _timelineStep(
                      icon: Icons.inventory_2,
                      title: "Pesanan Diproses",
                      badge: "Processing",
                      bg: const Color(0xFFE3F2FD),
                      fg: const Color(0xFF2196F3),
                    ),
                    _timelineStep(
                      icon: Icons.local_shipping,
                      title: "Dalam Pengiriman",
                      badge: "Shipped",
                      bg: const Color(0xFFF3E5F5),
                      fg: const Color(0xFF9C27B0),
                    ),
                    _timelineStep(
                      icon: Icons.check_circle,
                      title: "Pesanan Selesai",
                      badge: "Delivered",
                      bg: const Color(0xFFE8F5E9),
                      fg: const Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  // Mini text chip in smartphone mockup (Slide 1)
  Widget _phoneChip(String text) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECFCCB),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 6, color: AppColors.primary, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Floating Category Bubble (Slide 1)
  Widget _floatingBubble({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: fg),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ],
    );
  }

  // Chip filter (Slide 2)
  Widget _filterChip(String text, {bool active = false}) {
    return Container(
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: active ? Colors.white : Colors.grey.shade600,
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  // Product Card mockup (Slide 2)
  Widget _productCard({
    required String title,
    required String tag,
    required Color tagBg,
    required Color tagFg,
    required String price,
    required Gradient gradient,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 24, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 6),
          // Category Tag
          Container(
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              tag,
              style: TextStyle(fontSize: 7.5, color: tagFg, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(fontSize: 9.5, color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Timeline Step (Slide 3)
  Widget _timelineStep({
    required IconData icon,
    required String title,
    required String badge,
    required Color bg,
    required Color fg,
  }) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: fg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            badge,
            style: TextStyle(fontSize: 8, color: fg, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
