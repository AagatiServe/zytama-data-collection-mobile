import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zytama_data/features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/product_bloc.dart';
import 'barcode_scanner_screen.dart';
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
  final _picker = ImagePicker();
  int _scanCount = 0;
  static const int _dailyGoal = 60;
  static const int _streak = 5;
  final List<_ScanEntry> _recentScans = [];

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openScanner());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Scanner ───────────────────────────────────────────────────────────────

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

  // ── Image capture helpers ─────────────────────────────────────────────────

  Future<void> _capture({
    required String label,
    required String instruction,
    required String? barcode,
    required IconData icon,
    required Color iconColor,
    required int stepNumber,
    required void Function(File) onCaptured,
  }) async {
    final proceed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CaptureGuideSheet(
        stepNumber: stepNumber,
        totalSteps: 4,
        label: label,
        instruction: instruction,
        barcode: barcode,
        icon: icon,
        iconColor: iconColor,
      ),
    );
    if (!mounted) return;
    if (proceed != true) {
      context.read<ProductBloc>().add(ResetProduct());
      _openScanner();
      return;
    }
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (!mounted) return;
    if (x != null) {
      onCaptured(File(x.path));
    } else {
      context.read<ProductBloc>().add(ResetProduct());
      _openScanner();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Auth
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (r) => false,
              );
            }
          },
        ),

        // Product flow
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
                      const Text('This product is already in the database.'),
                      const SizedBox(height: 8),
                      _BarcodeChip(barcode: state.barcode),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              if (!context.mounted) return;
              context.read<ProductBloc>().add(ResetProduct());
              _openScanner();
            } else if (state is ProductNotExists) {
              await _capture(
                stepNumber: 1,
                label: 'Front Photo',
                instruction: 'Photograph the front of the product',
                barcode: state.barcode,
                icon: Icons.inventory_2_rounded,
                iconColor: Colors.blue,
                onCaptured: (f) =>
                    context.read<ProductBloc>().add(ProductImageCaptured(f)),
              );
            } else if (state is CapturingBarcodeImage) {
              await _capture(
                stepNumber: 2,
                label: 'Barcode Photo',
                instruction: 'Photograph the barcode on the product',
                barcode: null,
                icon: Icons.qr_code_rounded,
                iconColor: Colors.deepPurple,
                onCaptured: (f) => context
                    .read<ProductBloc>()
                    .add(BarcodeImageCaptured(f)),
              );
            } else if (state is CapturingIngredientsImage) {
              await _capture(
                stepNumber: 3,
                label: 'Ingredients Photo',
                instruction: 'Photograph the ingredients label',
                barcode: null,
                icon: Icons.list_alt_rounded,
                iconColor: Colors.orange,
                onCaptured: (f) => context
                    .read<ProductBloc>()
                    .add(IngredientsImageCaptured(f)),
              );
            } else if (state is ReadyToReview) {
              final capturedBarcode = state.barcode;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductReviewScreen(
                    barcode: capturedBarcode,
                    initialProductImage: state.productImage,
                    initialBarcodeImage: state.barcodeImage,
                    initialIngredientsImage: state.ingredientsImage,
                    onSuccess: () => setState(() {
                      _scanCount++;
                      _recentScans.insert(
                          0,
                          _ScanEntry(
                              barcode: capturedBarcode,
                              time: DateTime.now()));
                      if (_recentScans.length > 10) _recentScans.removeLast();
                    }),
                  ),
                ),
              );
              if (!context.mounted) return;
              final s = context.read<ProductBloc>().state;
              if (s is ProductInitial) _openScanner();
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
                        child: const Text('OK')),
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
        backgroundColor: const Color(0xFFF3FAFF),
        body: Stack(
          children: [
            // Mesh blobs
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA3F69C).withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0d631b).withValues(alpha: 0.05),
                ),
              ),
            ),

            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final user = authState is AuthAuthenticated
                            ? authState.user
                            : null;
                        final name = user?.name.isNotEmpty == true
                            ? user!.name
                            : 'User';
                        final agentCode = user?.agentCode.isNotEmpty == true
                            ? user!.agentCode
                            : '';
                        return _Header(
                          name: name,
                          agentCode: agentCode,
                          onNotificationTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationScreen(),
                            ),
                          ),
                          onLogoutTap: () => _confirmLogout(context),
                        );
                      },
                    ),
                  ),

                  // Circular progress ring
                  SliverToBoxAdapter(
                    child: _ProgressSection(
                      scanCount: _scanCount,
                      dailyGoal: _dailyGoal,
                      streak: _streak,
                      pulseCtrl: _pulseCtrl,
                    ),
                  ),

                  // Launch button
                  SliverToBoxAdapter(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        final idle = state is ProductInitial ||
                            state is ProductScanning;
                        return _LaunchButton(
                          onTap: idle ? _openScanner : null,
                          isChecking: state is ProductChecking,
                          isUploading: state is ProductUploading,
                        );
                      },
                    ),
                  ),

                  // Recent scans
                  SliverToBoxAdapter(
                    child: _RecentScansSection(scans: _recentScans),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 48)),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String name;
  final String agentCode;
  final VoidCallback onNotificationTap;
  final VoidCallback onLogoutTap;

  const _Header({
    required this.name,
    required this.agentCode,
    required this.onNotificationTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
      child: Row(
        children: [
          // Avatar with check badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0d631b).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0d631b), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0d631b).withValues(alpha: 0.20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0d631b),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -3,
                right: -3,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d631b),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFF3FAFF), width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 11),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agentCode.isNotEmpty ? agentCode : 'AGENT',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF40493d),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hello, $name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF071e27),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          // Notification button
          _IconBtn(
            icon: Icons.notifications_outlined,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: 10),
          // Logout button
          _IconBtn(
            icon: Icons.logout_rounded,
            color: Colors.red.shade400,
            bgColor: Colors.red.withValues(alpha: 0.08),
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}

// ── Reusable icon button ──────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF40493d),
    this.bgColor = const Color(0xFFDBF1FE),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ── Progress Section ──────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final int scanCount;
  final int dailyGoal;
  final int streak;
  final AnimationController pulseCtrl;

  const _ProgressSection({
    required this.scanCount,
    required this.dailyGoal,
    required this.streak,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        dailyGoal > 0 ? (scanCount / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = (dailyGoal - scanCount).clamp(0, dailyGoal);
    final percent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Circular ring
          SizedBox(
            width: 270,
            height: 270,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(270, 270),
                  painter: _RingPainter(progress: progress),
                ),
                // Animated inner pulse ring
                AnimatedBuilder(
                  animation: pulseCtrl,
                  builder: (_, __) {
                    final scale = 0.95 + pulseCtrl.value * 0.10;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 195,
                        height: 195,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0d631b)
                                .withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Center label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$scanCount',
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0d631b),
                              height: 1.0,
                              letterSpacing: -2,
                            ),
                          ),
                          TextSpan(
                            text: ' / $dailyGoal',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF40493d),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "TODAY'S SCANS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF40493d),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Streak badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCFE6F2).withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: const Color(0xFFBFCABA).withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFFC107)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$streak Day Streak!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF071e27),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF40493d),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "You're "),
                  TextSpan(
                    text: '$percent%',
                    style: const TextStyle(
                      color: Color(0xFF0d631b),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' of the way there! '),
                  TextSpan(
                    text: '$remaining more',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' to hit your daily target.'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

// ── Ring Painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFFCFE6F2).withValues(alpha: 0.40)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: const [Color(0xFF1b6d24), Color(0xFF88d982)],
    );
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Launch Button ─────────────────────────────────────────────────────────────

class _LaunchButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isChecking;
  final bool isUploading;

  const _LaunchButton({
    required this.onTap,
    required this.isChecking,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final busy = isChecking || isUploading;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: onTap == null ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0d631b), Color(0xFF2e7d32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0d631b).withValues(alpha: 0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: busy
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : const Icon(Icons.qr_code_scanner_rounded,
                          color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                // Labels
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        busy ? 'Please wait' : 'Launch Scanner',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    busy
                        ? Icons.hourglass_top_rounded
                        : Icons.arrow_forward_rounded,
                    color: const Color(0xFF0d631b),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recent Scans ──────────────────────────────────────────────────────────────

class _RecentScansSection extends StatelessWidget {
  final List<_ScanEntry> scans;
  const _RecentScansSection({required this.scans});

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Scans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF071e27),
                ),
              ),
              const Spacer(),
              if (scans.isNotEmpty) ...[
                const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0d631b),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF0d631b), size: 18),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (scans.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(children: [
                Icon(Icons.inventory_2_outlined,
                    size: 36, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'No scans yet today',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ]),
            )
          else
            ...scans.take(5).map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ScanCard(
                      entry: entry, timeAgo: _timeAgo(entry.time)),
                )),
        ],
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final _ScanEntry entry;
  final String timeAgo;
  const _ScanCard({required this.entry, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0d631b).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: Color(0xFF0d631b), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.barcode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF071e27),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF40493d),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF0d631b), size: 22),
        ],
      ),
    );
  }
}

// ── Capture guide sheet ───────────────────────────────────────────────────────

class _CaptureGuideSheet extends StatelessWidget {
  final int stepNumber;
  final int totalSteps;
  final String label;
  final String instruction;
  final String? barcode;
  final IconData icon;
  final Color iconColor;

  const _CaptureGuideSheet({
    required this.stepNumber,
    required this.totalSteps,
    required this.label,
    required this.instruction,
    required this.barcode,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          // Step dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (i) {
              final active = i + 1 == stepNumber;
              final done = i + 1 < stepNumber;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: active ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: active
                      ? iconColor
                      : done
                          ? iconColor.withValues(alpha: 0.35)
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            'Step $stepNumber of $totalSteps  •  $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: iconColor,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF071e27),
              height: 1.3,
            ),
          ),
          if (barcode != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.qr_code, size: 15, color: Colors.grey),
                const SizedBox(width: 6),
                Text(barcode!,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFF071e27))),
              ]),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text('Open Camera',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0d631b),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

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
        border: Border.all(color: Colors.grey.shade300),
      ),
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
