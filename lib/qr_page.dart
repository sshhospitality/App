import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:intl/intl.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: scanQRCode,
              child: const Text('Scan QR'),
            ),
            const SizedBox(height: 20.0),
            // Text(qrResult),
          ],
        ),
      ),
    );
  }

  Future<void> postTransaction() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final String sessionCookie = prefs.getString('token') ?? 'N/A';
      final String id = prefs.getString('_id') ?? 'N/A';
      var cookie = 'token=$sessionCookie';

      final response = await http.post(
        Uri.parse(
            "https://z1ogo1n55a.execute-api.ap-south-1.amazonaws.com/api/txn/transactions"),
        headers: <String, String>{
          "cookie": cookie,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{"userId": id, "transaction_mode": "QR"}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        showAlertDialog(
            context,
            'Transaction Successful',
            'Please wait as you are being redirected to transaction success page.',
            data);
      } else {
        final data = json.decode(response.body);
        showAlertDialog(
            context, 'Transaction Failed', data['message'] ?? 'Unknown error');
      }
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

  void showAlertDialog(BuildContext context, String title, String message,
      [Map<String, dynamic>? data]) {
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
                if (data != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) =>
                            TransactionSuccessPage(data: data)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class TransactionSuccessPage extends StatelessWidget {
  final Map<String, dynamic> data;

  TransactionSuccessPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final transaction = data['transaction'];
    final timestamp = DateTime.parse(transaction['timestamp']);
    final formattedTimestamp =
        DateFormat('yyyy-MM-dd – kk:mm').format(timestamp);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Success'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Transaction was successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Transaction Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('Account From:', transaction['account_from']),
            _buildDetailRow('Account To:', transaction['account_to']),
            _buildDetailRow('Meal Type:', transaction['mealType']),
            _buildDetailRow(
                'Transaction Mode:', transaction['transaction_mode']),
            _buildDetailRow('Transaction Ref No:',
                transaction['transaction_ref_no'].toString()),
            _buildDetailRow(
                'Meal Items:', transaction['meal_items'].join(', ')),
            _buildDetailRow('Transaction ID:', transaction['_id'].toString()),
            _buildDetailRow('Timestamp:', formattedTimestamp),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const MainHomePage()),
                  );
                },
                child: const Text('Go to Home Page'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
