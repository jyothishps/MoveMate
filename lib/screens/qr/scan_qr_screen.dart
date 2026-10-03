import 'package:flutter/material.dart';
import 'package:qr_packing_app/widgets/empty_state.dart';

class ScanQrScreen extends StatelessWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR')),
      body: const EmptyState(
        icon: Icons.qr_code_scanner,
        title: 'Scan a box QR code',
        message: 'Camera scanning will be added in Phase 9.',
      ),
    );
  }
}