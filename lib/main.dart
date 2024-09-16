import 'dart:io';
import 'package:event/services/notification_services.dart';
import 'package:event/views/auth/login_signup.dart';
import 'package:event/views/bottom_nav_bar/bottom_bar_view.dart';
import 'package:event/views/onboarding_screen.dart';
import 'package:event/views/profile/add_profile.dart';
import 'package:get/get.dart';
import 'package:event/views/bottom_nav_bar/create_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event/controller/auth_controller.dart'; // Assurez-vous que l'import du contrôleur est correct
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print(message.data.toString());
//   print(message.notification!.toString());
// }

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec configuration spécifique pour Android
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBkfG5_fgEZRD22D-NtIUt3MHkNdYfjLto", 
        appId: "1:752542073774:android:c6f37afe00654a04e67e3f",
        messagingSenderId: "752542073774",
        projectId: "sge-app-d4873",
        storageBucket: "sge-app-d4873.appspot.com",

      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialisation de AuthController
  Get.put(AuthController());

  // await Firebase.initializeApp();
  //  LocalNotificationService.initialize();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

 
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),



      // Définissez les routes ici
      getPages: [
      //  GetPage(name: '/', page: () => ProfileScreen()),
        GetPage(name: '/login', page: () => LoginView()), // Définir la route pour LoginView
      //  GetPage(name: '/home', page: () => BottomBarView()), // Définir la route pour BottomBarView
       // GetPage(name: '/onboarding', page: () => OnBoardingScreen()), // Route pour OnBoarding
       // GetPage(name: '/create_event', page: () => CreateEvent()), // Route pour CreateEvent
      ],

     // home: FirebaseAuth.instance.currentUser!.uid == null? OnBoardingScreen() : BottomBarView(),
     home: OnBoardingScreen(),
    );
  }
}




//  home: PaymentPage(),
//       routes: {
//         '/qr_code': (context) => QRCodePage(),
//         '/scan_qr': (context) => ScanQRCodePage(),
//       },
