import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart' as di;
import 'core/network/connectivity_service.dart';
import 'core/notifications/fcm_service.dart';
import 'core/sync/sync_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/product/presentation/bloc/dashboard_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initFirebase();

  await di.init();
  // await di.sl<FcmService>().initialize();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<ProductBloc>(create: (_) => di.sl<ProductBloc>()),
        BlocProvider<DashboardBloc>(
          create: (_) => di.sl<DashboardBloc>()..add(DashboardLoadRequested()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Zytama',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.workSansTextTheme(),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 1,
            titleTextStyle: GoogleFonts.workSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        builder: (context, child) =>
            _ConnectivityWrapper(child: child ?? const SizedBox.shrink()),
        home: const SplashScreen(),
      ),
    );
  }
}

class _ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const _ConnectivityWrapper({required this.child});

  @override
  State<_ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<_ConnectivityWrapper> {
  late final ConnectivityService _connectivity;
  late final SyncService _syncService;
  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<SyncProgress>? _syncSub;
  SyncProgress? _currentSync;

  @override
  void initState() {
    super.initState();
    _connectivity = di.sl<ConnectivityService>();
    _syncService = di.sl<SyncService>();

    _connectivitySub = _connectivity.onStatusChange.listen(_onStatusChange);
    _syncSub = _syncService.syncProgress$.listen(_onSyncProgress);

    if (!_connectivity.isOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onStatusChange(false);
      });
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _syncSub?.cancel();
    super.dispose();
  }

  void _onStatusChange(bool isOnline) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              isOnline
                  ? 'Back online. Syncing data…'
                  : 'No internet connection.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor:
            isOnline ? const Color(0xff0B7285) : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isOnline ? 3 : 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _onSyncProgress(SyncProgress progress) {
    if (!mounted) return;
    setState(() => _currentSync = progress);

    if (progress.status == SyncStatus.completed) {
      // Refresh dashboard to get updated server counts
      try {
        context.read<DashboardBloc>().add(DashboardRefreshRequested());
      } catch (_) {}

      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cloud_done_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                '${progress.synced} product${progress.synced > 1 ? 's' : ''} synced successfully!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xff0B7285),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _currentSync = null);
      });
    } else if (progress.status == SyncStatus.failed) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.cloud_off_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Sync failed. Will retry later.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _currentSync = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncing =
        _currentSync != null && _currentSync!.status == SyncStatus.syncing;

    return Stack(
      children: [
        widget.child,
        if (syncing)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 4,
            left: 16,
            right: 16,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xff0B7285),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Syncing ${_currentSync!.synced}/${_currentSync!.total}…',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _currentSync!.total > 0
                                  ? _currentSync!.synced / _currentSync!.total
                                  : 0,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
