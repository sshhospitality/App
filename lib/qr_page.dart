import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class QRPage extends StatefulWidget {
  const QRPage({super.key});

  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  String qrResult = "QR Code Result";
  final String originalText = 'naivedyam';
  late final String expectedQrCode;
  @override
  void initState() {
    super.initState();
    expectedQrCode = sha256.convert(utf8.encode(originalText)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('QR Scanner'),
      // ),
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

  Future<void> postTransaction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String sessionCookie = await prefs.getString('token') ?? 'N/A';
      final String id = await prefs.getString('_id') ?? 'N/A';
      var cookie = 'token=$sessionCookie';
      print(id);
      final response = await http.post(
        Uri.parse(
            "https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/txn/transactions"),
        headers: <String, String>{
          "cookie": cookie,
        },
        body: jsonEncode(<String, String>{
          "userId": "661594aca9a498b63c75501c",
          "transaction_mode": "QR"
        }),
      );

      final data = json.decode(response.body);
      print(cookie);
      print(data);
      showAlertDialog(context, 'Transaction Successful',
          'Please wait as you are being redirected to transaction success page.');
    } catch (e) {
      showAlertDialog(context, 'Transaction Failed', '$e');
    }
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

      if (qrCode == expectedQrCode) {
        postTransaction();
        setState(() {
          qrResult = 'Correct QR Code! Proceeding with API call.';
        });
      } else if (qrCode != "-1") {
        // Show alert dialog
        showAlertDialog(
            context, 'Incorrect QR Code', 'Please scan the correct QR code.');
      }

      print("QRCode_Result: $qrCode");
    } on PlatformException {
      setState(() {
        qrResult = 'Failed to scan QR Code.';
      });
    }
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
