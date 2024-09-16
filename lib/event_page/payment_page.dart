import 'package:event/widgets/qr_code_display.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Pour le simulateur de temps

class PaymentPage extends StatefulWidget {
  final double totalPrice;
  final String ticketType;
  final int numberOfTickets;
  final String event_name;
  final String location; // Nouvelle propriété
  final DateTime start_time; // Nouvelle propriété
  final DateTime end_time; // Nouvelle propriété


  PaymentPage({
    required this.totalPrice,
    required this.ticketType,
    required this.numberOfTickets,
    required this.event_name, required String userId,
    required this.location, // Nouvelle propriété
    required this.start_time, // Nouvelle propriété
    required this.end_time, // Nouvelle propriété
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _simulatePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulation d'un délai pour le traitement du paiement
      await Future.delayed(Duration(seconds: 2));

      // Vérifiez si l'utilisateur est authentifié
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: Utilisateur non authentifié'),
        ));
        return;
      }

      // Récupérer l'ID utilisateur
      final String userId = user.uid;

      // Supposons que le paiement est toujours réussi pour la simulation
      String transactionId = 'txn_123456789'; // ID de transaction simulé

      // Sauvegarder les informations dans Firestore
      await FirebaseFirestore.instance.collection('payments').add({
        'transactionId': transactionId,
        'userId': userId,
        'event_name': widget.event_name,
        'ticketType': widget.ticketType,
        'numberOfTickets': widget.numberOfTickets,
        'totalPrice': widget.totalPrice,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'timestamp': FieldValue.serverTimestamp(),  // Ajouter un timestamp
      });

      // Rediriger vers la page du QR Code après un "paiement" réussi
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRCodePage(
            transactionId: transactionId,
            event_name: widget.event_name,
            ticketType: widget.ticketType,
            location: widget.location,
            start_time: widget.start_time,
            end_time: widget.end_time,
            numberOfTickets: widget.numberOfTickets,
            totalPrice: widget.totalPrice,
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur de paiement: $error'),
      ));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement sécurisé'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isProcessing
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant à payer: ${widget.totalPrice.toStringAsFixed(2)} XOF',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Nom complet'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Numéro de téléphone'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _simulatePayment,
                      child: Text('Confirmer le paiement'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
