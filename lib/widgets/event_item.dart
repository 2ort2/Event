import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventItem extends StatelessWidget {
  final DocumentSnapshot eventData;

  EventItem(this.eventData);

  @override
  Widget build(BuildContext context) {
    String eventName = eventData.get('event_name');  // Nom de l'événement
    String eventDate = eventData.get('date');  // Date de l'événement
    String startTime = eventData.get('start_time');  // Heure de début
    String endTime = eventData.get('end_time');  // Heure de fin
    String location = eventData.get('location');  // Lieu de l'événement
    String eventImage = '';  // L'image de l'événement
    String standardPrice = eventData.get('standardPrice');  // Prix standard
    String vipPrice = eventData.get('vipPrice');  // Prix VIP

    // Vérification de l'existence de médias et récupération du premier média
    List media = eventData.get('media') ?? [];
    if (media.isNotEmpty) {
      Map<String, dynamic> firstMedia = media[0];
      eventImage = firstMedia['url'];
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affichage de l'image de l'événement
          Container(
            height: 200.0,  // Ajustez la hauteur en fonction de vos besoins
            width: double.infinity,
            child: eventImage.isNotEmpty
                ? Image.network(
                    eventImage,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey,
                    child: Icon(Icons.event, size: 50, color: Colors.white),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              eventName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Date: $eventDate',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Heure: $startTime - $endTime',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Lieu: $location',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Prix Standard: $standardPrice\$',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Prix VIP: $vipPrice\$',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
