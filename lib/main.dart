import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart' as di;
import 'core/network/connectivity_service.dart';
import 'core/notifications/fcm_service.dart';
import 'core/sync/sync_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/product/presentation/bloc/dashboard_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        title: AppStrings.appTitle,
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
        builder: (context, child) => _ConnectivityWrapper(
          child: child ?? const SizedBox.shrink(),
        ),
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
  final ValueNotifier<SyncProgress?> _syncProgress = ValueNotifier(null);
  Timer? _syncCompleteTimer;

  @override
  void initState() {
    super.initState();
    _connectivity = di.sl<ConnectivityService>();
    _syncService = di.sl<SyncService>();
    _connectivitySub = _connectivity.onStatusChange.listen(_onStatusChange);
    _syncSub = _syncService.syncProgress$.listen(_onSyncProgress);
  }

  void _onSyncProgress(SyncProgress p) {
    if (!mounted) return;

    if (p.isDone) {
      _showSyncOverlay(p);
      _syncCompleteTimer?.cancel();
      _syncCompleteTimer = Timer(const Duration(seconds: 4), _hideSyncOverlay);
      return;
    }

    _syncCompleteTimer?.cancel();
    _showSyncOverlay(p);
  }

  void _showSyncOverlay(SyncProgress progress) {
    _syncProgress.value = progress;
  }

  void _hideSyncOverlay() {
    _syncProgress.value = null;
  }

  void _onStatusChange(bool isOnline) {
    if (!mounted) return;
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;
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
                  ? AppStrings.backOnlineSyncing
                  : AppStrings.noInternetConnection,
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

  @override
  void dispose() {
    _syncCompleteTimer?.cancel();
    _hideSyncOverlay();
    _connectivitySub?.cancel();
    _syncSub?.cancel();
    _syncProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        _SyncProgressOverlay(progressListenable: _syncProgress),
      ],
    );
  }
}

class _SyncProgressOverlay extends StatelessWidget {
  final ValueListenable<SyncProgress?> progressListenable;

  const _SyncProgressOverlay({required this.progressListenable});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: IgnorePointer(
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: ValueListenableBuilder<SyncProgress?>(
              valueListenable: progressListenable,
              builder: (context, progress, _) {
                if (progress == null) return const SizedBox.shrink();

                final isDone = progress.isDone;
                final progressValue = progress.total > 0
                    ? progress.current / progress.total
                    : null;

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xff0B7285),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        if (isDone)
                          const Icon(
                            Icons.cloud_done_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        else
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: progressValue,
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isDone
                                ? AppStrings.syncComplete(progress.total)
                                : AppStrings.syncProgress(
                                    progress.current,
                                    progress.total,
                                  ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
