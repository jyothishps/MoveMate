import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_packing_app/core/theme/app_text_styles.dart';
import 'package:qr_packing_app/core/utils/qr_parser.dart';
import 'package:qr_packing_app/screens/box/box_details_screen.dart';
import 'package:qr_packing_app/services/auth_service.dart';
import 'package:qr_packing_app/services/box_service.dart';
import 'package:qr_packing_app/services/database_exception.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';
import 'package:qr_packing_app/widgets/primary_button.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  static const Duration _duplicateWindow = Duration(seconds: 3);

  final _boxService = BoxService();
  late MobileScannerController _controller;

  bool _isProcessing = false;
  String? _lastValue;
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  MobileScannerController _createController() {
    // Only QR codes are read; other barcode types are ignored.
    return MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Used by the "Try again" button after a camera error.
  void _restartScanner() {
    _controller.dispose();
    setState(() => _controller = _createController());
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    // Ignore new scans while one is already being handled.
    if (_isProcessing || capture.barcodes.isEmpty) return;

    final rawValue = capture.barcodes.first.rawValue;

    // Ignore the same code if it was just scanned (duplicate scans).
    final now = DateTime.now();
    final lastTime = _lastScanTime;
    if (rawValue == _lastValue &&
        lastTime != null &&
        now.difference(lastTime) < _duplicateWindow) {
      return;
    }
    _lastValue = rawValue;
    _lastScanTime = now;

    setState(() => _isProcessing = true);

    try {
      // 1. Read the box ID from the QR text.
      final boxId = QrParser.parseBoxId(rawValue);
      if (boxId == null) {
        _showMessage('This is not a MoveMate box QR code.');
        return;
      }

      // 2. The user must be logged in.
      final user = AuthService().currentUser;
      if (user == null) {
        _showMessage('Please log in again.');
        return;
      }

      // 3. Look for the box among THIS user's boxes only.
      final box = await _boxService.getUserBox(boxId, user.uid);
      if (!mounted) return;
      if (box == null) {
        _showMessage(
          'Box not found. It may have been deleted, or it belongs to another account.',
        );
        return;
      }

      // Remember when this box was scanned (used by the dashboard).
      _boxService.markScanned(box.id);

      // 4. Open the box, then ignore the same code for a few seconds.
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BoxDetailsScreen(boxId: box.id)),
      );
      _lastValue = rawValue;
      _lastScanTime = DateTime.now();
    } on DatabaseException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              key: ObjectKey(_controller),
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) =>
                  _ScannerError(error: error, onRetry: _restartScanner),
            ),
          ),
          // The frame and hint only appear while the camera is running.
          Positioned.fill(
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                if (!state.isRunning) return const SizedBox.shrink();
                return Stack(
                  children: [
                    const Center(child: _ScanFrame()),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: _StatusCard(isProcessing: _isProcessing),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isProcessing;

  const _StatusCard({required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (isProcessing) ...[
              const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                isProcessing
                    ? 'Looking up box...'
                    : 'Point the camera at a MoveMate box QR code',
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  final MobileScannerException error;
  final VoidCallback onRetry;

  const _ScannerError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmptyState(
            icon: denied ? Icons.no_photography_outlined : Icons.error_outline,
            title: denied ? 'Camera permission needed' : 'Camera unavailable',
            message: denied
                ? 'Allow camera access in Settings > Apps > MoveMate > '
                'Permissions, then tap Try again.'
                : 'The camera could not be started. Close other apps that '
                'use the camera, then tap Try again.',
          ),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Try again', onPressed: onRetry),
        ],
      ),
    );
  }
}