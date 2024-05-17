import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  String qrResult = "QR Code Result";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                scanQRCode();
              },
              child: const Text('Scan QR'),
            ),
            const SizedBox(height: 20.0),
            Text(qrResult),
          ],
        ),
      ),
    );
  }

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Customize the line color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.QR, // Scan mode: QR
      );

      if (!mounted) return;

      setState(() {
        qrResult = qrCode != "-1" ? qrCode : "Scan cancelled";
      });

      print("QRCode_Result: $qrCode");
    } on PlatformException {
      setState(() {
        qrResult = 'Failed to scan QR Code.';
      });
    }
  }
}
