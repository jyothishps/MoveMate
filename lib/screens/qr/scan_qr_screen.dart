import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
                    // Dimmed camera mask outside scan reticle
                    const Positioned.fill(
                      child: CustomPaint(
                        painter: _VignetteCutoutPainter(
                          cutoutSize: 260,
                          borderRadius: 20,
                        ),
                      ),
                    ),
                    // High-tech corner bracket reticle with animated laser
                    const Center(child: _ScanReticle()),
                    // Floating frosted glass instruction card
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 30,
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

class _ScanReticle extends StatefulWidget {
  const _ScanReticle();

  @override
  State<_ScanReticle> createState() => _ScanReticleState();
}

class _ScanReticleState extends State<_ScanReticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const boxSize = 260.0;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        children: [
          // Corner brackets
          CustomPaint(
            size: const Size(boxSize, boxSize),
            painter: _CornerBracketPainter(),
          ),
          // Animated sweeping laser line
          AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              final topOffset = _animController.value * (boxSize - 16) + 8;
              return Positioned(
                top: topOffset,
                left: 12,
                right: 12,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF38BDF8),
                        Colors.white,
                        Color(0xFF38BDF8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.8),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;
    const radius = 16.0;

    // Top-Left
    final pathTL = Path()
      ..moveTo(0, cornerLength)
      ..lineTo(0, radius)
      ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, 0);
    canvas.drawPath(pathTL, paint);

    // Top-Right
    final pathTR = Path()
      ..moveTo(size.width - cornerLength, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
      ..lineTo(size.width, cornerLength);
    canvas.drawPath(pathTR, paint);

    // Bottom-Left
    final pathBL = Path()
      ..moveTo(0, size.height - cornerLength)
      ..lineTo(0, size.height - radius)
      ..arcToPoint(Offset(radius, size.height), radius: const Radius.circular(radius))
      ..lineTo(cornerLength, size.height);
    canvas.drawPath(pathBL, paint);

    // Bottom-Right
    final pathBR = Path()
      ..moveTo(size.width - cornerLength, size.height)
      ..lineTo(size.width - radius, size.height)
      ..arcToPoint(Offset(size.width, size.height - radius), radius: const Radius.circular(radius))
      ..lineTo(size.width, size.height - cornerLength);
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VignetteCutoutPainter extends CustomPainter {
  final double cutoutSize;
  final double borderRadius;

  const _VignetteCutoutPainter({
    required this.cutoutSize,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)));

    final finalPath = Path.combine(PathOperation.difference, bgPath, cutoutPath);
    canvas.drawPath(finalPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatusCard extends StatelessWidget {
  final bool isProcessing;

  const _StatusCard({required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              if (isProcessing) ...[
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(width: 14),
              ] else ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFF38BDF8),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  isProcessing
                      ? 'Looking up box...'
                      : 'Point camera at a MoveMate box QR code',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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