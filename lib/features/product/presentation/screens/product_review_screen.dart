import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/product_bloc.dart';

class ProductReviewScreen extends StatefulWidget {
  final String barcode;
  final File initialProductImage;
  final File initialIngredientsImage;
  final File initialNutritionImage;
  final VoidCallback onSuccess;

  const ProductReviewScreen({
    super.key,
    required this.barcode,
    required this.initialProductImage,
    required this.initialIngredientsImage,
    required this.initialNutritionImage,
    required this.onSuccess,
  });

  @override
  State<ProductReviewScreen> createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {
  late File _productImage;
  late File _ingredientsImage;
  late File _nutritionImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _productImage = widget.initialProductImage;
    _ingredientsImage = widget.initialIngredientsImage;
    _nutritionImage = widget.initialNutritionImage;
  }

  Future<void> _replaceImage(int index) async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (x == null || !mounted) return;
    setState(() {
      switch (index) {
        case 0:
          _productImage = File(x.path);
        case 1:
          _ingredientsImage = File(x.path);
        case 2:
          _nutritionImage = File(x.path);
      }
    });
  }

  void _viewImage(File image, String label) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            SizedBox.expand(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 6.0,
                child: Image.file(image, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            Positioned(
              top: 44,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.50),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded,
                          color: Colors.white70, size: 14),
                      SizedBox(width: 5),
                      Text(AppStrings.pinchToZoom,
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    context.read<ProductBloc>().add(SubmitProduct(
          productImage: _productImage,
          ingredientsImage: _ingredientsImage,
          nutritionImage: _nutritionImage,
        ));
  }

  Future<void> _showSuccessDialog({required bool offline}) {
    final color = offline ? const Color(0xffF59E0B) : Colors.green;
    final icon = offline ? Icons.cloud_off_rounded : Icons.check_circle_rounded;
    final title = offline ? AppStrings.savedOffline : AppStrings.uploaded;
    final message =
        offline ? AppStrings.productSavedOffline : AppStrings.productUploaded;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 8),
          Text(title),
        ]),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(AppStrings.done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) async {
        if (state is ProductUploadSuccess) {
          widget.onSuccess();
          await _showSuccessDialog(offline: false);
          if (!context.mounted) return;
          context.read<ProductBloc>().add(ResetProduct());
          Navigator.of(context).pop();
        } else if (state is ProductUploadSavedOffline) {
          widget.onSuccess();
          await _showSuccessDialog(offline: true);
          if (!context.mounted) return;
          context.read<ProductBloc>().add(ResetProduct());
          Navigator.of(context).pop();
        } else if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF8FBF8),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            final uploading = state is ProductUploading ||
                state is ProductUploadSavedOffline ||
                state is ProductUploadSuccess;
            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      // ── Header ────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xffDDF4E8),
                              Color(0xffEEF9F0),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.read<ProductBloc>().add(ResetProduct());
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  size: 20),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              AppStrings.reviewProduct,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),

                      // ── Scrollable body ───────────────────────────────
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          children: [
                            // Barcode card
                            _BarcodeCard(barcode: widget.barcode),

                            const SizedBox(height: 20),

                            // Captured Images title
                            const Row(
                              children: [
                                Icon(Icons.image,
                                    color: Color(0xff0A6475), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  AppStrings.capturedImages,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            _CaptureCard(
                              number: '01',
                              title: AppStrings.productPhoto,
                              color: const Color(0xff88DDD6),
                              image: _productImage,
                              onTap: () => _viewImage(
                                  _productImage, AppStrings.productPhotoPlain),
                              onReplace:
                                  uploading ? null : () => _replaceImage(0),
                            ),

                            const SizedBox(height: 12),

                            _CaptureCard(
                              number: '02',
                              title: AppStrings.ingredientsPhoto,
                              color: const Color(0xffB39DDB),
                              image: _ingredientsImage,
                              onTap: () => _viewImage(_ingredientsImage,
                                  AppStrings.ingredientsPhotoPlain),
                              onReplace:
                                  uploading ? null : () => _replaceImage(1),
                            ),

                            const SizedBox(height: 12),

                            _CaptureCard(
                              number: '03',
                              title: AppStrings.nutritionPhoto,
                              color: const Color(0xffFFCC80),
                              image: _nutritionImage,
                              onTap: () => _viewImage(_nutritionImage,
                                  AppStrings.nutritionPhotoPlain),
                              onReplace:
                                  uploading ? null : () => _replaceImage(2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Submit bar ────────────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        16, 12, 16, MediaQuery.paddingOf(context).bottom + 12),
                    color: Colors.white,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: uploading ? null : _submit,
                        icon: uploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.upload_outlined, size: 20),
                        label: Text(
                          uploading
                              ? AppStrings.uploading
                              : AppStrings.submitProduct,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4CC6B7),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xff4CC6B7).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Upload overlay ────────────────────────────────────────
                if (uploading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 14),
                          Text(AppStrings.uploading,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Barcode card ──────────────────────────────────────────────────────────────

class _BarcodeCard extends StatelessWidget {
  final String barcode;
  const _BarcodeCard({required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff4BD0C0), Color(0xffA6F3D9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.qr_code_2, size: 40, color: Color(0xff0A6475)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(AppStrings.scannedSuccessfully,
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(AppStrings.scannedBarcode,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  barcode,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: Colors.green, size: 28),
          ),
        ],
      ),
    );
  }
}

// ── Capture card ──────────────────────────────────────────────────────────────

class _CaptureCard extends StatelessWidget {
  final String number;
  final String title;
  final Color color;
  final File image;
  final VoidCallback onTap;
  final VoidCallback? onReplace;

  const _CaptureCard({
    required this.number,
    required this.title,
    required this.color,
    required this.image,
    required this.onTap,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // Left info panel
          Container(
            width: 110,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: color.withValues(alpha: 0.85),
                      height: 1.0),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, height: 1.3),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Spacer(),
                if (onReplace != null)
                  SizedBox(
                    height: 30,
                    child: OutlinedButton.icon(
                      onPressed: onReplace,
                      icon: const Icon(Icons.refresh, size: 13),
                      label: const Text(AppStrings.replace,
                          style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color.withValues(alpha: 0.9),
                        side: BorderSide(
                            color: color.withValues(alpha: 0.5), width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Right image
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    child: Image.file(
                      image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.48),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 3),
                          Text(AppStrings.zoom,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
