import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

// Liste des raisons possibles pour le signalement
const List<String> reportReasons = [
  'Contenu inapproprié',
  'Spam ou publicité',
  'Discours haineux',
  'Violence',
  'Autre',
];

void openReportDialog(BuildContext context, DocumentSnapshot eventData) {
  String selectedReason = reportReasons[0]; // Raison par défaut
  TextEditingController detailsController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Signaler l\' événement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedReason,
              decoration: InputDecoration(
                labelText: 'Sélectionnez une raison',
              ),
              items: reportReasons.map((String reason) {
                return DropdownMenuItem<String>(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (String? newValue) {
                selectedReason = newValue!;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: detailsController,
              decoration: InputDecoration(
                hintText: 'Détails supplémentaires (facultatif)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le dialog
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              submitReport(selectedReason, detailsController.text, eventData);
              Navigator.of(context).pop(); // Ferme le dialog
            },
            child: Text('Envoyer'),
          ),
        ],
      );
    },
  );
}

void submitReport(String selectedReason, String details, DocumentSnapshot eventData) {
  if (selectedReason.isNotEmpty) {
    FirebaseFirestore.instance.collection('reports').add({
      'eventId': eventData.id,
      'reason': selectedReason,
      'details': details,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': Timestamp.now(),
    }).then((_) {
      Get.snackbar(
        'Signalement envoyé',
        'Votre signalement a été envoyé avec succès.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }).catchError((error) {
      Get.snackbar(
        'Erreur',
        'Une erreur s\'est produite lors de l\'envoi du signalement.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }
}
