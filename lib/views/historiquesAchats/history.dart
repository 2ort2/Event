import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  @override
  _PurchaseHistoryScreenState createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> purchaseHistory = []; // Liste des achats

  @override
  void initState() {
    super.initState();
    fetchPurchaseHistory(); // Récupérer l'historique des achats de l'utilisateur connecté
  }

  // Fonction pour récupérer l'historique des achats
  void fetchPurchaseHistory() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('payments') // Collection contenant les achats
        .where('userId', isEqualTo: currentUserUid)
        .get();

    setState(() {
      purchaseHistory = querySnapshot.docs; // Récupérer les achats de l'utilisateur
    });
  }

  // Fonction pour vider l'historique d'achats (localement)
  void clearPurchaseHistory() {
    setState(() {
      purchaseHistory.clear(); // Vider l'historique localement
    });
  }

  // Fonction pour supprimer les achats de la base de données (si nécessaire)
  Future<void> deletePurchaseHistoryFromDatabase() async {
    WriteBatch batch = _firestore.batch();

    for (DocumentSnapshot doc in purchaseHistory) {
      batch.delete(doc.reference); // Supprimer chaque document d'achat
    }

    await batch.commit(); // Appliquer les suppressions en une seule fois
    clearPurchaseHistory(); // Vider l'historique localement après suppression
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des achats'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete), // Icône pour vider l'historique
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Vider l\'historique'),
                  content: Text('Êtes-vous sûr de vouloir vider l\'historique de vos achats ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Confirmer'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                deletePurchaseHistoryFromDatabase(); // Vider l'historique depuis la base de données
              }
            },
          ),
        ],
      ),
      body: purchaseHistory.isEmpty
          ? Center(child: Text('Aucun historique d\'achat disponible.'))
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: purchaseHistory.length,
              itemBuilder: (context, index) {
                DocumentSnapshot purchaseData = purchaseHistory[index];
                String eventName = purchaseData.get('eventName') ?? 'Événement inconnu';
                String ticketType = purchaseData.get('ticketType') ?? 'Type de billet inconnu';
                int numberOfTickets = purchaseData.get('numberOfTickets') ?? 0;
                double totalPrice = purchaseData.get('totalPrice') ?? 0.0;
                Timestamp timestamp = purchaseData.get('timestamp') ?? Timestamp.now();
                DateTime purchaseDate = timestamp.toDate();

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.receipt_long),
                    title: Text(eventName),
                    subtitle: Text(
                      'Type de billet : $ticketType\n'
                      'Nombre de billets : $numberOfTickets\n'
                      'Prix total : ${totalPrice.toStringAsFixed(2)} XOF\n'
                      'Date : ${purchaseDate.toLocal().toString()}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
