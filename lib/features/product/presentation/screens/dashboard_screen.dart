import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _DashboardScreenState extends State<DashboardScreen> {
  int _scanCount = 0;
  int _navIndex = 0;
  final List<_ScanEntry> _recentScans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openScanner());
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.logout_rounded, color: Colors.red, size: 22),
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

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
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
                        color: Colors.orange, size: 24),
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
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox()),
                        ),
                        const SizedBox(height: 10),
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
                  builder: (_) => MultiCaptureScreen(barcode: state.barcode),
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
                    Icon(Icons.error_rounded, color: Colors.red, size: 22),
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
        backgroundColor: const Color(0xffF5FAF5),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _navIndex,
          selectedItemColor: const Color(0xff1AA3A3),
          unselectedItemColor: Colors.grey,
          onTap: (i) {
            if (i == 1) {
              _openScanner();
            } else if (i == 2) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const NotificationScreen()));
            } else {
              setState(() => _navIndex = i);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.crop_free_rounded), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined), label: ''),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    // ── Header ──────────────────────────────────────────
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final user = authState is AuthAuthenticated
                            ? authState.user
                            : null;
                        final name = user?.name.isNotEmpty == true
                            ? user!.name
                            : 'Agent';
                        final initial = name[0].toUpperCase();
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xff0B7285)
                                  .withValues(alpha: 0.15),
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff0B7285),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, $name',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "Let's collect accurate ingredient data.",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _confirmLogout(context),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xff0B7285),
                                      width: 1.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.logout,
                                    color: Color(0xff0B7285), size: 20),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ── Search bar ───────────────────────────────────────
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                          prefixIcon: Icon(Icons.search,
                              size: 22, color: Color(0xff0B7285)),
                          hintText: 'Search products…',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Summary header ───────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1A1A1A)),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(DateTime.now()),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Summary cards ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.crop_free,
                            count: '$_scanCount',
                            label: 'Products\nScanned',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.check_circle_outline,
                            count: '$_scanCount',
                            label: 'Successfully\nCaptured',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _SummaryCard(
                            icon: Icons.sync,
                            count: '0',
                            label: 'Pending\nSync',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── New Scan button ──────────────────────────────────
                    BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        final busy = state is ProductChecking ||
                            state is ProductUploading;
                        return GestureDetector(
                          onTap: busy ? null : _openScanner,
                          child: Container(
                            height: 76,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xff005F73),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  busy
                                      ? Icons.hourglass_top_rounded
                                      : Icons.document_scanner_outlined,
                                  size: 32,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        busy ? 'Processing…' : 'New Scan',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        busy
                                            ? 'Please wait'
                                            : 'Scan ingredient label using camera',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                if (busy)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                else
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      color: Colors.white70, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // ── Recent Scans header ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Scans',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1A1A1A)),
                        ),
                        if (_recentScans.isNotEmpty)
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                  color: Color(0xff0B7285),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Recent Scans list ────────────────────────────────
                    if (_recentScans.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        alignment: Alignment.center,
                        child: const Text(
                          'No scans yet. Tap New Scan to start.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      )
                    else
                      ...(_recentScans.take(5).map((e) => _RecentScanCard(
                            barcode: e.barcode,
                            timeAgo: _timeAgo(e.time),
                          ))),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Checking overlay ─────────────────────────────────────────
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is! ProductChecking) return const SizedBox.shrink();
                return Container(
                  color: Colors.black.withValues(alpha: 0.50),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                              color: Color(0xff0B7285), strokeWidth: 3),
                          const SizedBox(height: 16),
                          const Text('Checking product…',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff1A1A1A))),
                          const SizedBox(height: 4),
                          Text(state.barcode,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Colors.grey)),
                        ],
                      ),
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
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffD9F0EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xff0B7285), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// ── Recent Scan Card ──────────────────────────────────────────────────────────

class _RecentScanCard extends StatelessWidget {
  final String barcode;
  final String timeAgo;

  const _RecentScanCard({required this.barcode, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xffD9F0EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: Color(0xff0B7285), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barcode,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Product  •  $timeAgo',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xffE5F6EE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Captured',
              style: TextStyle(
                  color: Color(0xff0E9F6E),
                  fontWeight: FontWeight.w600,
                  fontSize: 11),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xff0B7285), size: 18),
        ],
      ),
    );
  }
}

// ── Barcode chip (used in dialogs) ────────────────────────────────────────────

class _BarcodeChip extends StatelessWidget {
  final String barcode;
  const _BarcodeChip({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.qr_code, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(barcode,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
