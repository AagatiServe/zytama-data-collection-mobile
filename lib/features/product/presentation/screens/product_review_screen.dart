import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zytama_data/core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
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
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                      color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pinch_rounded,
                          color: Colors.white70, size: 16),
                      SizedBox(width: 6),
                      Text('Pinch to zoom',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) async {
        if (state is ProductUploadSuccess) {
          widget.onSuccess();
          await _showSuccessDialog();
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Review Product',
              style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              context.read<ProductBloc>().add(ResetProduct());
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            final uploading = state is ProductUploading;
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    _BarcodeCard(barcode: widget.barcode),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('Captured Images',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                              letterSpacing: 0.5)),
                    ),
                    _ImageCard(
                      label: 'Front Image',
                      stepColor: Colors.blue,
                      stepIcon: Icons.inventory_2_rounded,
                      image: _productImage,
                      onTap: () => _viewImage(_productImage, 'Front Image'),
                      onReplace: uploading ? null : () => _replaceImage(0),
                    ),
                    const SizedBox(height: 12),
                    _ImageCard(
                      label: 'Ingredients Image',
                      stepColor: Colors.deepPurple,
                      stepIcon: Icons.list_alt_rounded,
                      image: _ingredientsImage,
                      onTap: () =>
                          _viewImage(_ingredientsImage, 'Ingredients Image'),
                      onReplace: uploading ? null : () => _replaceImage(1),
                    ),
                    const SizedBox(height: 12),
                    _ImageCard(
                      label: 'Nutrition Image',
                      stepColor: Colors.orange,
                      stepIcon: Icons.restaurant_menu_rounded,
                      image: _nutritionImage,
                      onTap: () =>
                          _viewImage(_nutritionImage, 'Nutrition Image'),
                      onReplace: uploading ? null : () => _replaceImage(2),
                    ),
                  ],
                ),

                // Sticky submit bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                        16, 12, 16, MediaQuery.paddingOf(context).bottom + 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: uploading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: uploading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text('Submit Product',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                // Full-screen upload overlay
                if (uploading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text('Uploading…',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
          SizedBox(width: 8),
          Text('Uploaded!'),
        ]),
        content: const Text(
          'Product data has been uploaded successfully.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done'),
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.qr_code_rounded,
              color: AppColors.primary, size: 26),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Scanned Barcode',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(barcode,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: AppColors.textDark)),
        ]),
      ]),
    );
  }
}

// ── Image card ────────────────────────────────────────────────────────────────

class _ImageCard extends StatelessWidget {
  final String label;
  final Color stepColor;
  final IconData stepIcon;
  final File image;
  final VoidCallback onTap;
  final VoidCallback? onReplace;

  const _ImageCard({
    required this.label,
    required this.stepColor,
    required this.stepIcon,
    required this.image,
    required this.onTap,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
          child: Row(children: [
            Icon(stepIcon, color: stepColor, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (onReplace != null)
              TextButton.icon(
                onPressed: onReplace,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Replace', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: stepColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ]),
        ),
        GestureDetector(
          onTap: onTap,
          child: Stack(children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: Image.file(
                image,
                width: double.infinity,
                height: (MediaQuery.sizeOf(context).width * 0.55)
                    .clamp(160.0, 260.0),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Tap to zoom',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
