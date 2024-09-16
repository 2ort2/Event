import 'package:flutter/material.dart';
import 'payment_page.dart';

class TicketSummaryDialog extends StatelessWidget {
  final String event_name;
  final String ticketType;
  final int numberOfTickets;
  final double totalPrice;
  final bool isStandardSelected;
  final bool isVipSelected;
  final String location; // Nouvelle propriété
  final DateTime start_time; // Nouvelle propriété
  final DateTime end_time; // Nouvelle propriété
  final String userId;  // Ajoutez l'UID ici

  TicketSummaryDialog({
    required this.event_name,
    required this.ticketType,
    required this.numberOfTickets,
    required this.totalPrice,
    required this.isStandardSelected,
    required this.isVipSelected,
    required this.location, // Nouvelle propriété
    required this.start_time, // Nouvelle propriété
    required this.end_time, // Nouvelle propriété
    required this.userId,  // Ne déclarez 'userId' qu'une seule fois ici
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Récapitulatif de la commande'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Événement: $event_name', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Type de ticket: $ticketType', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Nombre de billets: $numberOfTickets', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Prix total: \cfa${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Modifier'),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPage(
                  totalPrice: totalPrice,
                  ticketType: ticketType,
                  numberOfTickets: numberOfTickets,
                  event_name: event_name,
                  location: location,
                  start_time: start_time,
                  end_time: end_time,
                  userId: userId,  // Passez l'UID à la page de paiement
                ),
              ),
            );
          },
          child: Text('Passer au paiement'),
        ),
      ],
    );
  }
}
