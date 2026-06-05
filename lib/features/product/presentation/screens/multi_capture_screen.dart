import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:zytama_data/core/constants/app_colors.dart';

class _StepConfig {
  final String label;
  final String instruction;
  final IconData icon;
  final Color color;
  const _StepConfig({
    required this.label,
    required this.instruction,
    required this.icon,
    required this.color,
  });
}

class MultiCaptureScreen extends StatefulWidget {
  final String barcode;
  const MultiCaptureScreen({super.key, required this.barcode});

  @override
  State<MultiCaptureScreen> createState() => _MultiCaptureScreenState();
}

class _MultiCaptureScreenState extends State<MultiCaptureScreen> {
  static const _steps = [
    _StepConfig(
      label: 'Product Photo',
      instruction: 'Photograph the\nfront of the product',
      icon: Icons.inventory_2_rounded,
      color: Color(0xff0A6475),
    ),
    _StepConfig(
      label: 'Ingredients Photo',
      instruction: 'Photograph the\ningredients label',
      icon: Icons.list_alt_rounded,
      color: Color(0xff7B2FBE),
    ),
    _StepConfig(
      label: 'Nutrition Photo',
      instruction: 'Photograph the\nnutrition facts label',
      icon: Icons.restaurant_menu_rounded,
      color: Color(0xffE07B29),
    ),
  ];

  CameraController? _ctrl;
  int _step = 0;
  final List<File> _captured = [];
  bool _taking = false;
  bool _flash = false;
  Timer? _sheetTimer;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;
    final rear = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _ctrl = CameraController(rear, ResolutionPreset.high, enableAudio: false);
    await _ctrl!.initialize();
    if (mounted) {
      setState(() {});
      _showStepSheet();
    }
  }

  void _showStepSheet() {
    if (!mounted || _sheetOpen) return;
    _sheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (_) => _StepGuideSheet(
        step: _steps[_step],
        stepNumber: _step + 1,
        totalSteps: _steps.length,
        barcode: _step == 0 ? widget.barcode : null,
      ),
    ).then((_) {
      _sheetOpen = false;
      _sheetTimer?.cancel();
    });

    _sheetTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _sheetOpen) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _sheetTimer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_ctrl == null || !_ctrl!.value.isInitialized || _taking) return;
    setState(() {
      _taking = true;
      _flash = true;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _flash = false);
    });

    final xFile = await _ctrl!.takePicture();
    _captured.add(File(xFile.path));

    if (!mounted) return;

    if (_step < _steps.length - 1) {
      setState(() {
        _step++;
        _taking = false;
      });
      _showStepSheet();
    } else {
      Navigator.of(context).pop(_captured);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialized = _ctrl?.value.isInitialized ?? false;
    final step = _steps[_step];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (initialized)
            CameraPreview(_ctrl!)
          else
            const Center(
                child: CircularProgressIndicator(color: Colors.white)),

          if (_flash) Container(color: Colors.white.withValues(alpha: 0.6)),

          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(null),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Step ${_step + 1} of ${_steps.length}  •  ${step.label}',
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.instruction.replaceAll('\n', ' '),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (i) {
                        final active = i == _step;
                        final done = i < _step;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: active ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: done
                                ? Colors.white.withValues(alpha: 0.5)
                                : active
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Barcode chip
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      widget.barcode,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Shutter button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _taking ? null : _capture,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: _taking ? 36 : 54,
                            height: _taking ? 36 : 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _taking
                                  ? AppColors.primary.withValues(alpha: 0.6)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Guide Bottom Sheet ────────────────────────────────────────────────────

class _StepGuideSheet extends StatelessWidget {
  final _StepConfig step;
  final int stepNumber;
  final int totalSteps;
  final String? barcode;

  const _StepGuideSheet({
    required this.step,
    required this.stepNumber,
    required this.totalSteps,
    this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _BottomSheetClipper(),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 36),

                  // Progress bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: List.generate(totalSteps, (i) {
                        final active = i + 1 == stepNumber;
                        final done = i + 1 < stepNumber;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                right: i < totalSteps - 1 ? 6 : 0),
                            height: 4,
                            decoration: BoxDecoration(
                              color: (active || done)
                                  ? step.color
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Icon box
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(step.icon, size: 34, color: step.color),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Step $stepNumber of $totalSteps  •  ${step.label}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: step.color,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      step.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Color(0xff1A1A1A),
                      ),
                    ),
                  ),

                  if (barcode != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.qr_code,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(barcode!,
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Color(0xff1A1A1A))),
                      ]),
                    ),
                  ],

                  const Spacer(),

                  // Dismiss button
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        24, 0, 24, MediaQuery.paddingOf(context).bottom + 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 20),
                        label: const Text(
                          'Open Camera',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4CC5B8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating handle pill in the notch
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 62,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 26,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom clipper ─────────────────────────────────────────────────────────────

class _BottomSheetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 40;
    const double notchWidth = 110;
    const double notchDepth = 22;

    final path = Path();
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    final start = size.width / 2 - notchWidth / 2;
    final end = size.width / 2 + notchWidth / 2;

    path.lineTo(start, 0);
    path.cubicTo(start + 10, 0, start + 15, notchDepth, size.width / 2,
        notchDepth);
    path.cubicTo(end - 15, notchDepth, end - 10, 0, end, 0);

    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
