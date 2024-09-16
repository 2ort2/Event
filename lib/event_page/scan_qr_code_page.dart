import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class ScanQRCodePage extends StatelessWidget {
  final String expectedEventDetails = "EXAMPLE_EVENT_ID"; // Cela devrait correspondre à l'ID de l'événement

  void _scanQrCode(BuildContext context) async {
    var result = await BarcodeScanner.scan();

    if (result.rawContent.isNotEmpty) {
      if (result.rawContent == expectedEventDetails) {
        _markQrCodeAsUsed();
        _showSuccessDialog(context);
      } else {
        _showFailureDialog(context, "Invalid or already used QR Code");
      }
    }
  }

  void _markQrCodeAsUsed() {
    // Logique pour marquer le QR code comme utilisé
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("QR Code Valid"),
          content: Text("Thank you! Your QR Code has been validated."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("QR Code Invalid"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _scanQrCode(context),
          child: Text("Scan QR Code"),
        ),
      ),
    );
  }
}
