import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:zytama_data/core/constants/app_colors.dart';

class _StepConfig {
  final String label;
  final String instruction;
  final IconData icon;
  const _StepConfig({
    required this.label,
    required this.instruction,
    required this.icon,
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
      instruction: 'Photograph the front of the product',
      icon: Icons.inventory_2_rounded,
    ),
    _StepConfig(
      label: 'Ingredients Photo',
      instruction: 'Photograph the ingredients label',
      icon: Icons.list_alt_rounded,
    ),
    _StepConfig(
      label: 'Nutrition Photo',
      instruction: 'Photograph the nutrition facts label',
      icon: Icons.restaurant_menu_rounded,
    ),
  ];

  CameraController? _ctrl;
  int _step = 0;
  final List<File> _captured = [];
  bool _taking = false;
  bool _flash = false;

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
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
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

          // Flash overlay
          if (_flash) Container(color: Colors.white.withValues(alpha: 0.6)),

          // Top gradient + step info
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
                                step.instruction,
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
                    // Step dots
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
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code,
                        size: 14, color: Colors.white70),
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

          // Bottom gradient + shutter
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
