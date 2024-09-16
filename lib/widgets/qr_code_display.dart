import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'dart:typed_data';

class QRCodePage extends StatefulWidget {
  final String transactionId;
  final String event_name;
  final String ticketType;
  final int numberOfTickets;
  final double totalPrice;
  final String location; // Nouvelle propriété
  final DateTime start_time; // Nouvelle propriété
  final DateTime end_time; // Nouvelle propriété

  QRCodePage({
    required this.transactionId,
    required this.event_name,
    required this.ticketType,
    required this.numberOfTickets,
    required this.totalPrice,
    required this.location, // Nouvelle propriété
    required this.start_time, // Nouvelle propriété
    required this.end_time, // Nouvelle propriété
  });

  @override
  _QRCodePageState createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isQRUsed = false;

  Future<void> _saveQRCodeAsImage() async {
    final permission = await PhotoManager.requestPermissionExtend();
    
    if (permission.isAuth) {
      _screenshotController.capture().then((Uint8List? image) async {
        if (image != null) {
          final tempDir = await Directory.systemTemp.createTemp();
          final file = await File('${tempDir.path}/qr_code.png').writeAsBytes(image);

          final asset = await PhotoManager.editor.saveImage(
            image, 
            filename: 'qr_code.png',
          );
          if (asset != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Le QR code a été enregistré dans la galerie.')),
            );
          }
        }
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde de l\'image.')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission refusée.')),
      );
    }
  }

  Future<void> _saveQRCodeAsPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Ticket QR Code',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.BarcodeWidget(
                data: _qrCodeData(),
                barcode: pw.Barcode.qrCode(),
                width: 200,
                height: 200,
              ),
              pw.SizedBox(height: 20),
              pw.Text('Transaction ID: ${widget.transactionId}'),
              pw.Text('Événement: ${widget.event_name}'),
              pw.Text('Type de ticket: ${widget.ticketType}'),
              pw.Text('Nombre de billets: ${widget.numberOfTickets}'),
              pw.Text('Montant: ${widget.totalPrice.toStringAsFixed(2)} XOF'),
              pw.SizedBox(height: 10),
              pw.Text('Lieu: ${widget.location}'),
              pw.Text('Début: ${widget.start_time.toLocal().toString()}'),
              pw.Text('Fin: ${widget.end_time.toLocal().toString()}'),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  String _qrCodeData() {
    return _isQRUsed
        ? 'Code QR invalide' // Message si le code a déjà été scanné
        : '${widget.transactionId}|${widget.event_name}|${widget.ticketType}|${widget.numberOfTickets}|${widget.totalPrice.toStringAsFixed(2)}|${widget.location}|${widget.start_time.toIso8601String()}|${widget.end_time.toIso8601String()}';
  }

  void _scannedCode() {
    if (!_isQRUsed) {
      // Traitez le scan ici...
      // Vous pouvez éventuellement envoyer une requête au serveur pour invalider le QR code.
      setState(() {
        _isQRUsed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code QR scanné avec succès!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code QR invalide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveQRCodeAsImage,
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _saveQRCodeAsPDF,
          ),
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: _screenshotController,
            child: GestureDetector(
              onTap: _scannedCode,  // Simulation de la lecture du code QR
              child: SizedBox(
                width: 200.0,  // Largeur du QR code
                height: 200.0, // Hauteur du QR code
                child: QrImageView(
                  data: _qrCodeData(),  // Utilisation du contenu modifié
                  version: QrVersions.auto,  // Version auto
                  size: 200.0,  // Taille du QR code
                ),
              ),
            ),
        ),
      ),
    );
  }
}
