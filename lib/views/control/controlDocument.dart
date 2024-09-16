// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// DocumentSnapshot<Map<String, dynamic>> getFakeDocumentSnapshot() {
//   // Crée un snapshot fictif en utilisant Map<String, dynamic> pour les données
//   return QueryDocumentSnapshot<Map<String, dynamic>>(
//     FirebaseFirestore.instance,
//     FirebaseFirestore.instance.doc('fake/doc'),
//     {'nom': 'Utilisateur Inconnu', 'email': 'exemple@domaine.com'},  // Données par défaut
//     SnapshotMetadata(false, false),
//     false,
//   );
// }