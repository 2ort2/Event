import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assurez-vous d'importer cette bibliothèque
import 'ticket_summary_dialog.dart';  // Assurez-vous que ce fichier est correctement importé

class TicketSelectionPage extends StatefulWidget {
  final dynamic eventData; // Utilisation de dynamic ici pour simplifier

  TicketSelectionPage({required this.eventData});

  @override
  _TicketSelectionPageState createState() => _TicketSelectionPageState();
}

class _TicketSelectionPageState extends State<TicketSelectionPage> {
  String? selectedTicketType;
  int numberOfTickets = 1;
  bool isStandardSelected = false;
  bool isVipSelected = false;
  final standardPriceController = TextEditingController();
  final vipPriceController = TextEditingController();
  double totalPrice = 0.0;

  late String location;
  late DateTime start_time;
  late DateTime end_time;

  @override
  void initState() {
    super.initState();

    // Extraction des données de l'événement avec des valeurs par défaut
    standardPriceController.text = (widget.eventData.get('standardPrice') ?? '0').toString();
    vipPriceController.text = (widget.eventData.get('vipPrice') ?? '0').toString();
    
    location = widget.eventData.get('location') ?? 'Non spécifié';

    var startTimeValue = widget.eventData.get('start_time');
    var endTimeValue = widget.eventData.get('end_time');

    if (startTimeValue is Timestamp) {
      start_time = startTimeValue.toDate();
    } else if (startTimeValue is String) {
      start_time = DateTime.tryParse(startTimeValue) ?? DateTime.now(); // Valeur par défaut
    } else {
      start_time = DateTime.now(); // Valeur par défaut si non initialisé
    }

    if (endTimeValue is Timestamp) {
      end_time = endTimeValue.toDate();
    } else if (endTimeValue is String) {
      end_time = DateTime.tryParse(endTimeValue) ?? DateTime.now(); // Valeur par défaut
    } else {
      end_time = DateTime.now(); // Valeur par défaut si non initialisé
    }
  }

  void calculateTotalPrice() {
    totalPrice = 0.0;
    double standardPrice = double.tryParse(standardPriceController.text) ?? 0.0;
    double vipPrice = double.tryParse(vipPriceController.text) ?? 0.0;

    if (isStandardSelected) {
      totalPrice += standardPrice * numberOfTickets;
    }
    if (isVipSelected) {
      totalPrice += vipPrice * numberOfTickets;
    }
    setState(() {});  // Update the UI with the new total price
  }

  @override
  Widget build(BuildContext context) {
    int maxEntries = widget.eventData.get('max_entries') ?? 1; // Valeur par défaut en cas de nullité

    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir le type de ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventData.get('event_name') ?? 'Événement inconnu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Sélectionnez un type de ticket:', style: TextStyle(fontSize: 18)),
            CheckboxListTile(
              title: Text('Standard'),
              value: isStandardSelected,
              onChanged: (bool? value) {
                setState(() {
                  isStandardSelected = value ?? false;
                  calculateTotalPrice();
                });
              },
            ),
            CheckboxListTile(
              title: Text('VIP'),
              value: isVipSelected,
              onChanged: (bool? value) {
                setState(() {
                  isVipSelected = value ?? false;
                  calculateTotalPrice();
                });
              },
            ),
            SizedBox(height: 10),
            Text('Nombre de billets:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            DropdownButton<int>(
              value: numberOfTickets,
              onChanged: (int? newValue) {
                setState(() {
                  numberOfTickets = newValue ?? 1;
                  calculateTotalPrice();
                });
              },
              items: List.generate(maxEntries, (index) => index + 1)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Prix total: CFA ${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Vérification de l'authentification de l'utilisateur
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final String userId = user.uid;

                      // Redirection vers le récapitulatif des tickets avec l'UID
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return TicketSummaryDialog(
                            event_name: widget.eventData.get('event_name') ?? 'Événement inconnu',
                            ticketType: getTicketType(),
                            numberOfTickets: numberOfTickets,
                            totalPrice: totalPrice,
                            isStandardSelected: isStandardSelected,
                            isVipSelected: isVipSelected,
                            location: location,
                            start_time: start_time,  // Assurez-vous que start_time est non-nullable
                            end_time: end_time,      // Assurez-vous que end_time est non-nullable
                            userId: userId,  // Passez l'UID ici
                          );
                        },
                      );
                    } else {
                      // Afficher une erreur si l'utilisateur n'est pas authentifié
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Erreur : Utilisateur non authentifié'),
                      ));
                    }
                  },
                  child: Text('Voir le récapitulatif'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Annuler'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getTicketType() {
    if (isStandardSelected && isVipSelected) {
      return 'Standard & VIP';
    } else if (isStandardSelected) {
      return 'Standard';
    } else if (isVipSelected) {
      return 'VIP';
    } else {
      return 'Aucun';
    }
  }
}
