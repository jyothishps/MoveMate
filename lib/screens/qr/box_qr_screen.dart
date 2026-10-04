import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // The label: this is also what gets saved as the picture.
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RepaintBoundary(
                key: _labelKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        box.boxName,
                        style: AppTextStyles.heading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'BOX ${box.shortCode}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      QrImageView(
                        data: box.qrData,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text('Box ID', style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      SelectableText(
                        box.id,
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This code holds only the box ID. No names or items are stored inside it.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save to Gallery',
              icon: Icons.download,
              isLoading: _isSaving,
              onPressed: _saveToGallery,
            ),
          ],
        ),
      ),
    );
  }
}