import 'package:flutter/material.dart';

class BarcodeScannerTab extends StatelessWidget {
  const BarcodeScannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.qr_code_scanner, size: 48),
          SizedBox(height: 12),
          Text('Barcode scanner coming soon'),
        ],
      ),
    );
  }
}
