import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/providers/auth_provider.dart';
import 'package:uas_prakpemrogramanmobile/screens/admin/admin_main_navigation_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/auth/login_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/customer/customer_main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Fade-in on first frame (0.8s ease-out, with subtle rise).
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Slow pulse for the "Starting up..." text.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Continuous loading bar progress (matches @keyframes progress).
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _checkAuth();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

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
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative corner brackets (opacity 30%, 64x64, 2px white outer borders)
            const _CornerBracket(top: true, left: true),
            const _CornerBracket(top: true, left: false),
            const _CornerBracket(top: false, left: true),
            const _CornerBracket(top: false, left: false),

            // Central logo + brand block with fade-in animation
            Center(
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo card: 96x96 white rounded-xl, smartphone icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smartphone,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Brand name + tagline
                    const Column(
                      children: [
                        Text(
                          'Mobile Mart',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.7,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'YOUR DIGITAL MARKETPLACE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom loading bar + status text
            Positioned(
              left: 48, // px-12 ≈ 48
              right: 48,
              bottom: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading bar track
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          // Reproduce the @keyframes progress: 0% → 50% → 100%
                          // 0%  : width 0%,   left 0%
                          // 50% : width 40%,  left 30%
                          // 100%: width 0%,   left 100%
                          const trackWidth = 200.0;
                          final t = _progressController.value;
                          double widthPct;
                          double leftPct;
                          if (t < 0.5) {
                            final p = t * 2; // 0..1
                            widthPct = 40 * p;
                            leftPct = 30 * p;
                          } else {
                            final p = (t - 0.5) * 2; // 0..1
                            widthPct = 40 * (1 - p);
                            leftPct = 30 + 70 * p;
                          }
                          return Stack(
                            children: [
                              Positioned(
                                left: leftPct / 100 * trackWidth,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: widthPct / 100 * trackWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // "Starting up..." with slow pulse opacity
                  FadeTransition(
                    opacity: _pulseAnimation,
                    child: const Text(
                      'Starting up...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
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
}

/// Decorative corner bracket: 64x64, 2px white outer border, 30% opacity.
class _CornerBracket extends StatelessWidget {
  const _CornerBracket({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 16 : null,
      bottom: !top ? 16 : null,
      left: left ? 16 : null,
      right: !left ? 16 : null,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.3,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border: Border(
                top: top
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
                bottom: !top
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
                left: left
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
                right: !left
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(top && left ? 12 : 0),
                topRight: Radius.circular(top && !left ? 12 : 0),
                bottomLeft: Radius.circular(!top && left ? 12 : 0),
                bottomRight: Radius.circular(!top && !left ? 12 : 0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
