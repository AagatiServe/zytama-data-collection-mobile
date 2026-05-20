import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zytama_data/core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import 'login_screen.dart';
import 'package:zytama_data/features/product/presentation/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Icon: scale + fade  0.0 → 0.55
  late final Animation<double> _iconScale;
  late final Animation<double> _iconFade;

  // Title: slide-up + fade  0.35 → 0.70
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;

  // Subtitle: fade  0.55 → 0.80
  late final Animation<double> _subtitleFade;

  // Spinner: fade  0.72 → 1.0
  late final Animation<double> _spinnerFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );
    _iconFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 0.70, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
      ),
    );

    _spinnerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.72, 1.0, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) context.read<AuthBloc>().add(CheckAuthStatus());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.dashTealEnd,
                AppColors.primary,
                AppColors.dashMid,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                return Stack(
                  children: [
                    // Decorative background circles
                    Positioned(
                      top: -60,
                      right: -60,
                      child: Opacity(
                        opacity: 0.08,
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: const BoxDecoration(
                            color: AppColors.dashTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -80,
                      child: Opacity(
                        opacity: 0.06,
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App icon
                          FadeTransition(
                            opacity: _iconFade,
                            child: ScaleTransition(
                              scale: _iconScale,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.dashTeal
                                          .withValues(alpha: 0.45),
                                      blurRadius: 40,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.18),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(14),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 12, sigmaY: 12),
                                    child: Image.asset('assets/icon/icon.png',
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // App name
                          FadeTransition(
                            opacity: _titleFade,
                            child: Transform.translate(
                              offset: Offset(0, _titleSlide.value),
                              child: Text(
                                'Zytama Data',
                                style: GoogleFonts.workSans(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          FadeTransition(
                            opacity: _subtitleFade,
                            child: Text(
                              'Product Data Collection',
                              style: GoogleFonts.workSans(
                                color: Colors.white.withValues(alpha: 0.70),
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 72),

                          // Loading indicator
                          FadeTransition(
                            opacity: _spinnerFade,
                            child: const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom watermark
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _spinnerFade,
                        child: Text(
                          'Powered by Zytama',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
