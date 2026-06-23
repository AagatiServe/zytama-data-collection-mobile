import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zytama_data/core/constants/app_colors.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _hasScanned = false;
  bool _isVerifying = false;
  bool? _permissionGranted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      _controller = MobileScannerController();
      setState(() => _permissionGranted = true);
    } else {
      setState(() => _permissionGranted = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller?.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller?.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    _hasScanned = true;
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 400));
    // Stop and dispose the scanner before popping so the camera hardware
    // is released before the next screen tries to use it.
    await _controller?.stop();
    _controller?.dispose();
    _controller = null;
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        title: const Text('Scan Barcode'),
        actions: [
          if (_permissionGranted == true) ...[
            IconButton(
              tooltip: 'Toggle flash',
              icon: const Icon(Icons.flash_on_rounded),
              onPressed: () => _controller?.toggleTorch(),
            ),
            IconButton(
              tooltip: 'Flip camera',
              icon: const Icon(Icons.flip_camera_ios_rounded),
              onPressed: () => _controller?.switchCamera(),
            ),
          ],
        ],
      ),
      body: _permissionGranted == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _permissionGranted == false
              ? _PermissionDeniedView(onRetry: _initCamera)
              : Stack(

        children: [
          MobileScanner(controller: _controller!, onDetect: _onDetect),

          // Scan frame
          Center(
            child: Builder(builder: (context) {
              final scanSize = (MediaQuery.sizeOf(context).width * 0.65)
                  .clamp(200.0, 300.0);
              return Container(
              width: scanSize,
              height: scanSize,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  for (final alignment in [
                    Alignment.topLeft,
                    Alignment.topRight,
                    Alignment.bottomLeft,
                    Alignment.bottomRight,
                  ])
                    Align(
                      alignment: alignment,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            );
            }),
          ),

          // Instruction text
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.qr_code_scanner,
                    color: Colors.white54, size: 28),
                const SizedBox(height: 8),
                Text(
                  'Align the barcode within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
                ),
              ],
            ),
          ),

          // Verifying overlay — shown after barcode is detected
          if (_isVerifying)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Checking product…',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Please wait',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
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

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Camera permission required',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please allow camera access to scan barcodes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () async {
                await openAppSettings();
                onRetry();
              },
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
