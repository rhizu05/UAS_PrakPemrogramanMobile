import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/core/services/storage_service.dart';
import 'package:uas_prakpemrogramanmobile/providers/auth_provider.dart';
import 'package:uas_prakpemrogramanmobile/screens/admin/admin_main_navigation_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/customer/customer_main_navigation_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();

    // Premium entrance animation: fade-in and scale-up
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.85,
      upperBound: 1.0,
    );

    _fadeController.forward();
    _scaleController.forward();

    _checkAuthAndOnboarding();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check if onboarding is completed
    final bool onboardingCompleted = StorageService.isOnboardingCompleted();
    
    if (!onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (isAuthenticated) {
      if (authProvider.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerMainNavigationScreen(),
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerMainNavigationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Background blobs from Figma (Circle ornaments)
          // 1. Top Right Circle (width 320, height 320, x=153.6, y=-80)
          Positioned(
            right: -80,
            top: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 2. Bottom Left Circle (width 224, height 224, x=-64, y=668)
          Positioned(
            left: -64,
            bottom: -40,
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 3. Middle Right Circle (width 128, height 128, x=233.6, y=596)
          Positioned(
            right: 32,
            bottom: 128,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Central Logo & Brand
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: ScaleTransition(
                scale: _scaleController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo Card: 96x96 white rounded, with CustomPaint Shopping Bag Icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CustomPaint(
                          painter: ShoppingBagPainter(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Brand Name
                    const Text(
                      'LimeCart',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.7,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    const Text(
                      'Belanja mudah, harga terbaik',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom page dots
          Positioned(
            left: 0,
            right: 0,
            bottom: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter to draw the Figma-like LimeCart Shopping Bag Icon
class ShoppingBagPainter extends CustomPainter {
  final Color color;

  ShoppingBagPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 1. Draw the bag body (rounded corner container at the bottom)
    final bodyPath = Path()
      ..moveTo(w * 0.15, h * 0.38)
      ..lineTo(w * 0.85, h * 0.38)
      ..lineTo(w * 0.85, h * 0.78)
      ..arcToPoint(
        Offset(w * 0.73, h * 0.88),
        radius: Radius.circular(w * 0.12),
        clockwise: true,
      )
      ..lineTo(w * 0.27, h * 0.88)
      ..arcToPoint(
        Offset(w * 0.15, h * 0.78),
        radius: Radius.circular(w * 0.12),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(bodyPath, paint);

    // 2. Draw the flap/opening line of the bag (horizontal line at the top body)
    final flapPath = Path()
      ..moveTo(w * 0.15, h * 0.48)
      ..lineTo(w * 0.85, h * 0.48);
    canvas.drawPath(flapPath, paint);

    // 3. Draw the handle (loop at the top)
    final handlePath = Path()
      ..moveTo(w * 0.35, h * 0.38)
      ..cubicTo(
        w * 0.35, h * 0.15,
        w * 0.65, h * 0.15,
        w * 0.65, h * 0.38,
      );
    canvas.drawPath(handlePath, paint);

    // 4. Draw the smile-like curve on the pocket
    final smilePath = Path()
      ..moveTo(w * 0.42, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.70, w * 0.58, h * 0.62);
    canvas.drawPath(smilePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
