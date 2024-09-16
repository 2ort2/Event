import 'dart:io';
import 'dart:math';
import 'package:event/views/OTP/code_OTP.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/controller/data_controller.dart';
import 'package:event/views/bottom_nav_bar/bottom_bar_view.dart';
import 'package:event/views/home_screen.dart';
import 'package:event/views/profile/add_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:path/path.dart' as Path;
import 'package:path/path.dart';

class AuthController extends GetxController {
  // Initialisation des instances de FirebaseAuth et l'observable isLoading
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var isLoading = false.obs;

  // Fonction pour se connecter avec email et mot de passe
  void login({required String email, required String password}) {
    isLoading(true);

    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      isLoading(false);

      // Initialiser DataController
      // Get.put(DataController());

      Get.to(() =>
          BottomBarView()); // Redirection vers l'écran de profil après connexion
    }).catchError((e) {
      isLoading(false);
      Get.snackbar(
          'Error', "$e"); // Affichage d'une notification en cas d'erreur
    });
  }

  // // Fonction pour s'inscrire avec email et mot de passe
  // void signUp({required String email, required String password}) async {
  //   isLoading(true);

  //   auth
  //       .createUserWithEmailAndPassword(email: email, password: password)
  //       .then((value) {
  //     isLoading(false);

  //     // Initialiser DataController
  //     // Get.put(DataController());

  //     Get.to(() =>
  //         ProfileScreen()); // Redirection vers l'écran de profil après inscription
  //   }).catchError((e) {
  //     print("Erreur lors de l\'authentification $e");
  //     isLoading(false);
  //   });
  // }

// Fonction pour générer un OTP aléatoire de 6 chiffres
  String generateOtp() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000)
        .toString(); // Génère un nombre à 6 chiffres
  }

  // Fonction pour envoyer l'OTP par email
  Future<void> sendOtpEmail(String recipientEmail, String otp) async {
    String username = 'togboshalom@gmail.com'; // Remplacez par votre email
    String password = 'agea hqvf oqbm ctbz'; // Remplacez par votre mot de passe

    // Utilisation de l'alias 'mailer' pour la classe 'Message'
    final smtpServer =
        gmail(username, password); // Utiliser les paramètres SMTP de Gmail

    gmail(username, password); // Utiliser les paramètres SMTP de Gmail
    final message = mailer.Message()
      ..from = Address(username, 'VotreAppName')
      ..recipients.add(recipientEmail)
      ..subject = 'Votre code OTP'
      ..text = 'Votre code OTP est : $otp';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message envoyé : ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Erreur lors de l\'envoi de l\'email : $e');
    }
  }

  // Fonction pour s'inscrire avec email et mot de passe et envoyer OTP
  void signUp({required String email, required String password}) async {
    isLoading(true);

    try {
      // Vérifier si l'email existe déjà dans la collection 'otp'
      DocumentSnapshot otpSnapshot =
          await firestore.collection('otp').doc(email).get();

      if (otpSnapshot.exists) {
        // L'email est déjà dans la collection 'otp'
        Get.snackbar('Erreur',
            'Cet email est déjà utilisé pour une inscription précédente.');
        isLoading(false);
        return;
      }

      // Si l'email n'existe pas, créer un nouvel utilisateur
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Générer le code OTP
      String otp = generateOtp();

      // Sauvegarder l'OTP dans Firestore avec expiration
      await firestore.collection('otp').doc(email).set({
        'otp': otp,
        'createdAt': DateTime.now(),
        'expiresAt': DateTime.now()
            .add(Duration(minutes: 5)), // OTP expire après 5 minutes
      });

      // Envoyer le code OTP par email
      await sendOtpEmail(email, otp);

      // Redirection vers l'écran de saisie de l'OTP après inscription
      Get.to(() => OtpScreen(email: email));
    } catch (e) {
      print("Erreur lors de l'authentification : $e");
      Get.snackbar('Erreur',
          'Une erreur est survenue lors de l\'inscription. Veuillez réessayer.');
    } finally {
      isLoading(false);
    }
  }

  // Fonction pour vérifier l'OTP
  Future<void> verifyOtp(
      {required String email, required String enteredOtp}) async {
    DocumentSnapshot otpSnapshot =
        await firestore.collection('otp').doc(email).get();

    if (otpSnapshot.exists) {
      var data = otpSnapshot.data() as Map<String, dynamic>;
      String savedOtp = data['otp'];
      DateTime expiresAt = data['expiresAt'].toDate();

      if (DateTime.now().isBefore(expiresAt)) {
        if (savedOtp == enteredOtp) {
          // Si l'OTP est valide, supprimer l'OTP et rediriger vers l'écran de profil
          await firestore.collection('otp').doc(email).delete();
          Get.to(() => ProfileScreen());
        } else {
          // OTP incorrect
          Get.snackbar('Erreur', 'Code OTP incorrect');
        }
      } else {
        // OTP expiré
        Get.snackbar('Erreur', 'Le code OTP a expiré');
      }
    } else {
      // Aucun OTP trouvé
      Get.snackbar('Erreur', 'Aucun code OTP trouvé pour cet email');
    }
  }

  // Fonction pour annuler l'inscription
  Future<void> cancelRegistration() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await FirebaseAuth.instance.currentUser!.delete();
      print("Inscription annulée avec succès.");
    } catch (e) {
      print("Erreur lors de l'annulation de l'inscription: $e");
    }
  }

  // Fonction pour envoyer un email de réinitialisation de mot de passe
  void forgetPassword(String email) {
    if (email.isEmpty || !email.contains('@')) {
      Get.snackbar('Erreur', 'Veuillez entrer une adresse email valide');
      return;
    }

    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) {
      // Fermer la boîte de dialogue
      Navigator.of(context as BuildContext).pop();

      // Afficher un message de confirmation
      Get.snackbar('Email envoyé',
          'Nous vous avons envoyé un email de réinitialisation de mot de passe. Veuillez vérifier votre boîte de réception.');
    }).catchError((e) {
      // Gérer les erreurs
      Get.snackbar('Erreur', 'Impossible d\'envoyer l\'email: $e');
    });
  }

  // Fonction pour se connecter avec Google
  Future<void> signInWithGoogle() async {
    isLoading(true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      isLoading(false);
      Get.to(() =>
          BottomBarView()); // Redirection vers l'écran principal après connexion avec Google
    } catch (e) {
      isLoading(false);
      print("Erreur lors de la connexion avec Google: $e");
    }
  }

  var isProfileInformationLoading = false.obs;

  // Fonction pour uploader une image vers Firebase Storage
  Future<String> uploadImageToFirebaseStorage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);

    // Référence à Firebase Storage
    var reference = FirebaseStorage.instance.ref().child('Images/$fileName');

    // Téléchargement de l'image
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
    }).catchError((e) {
      print("Erreur lors de l'upload de l'image: $e");
    });

    return imageUrl;
  }

  // Fonction pour uploader les données du profil vers Firestore
  Future<void> uploadProfileData(String imageUrl, String firstName,
      String lastName, String mobileNumber, String dob, String gender) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'image': imageUrl,
        'first': firstName,
        'last': lastName,
        'mobileNumber': mobileNumber,
        'dob': dob,
        'gender': gender,
        'bannir': false, // Ajout du champ "bannir" défini à false
      });
      isProfileInformationLoading(false);
      Get.offAll(() =>
          BottomBarView()); // Redirection vers l'écran principal après mise à jour du profil
    } catch (e) {
      isProfileInformationLoading(false);
      print("Erreur lors de la sauvegarde des données de profil: $e");
      Get.snackbar('Erreur',
          'Échec de la sauvegarde des données de profil. Inscription annulée.',
          colorText: Colors.white, backgroundColor: Colors.red);
      await cancelRegistration(); // Annuler l'inscription
      Get.offAllNamed('/login'); // Rediriger vers la page de login
    }
  }

  // Fonction pour se déconnecter
  Future<void> logout() async {
    try {
      await auth.signOut(); // Déconnexion de Firebase Auth
      Get.offAllNamed('/login'); // Rediriger vers la page de connexion
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
      Get.snackbar('Erreur', 'Échec de la déconnexion: $e');
    }
  }
}
