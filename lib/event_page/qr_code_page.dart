// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'dart:io';
// import 'dart:typed_data';

// class QRCodePage extends StatefulWidget {
//   final String transactionId;
//   final String eventName;
//   final String ticketType;
//   final int numberOfTickets;
//   final double totalPrice;

//   QRCodePage({
//     required this.transactionId,
//     required this.eventName,
//     required this.ticketType,
//     required this.numberOfTickets,
//     required this.totalPrice,
//   });

//   @override
//   _QRCodePageState createState() => _QRCodePageState();
// }

// class _QRCodePageState extends State<QRCodePage> {
//   final ScreenshotController _screenshotController = ScreenshotController();

//   Future<void> _saveQRCodeAsImage() async {
//     final permission = await PhotoManager.requestPermissionExtend();
    
//     if (permission.isAuth) {
//       _screenshotController.capture().then((Uint8List? image) async {
//         if (image != null) {
//           final tempDir = await Directory.systemTemp.createTemp();
//           final file = await File('${tempDir.path}/qr_code.png').writeAsBytes(image);
          
//           final asset = await PhotoManager.editor.saveImage(
//             image, 
//             filename: 'qr_code.png',
//           );
//           if (asset != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Le QR code a été enregistré dans la galerie.')),
//             );
//           }
//         }
//       }).catchError((err) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur lors de la sauvegarde de l\'image.')),
//         );
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Permission refusée.')),
//       );
//     }
//   }

//   Future<void> _saveQRCodeAsPDF() async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) => pw.Center(
//           child: pw.Column(
//             children: [
//               pw.Text('Ticket QR Code'),
//               pw.SizedBox(height: 20),
//               pw.BarcodeWidget(
//                 data: _qrCodeData(),
//                 barcode: pw.Barcode.qrCode(),
//                 width: 200,
//                 height: 200,
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text('Transaction ID: ${widget.transactionId}'),
//               pw.Text('Événement: ${widget.eventName}'),
//               pw.Text('Type de ticket: ${widget.ticketType}'),
//               pw.Text('Nombre de billets: ${widget.numberOfTickets}'),
//               pw.Text('Montant: ${widget.totalPrice.toStringAsFixed(2)} XOF'),
//             ],
//           ),
//         ),
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }

//   String _qrCodeData() {
//     return 'Transaction ID: ${widget.transactionId}\n'
//         'Événement: ${widget.eventName}\n'
//         'Type de ticket: ${widget.ticketType}\n'
//         'Nombre de billets: ${widget.numberOfTickets}\n'
//         'Montant: ${widget.totalPrice.toStringAsFixed(2)} XOF';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _saveQRCodeAsImage,
//           ),
//           IconButton(
//             icon: Icon(Icons.picture_as_pdf),
//             onPressed: _saveQRCodeAsPDF,
//           ),
//         ],
//       ),
//       body: Center(
//         child: Screenshot(
//           controller: _screenshotController,
//           child: SizedBox(
//             width: 200.0,  // Définir la largeur du QR code
//             height: 200.0, // Définir la hauteur du QR code
//             child: QrImage(
//               data: _qrCodeData(),  // Utilise le paramètre correct pour générer le QR code
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
