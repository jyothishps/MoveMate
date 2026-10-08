import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_packing_app/core/constants/app_constants.dart';
import 'package:qr_packing_app/core/theme/app_colors.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/models/box_model.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class BoxQrScreen extends StatefulWidget {
  final BoxModel box;

  const BoxQrScreen({super.key, required this.box});

  @override
  State<BoxQrScreen> createState() => _BoxQrScreenState();
}

class _BoxQrScreenState extends State<BoxQrScreen> {
  // Lets us take a picture of the label widget.
  final GlobalKey _labelKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveToGallery() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    try {
      // 1. Turn the label on screen into PNG image data.
      final boundary =
      _labelKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not create the image');
      }
      final bytes = byteData.buffer.asUint8List();

      // 2. Make sure we are allowed to save to the gallery.
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Permission denied. Allow gallery access to save.'),
            ),
          );
          return;
        }
      }

      // 3. Save it.
      await Gal.putImageBytes(bytes);
      messenger.showSnackBar(
        const SnackBar(content: Text('QR code saved to your gallery')),
      );
    } on GalException {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save the image.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.box;
    final catColor = AppColors.categoryColor(box.category);
    final catIcon = AppConstants.categoryIcon(box.category);

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // The label: this is also what gets saved as the picture.
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: RepaintBoundary(
                  key: _labelKey,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Industrial Category Header Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          color: catColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(catIcon, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    box.category.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                box.location.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                box.boxName,
                                style: AppTextStyles.heading.copyWith(
                                  fontSize: 22,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'BOX ${box.shortCode}',
                                  style: AppTextStyles.shortCode.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Semantics(
                                  image: true,
                                  label: 'QR code for box ${box.boxName}',
                                  child: QrImageView(
                                    data: box.qrData,
                                    version: QrVersions.auto,
                                    size: 200,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'MOVEMATE SMART PACKING LABEL',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                box.id,
                                style: AppTextStyles.caption.copyWith(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This label can be printed or attached to your packing box.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save to Gallery',
              icon: Icons.download_rounded,
              isLoading: _isSaving,
              onPressed: _saveToGallery,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}