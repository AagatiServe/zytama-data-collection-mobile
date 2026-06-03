import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zytama_data/core/constants/app_colors.dart';
import 'package:zytama_data/features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/product_bloc.dart';
import 'barcode_scanner_screen.dart';
import 'multi_capture_screen.dart';
import 'package:zytama_data/features/auth/presentation/screens/login_screen.dart';
import 'notification_screen.dart';
import 'product_review_screen.dart';

class _ScanEntry {
  final String barcode;
  final DateTime time;
  _ScanEntry({required this.barcode, required this.time});
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _scanCount = 0;
  static const int _dailyGoal = 60;
  static const int _streak = 5;
  final List<_ScanEntry> _recentScans = [];

  late final AnimationController _pulseCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _ringFade;
  late final Animation<double> _ringProgress;
  late final Animation<double> _cardFade;
  late final Animation<double> _cardScale;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _pulseCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _headerFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    _ringFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut));
    _ringProgress = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.25, 1.0, curve: Curves.easeInOut));

    _cardFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut));
    _cardScale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.45, 0.85, curve: Curves.elasticOut)));

    _btnFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.60, 0.90, curve: Curves.easeOut));
    _btnSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.60, 1.0, curve: Curves.easeOut)));

    _entryCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openScanner());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    if (!mounted) return;
    context.read<ProductBloc>().add(ScanBarcodeRequested());
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted) return;
    barcode != null
        ? context.read<ProductBloc>().add(BarcodeScanned(barcode))
        : context.read<ProductBloc>().add(ResetProduct());
  }


  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.sizeOf(context);
    final heroH = sz.height * 0.60;
    // Ring fills available space inside hero after header + badge + paddings
    final ringSize = (heroH - 148).clamp(160.0, 240.0);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (r) => false);
            }
          },
        ),
        BlocListener<ProductBloc, ProductState>(
          listener: (context, state) async {
            if (state is ProductExists) {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 28),
                    SizedBox(width: 8),
                    Text('Already Exists'),
                  ]),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.productImageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(state.productImageUrl!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox()),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(state.message ??
                          'This product is already in the database.'),
                      const SizedBox(height: 8),
                      _BarcodeChip(barcode: state.barcode),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK')),
                  ],
                ),
              );
              if (!context.mounted) return;
              context.read<ProductBloc>().add(ResetProduct());
              _openScanner();
            } else if (state is ProductNotExists) {
              final images = await Navigator.of(context).push<List<File>>(
                MaterialPageRoute(
                  builder: (_) =>
                      MultiCaptureScreen(barcode: state.barcode),
                ),
              );
              if (!context.mounted) return;
              if (images != null && images.length == 3) {
                context.read<ProductBloc>().add(AllImagesCaptured(
                      productImage: images[0],
                      ingredientsImage: images[1],
                      nutritionImage: images[2],
                    ));
              } else {
                context.read<ProductBloc>().add(ResetProduct());
                _openScanner();
              }
            } else if (state is ReadyToReview) {
              final cb = state.barcode;
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProductReviewScreen(
                  barcode: cb,
                  initialProductImage: state.productImage,
                  initialIngredientsImage: state.ingredientsImage,
                  initialNutritionImage: state.nutritionImage,
                  onSuccess: () => setState(() {
                    _scanCount++;
                    _recentScans.insert(
                        0, _ScanEntry(barcode: cb, time: DateTime.now()));
                    if (_recentScans.length > 10) _recentScans.removeLast();
                  }),
                ),
              ));
              if (!context.mounted) return;
              if (context.read<ProductBloc>().state is ProductInitial) {
                _openScanner();
              }
            } else if (state is ProductError) {
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Row(children: [
                    Icon(Icons.error_rounded, color: Colors.red, size: 26),
                    SizedBox(width: 8),
                    Text('Error'),
                  ]),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'))
                  ],
                ),
              );
              if (!context.mounted) return;
              context.read<ProductBloc>().add(ResetProduct());
              _openScanner();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.dashBg,
        body: Stack(
          children: [
            // ── Background blobs (below-hero area) ──────────────────────
            Positioned(
              bottom: -60,
              right: -80,
              child: Container(
                width: sz.width * 0.75,
                height: sz.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.dashTeal.withValues(alpha: 0.12),
                      Colors.transparent
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: sz.height * 0.1,
              left: -60,
              child: Container(
                width: sz.width * 0.5,
                height: sz.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.dashTealMid.withValues(alpha: 0.08),
                      Colors.transparent
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
            // ── Main content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _buildHeroArea(heroH, ringSize),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(20, 0, 20, sz.height * 0.035),
                      child: Column(
                        children: [
                          SizedBox(
                              height: sz.height * 0.12), // card overlap space
                          const Spacer(),
                          FadeTransition(
                            opacity: _btnFade,
                            child: SlideTransition(
                              position: _btnSlide,
                              child: BlocBuilder<ProductBloc, ProductState>(
                                builder: (context, state) {
                                  final idle = state is ProductInitial ||
                                      state is ProductScanning;
                                  return _V3LaunchButton(
                                    onTap: idle ? _openScanner : null,
                                    isChecking: state is ProductChecking,
                                    isUploading: state is ProductUploading,
                                    screenWidth: sz.width,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Checking overlay ─────────────────────────────────────────
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is! ProductChecking) return const SizedBox.shrink();
                return Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8))
                        ],
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 3),
                        const SizedBox(height: 20),
                        const Text('Checking product…',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        const SizedBox(height: 6),
                        Text(state.barcode,
                            style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'monospace',
                                color: AppColors.textLight)),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero + overlapping cards ──────────────────────────────────────────────

  Widget _buildHeroArea(double heroH, double ringSize) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildHero(heroH, ringSize),
        // Cards straddle the hero's rounded bottom (overlap ~36px inside)
        Positioned(
          bottom: -80,
          left: 20,
          right: 20,
          child: FadeTransition(
            opacity: _cardFade,
            child: AnimatedBuilder(
              animation: _cardScale,
              builder: (_, child) =>
                  Transform.scale(scale: _cardScale.value, child: child!),
              child: _FloatingCards(
                  scanCount: _scanCount,
                  dailyGoal: _dailyGoal,
                  streak: _streak),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(double heroH, double ringSize) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
      child: Container(
        height: heroH,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.4, -1),
            end: Alignment(0.4, 1),
            colors: [
              AppColors.dashTeal,
              AppColors.dashTealMid,
              AppColors.dashTealEnd
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative arcs
            Positioned(
                top: -200,
                right: -200,
                child: Container(
                    width: 460,
                    height: 460,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10))))),
            Positioned(
                top: -160,
                right: -160,
                child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10))))),
            Positioned(
                bottom: -120,
                left: -100,
                child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.10),
                          Colors.transparent
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ))),
            // Content — Spacer distributes header to top, ring to center
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final user = authState is AuthAuthenticated
                              ? authState.user
                              : null;
                          final name = user?.name.isNotEmpty == true
                              ? user!.name
                              : 'User';
                          final code = user?.agentCode.isNotEmpty == true
                              ? user!.agentCode
                              : '';
                          return _V3Header(
                            name: name,
                            agentCode: code,
                            onNotificationTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationScreen())),
                            onLogoutTap: () => _confirmLogout(context),
                          );
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _ringFade,
                    child: AnimatedBuilder(
                      animation: _entryCtrl,
                      builder: (_, __) {
                        final progress = (_dailyGoal > 0
                                ? (_scanCount / _dailyGoal).clamp(0.0, 1.0)
                                : 0.0) *
                            _ringProgress.value;
                        return Column(
                          children: [
                            const _LiveBadge(),
                            const SizedBox(height: 12),
                            _V3Ring(
                              size: ringSize,
                              scanCount: _scanCount,
                              dailyGoal: _dailyGoal,
                              pulseCtrl: _pulseCtrl,
                              progress: progress,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.logout_rounded, color: Colors.red, size: 24),
          SizedBox(width: 8),
          Text('Logout'),
        ]),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _V3Header extends StatelessWidget {
  final String name;
  final String agentCode;
  final VoidCallback onNotificationTap;
  final VoidCallback onLogoutTap;

  const _V3Header(
      {required this.name,
      required this.agentCode,
      required this.onNotificationTap,
      required this.onLogoutTap});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Row(
      children: [
        _GlassBox(
            width: 44,
            height: 44,
            radius: 14,
            child: Center(
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (agentCode.isNotEmpty)
                Text(agentCode,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.3)),
              Text('Hello, $name',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: _GlassBox(
              width: 44,
              height: 44,
              radius: 14,
              child: Stack(children: [
                const Center(
                    child: Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 20)),
                Positioned(
                    top: 9,
                    right: 10,
                    child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.dashOrange))),
              ])),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onLogoutTap,
          child: _GlassBox(
              width: 44,
              height: 44,
              radius: 14,
              bgColor: const Color(0x2EFF8A3D),
              borderColor: const Color(0x59FF8A3D),
              child: const Center(
                  child: Icon(Icons.logout_rounded,
                      color: Color(0xFFFFD0A8), size: 20))),
        ),
      ],
    );
  }
}

class _GlassBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Widget child;
  final Color bgColor;
  final Color borderColor;

  const _GlassBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.child,
    this.bgColor = const Color(0x26FFFFFF),
    this.borderColor = const Color(0x40FFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Live Badge ────────────────────────────────────────────────────────────────

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dashGlow,
                boxShadow: [
                  BoxShadow(color: AppColors.dashGlow, blurRadius: 8)
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text('LIVE · TODAY',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.0)),
          ]),
        ),
      ),
    );
  }
}

// ── Responsive Ring ───────────────────────────────────────────────────────────

class _V3Ring extends StatelessWidget {
  final double size;
  final int scanCount;
  final int dailyGoal;
  final AnimationController pulseCtrl;
  final double progress;

  const _V3Ring({
    required this.size,
    required this.scanCount,
    required this.dailyGoal,
    required this.pulseCtrl,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final countFs = (size * 0.33).clamp(52.0, 78.0);
    final labelFs = (size * 0.050).clamp(9.0, 12.0);
    final targetFs = (size * 0.060).clamp(10.0, 14.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
              size: Size(size, size),
              painter: _V3RingPainter(progress: progress, ringSize: size)),
          // Pulse inner ring
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) => Container(
              width: size * (0.62 + pulseCtrl.value * 0.04),
              height: size * (0.62 + pulseCtrl.value * 0.04),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.08 + pulseCtrl.value * 0.05)),
              ),
            ),
          ),
          // Center text
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('COLLECTED',
                style: TextStyle(
                    fontSize: labelFs,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.70),
                    letterSpacing: 1.6)),
            const SizedBox(height: 2),
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFC7FAF0)],
              ).createShader(rect),
              child: Text('$scanCount',
                  style: TextStyle(
                      fontSize: countFs,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -3,
                      height: 1.0)),
            ),
            Text('of $dailyGoal target',
                style: TextStyle(
                    fontSize: targetFs,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.75))),
          ]),
        ],
      ),
    );
  }
}

class _V3RingPainter extends CustomPainter {
  final double progress;
  final double ringSize;
  const _V3RingPainter({required this.progress, required this.ringSize});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = (ringSize * 0.064).clamp(10.0, 16.0);
    final radius = (ringSize - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke);

    // Tick marks (60, proportional to ring size)
    final tickMajor = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final tickMinor = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi - math.pi / 2;
      final r1 = radius - stroke / 2 - ringSize * 0.036;
      final r2 = r1 - (i % 5 == 0 ? ringSize * 0.028 : ringSize * 0.018);
      canvas.drawLine(
        Offset(
            center.dx + math.cos(angle) * r1, center.dy + math.sin(angle) * r1),
        Offset(
            center.dx + math.cos(angle) * r2, center.dy + math.sin(angle) * r2),
        i % 5 == 0 ? tickMajor : tickMinor,
      );
    }

    if (progress <= 0) return;

    final sweep = 2 * math.pi * progress;
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: const [AppColors.dashRingLight, AppColors.dashTeal],
    ).createShader(rect);

    // Glow pass
    canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..shader = shader
          ..strokeWidth = stroke + 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    // Sharp arc
    canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..shader = shader
          ..strokeWidth = stroke
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_V3RingPainter old) =>
      old.progress != progress || old.ringSize != ringSize;
}

// ── Floating Cards ────────────────────────────────────────────────────────────

class _FloatingCards extends StatelessWidget {
  final int scanCount;
  final int dailyGoal;
  final int streak;

  const _FloatingCards(
      {required this.scanCount, required this.dailyGoal, required this.streak});

  @override
  Widget build(BuildContext context) {
    final remaining = (dailyGoal - scanCount).clamp(0, dailyGoal);
    final pct = dailyGoal > 0 ? (scanCount / dailyGoal * 100).round() : 0;
    return Row(
      children: [
        Expanded(
            child: _FloatCard(
          iconColors: const [Color(0xFFFFC78A), AppColors.dashOrange],
          icon: Icons.local_fire_department_rounded,
          label: 'Streak',
          value: '$streak',
          unit: 'days',
          hint: 'Best 12 days',
        )),
        const SizedBox(width: 12),
        Expanded(
            child: _FloatCard(
          iconColors: const [AppColors.dashTeal, AppColors.dashTealDark],
          icon: Icons.my_location_rounded,
          label: 'Remaining',
          value: '$remaining',
          unit: 'scans',
          hint: '$pct% complete',
        )),
      ],
    );
  }
}

class _FloatCard extends StatelessWidget {
  final List<Color> iconColors;
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String hint;

  const _FloatCard(
      {required this.iconColors,
      required this.icon,
      required this.label,
      required this.value,
      required this.unit,
      required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.dashDeep.withValues(alpha: 0.28),
              blurRadius: 36,
              offset: const Offset(0, 16),
              spreadRadius: -20)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: iconColors),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.dashTealDark.withValues(alpha: 0.40),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                          spreadRadius: -4)
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 12),
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.dashMid)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dashDeep,
                            letterSpacing: -1)),
                    const SizedBox(width: 4),
                    Text(unit,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dashMid)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(hint,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.dashMid.withValues(alpha: 0.70))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Launch Button ─────────────────────────────────────────────────────────────

class _V3LaunchButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isChecking;
  final bool isUploading;
  final double screenWidth;

  const _V3LaunchButton(
      {required this.onTap,
      required this.isChecking,
      required this.isUploading,
      required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final busy = isChecking || isUploading;
    final btnH = (screenWidth * 0.19).clamp(68.0, 80.0);
    final iconSz = (btnH * 0.68).clamp(46.0, 56.0);
    final arrowSz = (btnH * 0.78).clamp(52.0, 62.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.65 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: btnH,
          decoration: BoxDecoration(
            color: AppColors.dashDeep,
            borderRadius: BorderRadius.circular(btnH / 2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.dashDeep.withValues(alpha: 0.55),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                  spreadRadius: -14)
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Shimmer
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x4034D6C2),
                          Colors.transparent
                        ],
                        stops: [0.3, 0.5, 0.7],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: iconSz,
                      height: iconSz,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.dashTeal,
                              AppColors.dashTealDark
                            ]),
                        borderRadius: BorderRadius.circular(iconSz * 0.33),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.dashTeal.withValues(alpha: 0.60),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                              spreadRadius: -4)
                        ],
                      ),
                      child: busy
                          ? const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5)))
                          : const Icon(Icons.qr_code_scanner_rounded,
                              color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            busy
                                ? (isChecking
                                    ? 'Checking Product…'
                                    : 'Uploading…')
                                : 'Start Collection',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    (screenWidth * 0.046).clamp(16.0, 19.0),
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            busy
                                ? 'Please wait'
                                : 'Scanner ready · Tap to launch',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize:
                                    (screenWidth * 0.030).clamp(11.0, 13.0)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: arrowSz,
                      height: arrowSz,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.dashTeal,
                              AppColors.dashTealMid
                            ]),
                        borderRadius: BorderRadius.circular(arrowSz * 0.35),
                      ),
                      child: Icon(
                          busy
                              ? Icons.hourglass_top_rounded
                              : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Capture guide sheet ───────────────────────────────────────────────────────

// ── Shared ────────────────────────────────────────────────────────────────────

class _BarcodeChip extends StatelessWidget {
  final String barcode;
  const _BarcodeChip({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.qr_code, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(barcode,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ignore: unused_element
class _RecentScansSection extends StatelessWidget {
  final List<_ScanEntry> scans;
  const _RecentScansSection({required this.scans});

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    return '${d.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: scans
            .take(5)
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.inventory_2_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(e.barcode,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600))),
                      Text(_timeAgo(e.time),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textLight)),
                    ]),
                  ),
                ))
            .toList(),
      );
}
