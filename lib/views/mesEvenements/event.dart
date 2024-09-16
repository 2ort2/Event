import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/event_item.dart'; // Ce fichier devra contenir votre widget d'affichage d'un événement
// import 'modify_event_screen.dart';  // Importer ici la page de modification si nécessaire

class MyEventsScreen extends StatefulWidget {
  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid; // UID de l'utilisateur actuel
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<DocumentSnapshot> userEvents = <DocumentSnapshot>[].obs; // Liste des événements créés par l'utilisateur

  @override
  void initState() {
    super.initState();
    fetchUserEvents();  // Récupération des événements de l'utilisateur à l'initialisation
  }

  // Fonction pour récupérer les événements créés par l'utilisateur connecté
  void fetchUserEvents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('events')
          .where('uid', isEqualTo: currentUserUid)  // Filtrer par l'utilisateur actuel
          .get();

      userEvents.assignAll(querySnapshot.docs);  // Mettre à jour la liste des événements
    } catch (e) {
      print('Erreur lors de la récupération des événements: $e');
    }
  }

  // Fonction pour supprimer un événement de la base de données et de la liste affichée
  void deleteEvent(int index) async {
    try {
      DocumentSnapshot eventData = userEvents[index];
      await _firestore.collection('events').doc(eventData.id).delete();  // Supprimer l'événement de Firestore

      userEvents.removeAt(index);  // Supprimer l'événement de la liste affichée
    } catch (e) {
      print('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes événements'),
      ),
      body: Obx(() => userEvents.isEmpty
          ? Center(child: Text('Aucun événement créé.'))  // Message si aucun événement n'est trouvé
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,  // Nombre de colonnes dans la grille
                childAspectRatio: 0.8,  // Ratio de l'affichage pour ajuster les cartes
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: userEvents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot eventData = userEvents[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: EventItem(eventData),  // Affichage de l'événement via le widget EventItem
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteEvent(index);  // Appeler la fonction de suppression
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              // Rediriger vers la page de modification
                              // Get.to(() => ModifyEventScreen(eventData: eventData));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
