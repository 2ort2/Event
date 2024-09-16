// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../pages/qr_code_page.dart';

// class FedaPayService {
//   final String apiUrl = "https://api.fedapay.com/v1/transactions";
//   final String publicKey = "YOUR_PUBLIC_KEY"; // Remplacez par votre clé publique
//   final String secretKey = "YOUR_SECRET_KEY"; // Remplacez par votre clé secrète

//   Future<void> initiatePayment({
//     required String amount,
//     required String description,
//     required BuildContext context,
//   }) async {
//     // Convertir le montant en centimes (FedaPay attend le montant en centimes)
//     int amountInCents = (double.parse(amount) * 100).toInt();

//     Map<String, String> headers = {
//       "Authorization": "Bearer $secretKey",
//       "Content-Type": "application/json"
//     };

//     Map<String, dynamic> body = {
//       "transaction": {
//         "amount": amountInCents,
//         "description": description,
//         "currency": "XOF"
//       },
//       "customer": {
//         "firstname": "John", // Remplacez par les informations du client
//         "lastname": "Doe",   // Remplacez par les informations du client
//         "email": "customer@example.com"
//       }
//     };

//     try {
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: json.encode(body),
//       );

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         String checkoutUrl = data['data']['url']; // URL du paiement
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => QRCodePage(eventDetails: description),
//           ),
//         );
//       } else {
//         print("Erreur: ${response.body}");
//       }
//     } catch (e) {
//       print("Exception: $e");
//     }
//   }
// }