import 'package:event/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:event/views/mesEvenements/event.dart';
import 'package:event/views/historiquesAchats/history.dart';
import 'package:get/get.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('TOGBO Shalom'), 
            accountEmail: Text('togboshalom@gmail.com'),
             currentAccountPicture: CircleAvatar(
             backgroundImage: AssetImage('assets/profile_picture.png'),  // Image de profil
             ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Accueil'),
            onTap: () {
              Navigator.pop(context);  // Fermer le drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('Mes évènements'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => MyEventsScreen()); // Navigue vers la page "Mes événements"
            },
          ),


          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historique des achats'),
            onTap: () {
              Navigator.pop(context);
               Get.to(() => PurchaseHistoryScreen()); // Navigue vers la page "Historique des achats"
            },
          ),

           ListTile(
            leading: Icon(Icons.settings),
            title: Text('Modifier le mot de passe'),
            onTap: () {
              Navigator.pop(context);
              // Naviguer vers une autre page si nécessaire
            },
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Déconnexion'),
            onTap: () {
              Navigator.pop(context);  // Fermer le drawer
              Get.find<AuthController>().logout();  // Appeler la méthode de déconnexion
            },
          ),
        ],
      ),
    );
  }
}
