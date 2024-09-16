import 'dart:io';
import 'package:event/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_color.dart';
import '../../widgets/my_widgets.dart';
import 'package:event/views/auth/login_signup.dart';


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Clé globale pour le formulaire
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController dob = TextEditingController();

  // Variable pour stocker l'image de profil
  File? profileImage;

  // Variable pour gérer la sélection du sexe
  int selectedRadio = 0;

  // Référence au contrôleur d'authentification
  AuthController? authController;

  // Méthode appelée lors de l'initialisation du widget
  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>(); // Récupération du contrôleur via GetX
  }

  // Méthode pour afficher le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dob.text = '${picked.day}-${picked.month}-${picked.year}';
    }
  }

  // Méthode pour afficher la boîte de dialogue pour choisir la source de l'image
  void imagePickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choisir la source de l\'image'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {}); // Rafraîchit l'interface après sélection de l'image
                    Navigator.pop(context);
                  }
                },
                child: Icon(
                  Icons.camera_alt,
                  size: 30,
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {}); // Rafraîchit l'interface après sélection de l'image
                    Navigator.pop(context);
                  }
                },
                child: Image.asset(
                  'assets/gallary.png',
                  width: 25,
                  height: 25,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Méthode pour mettre à jour la sélection du sexe
  void setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  // Construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: Get.width * 0.1),
                InkWell(
                  onTap: imagePickDialog, // Appel de la méthode pour choisir l'image
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: EdgeInsets.only(top: 35),
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(70),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff7DDCFB),
                          Color(0xffBC67F2),
                          Color(0xffACF6AF),
                          Color(0xffF95549),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(70),
                          ),
                          child: profileImage == null
                              ? CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                    size: 50,
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Colors.white,
                                  backgroundImage: FileImage(profileImage!),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Get.width * 0.1),
                // Champs de saisie pour le nom
                textField(
                  text: 'Nom',
                  controller: firstNameController,
                  validator: (String? input) {
                    if (input == null || input.isEmpty) {
                      return 'Votre nom est requis.';
                    }
                    return null;
                  },
                ),
                // Champs de saisie pour le prénom
                textField(
                  text: 'Prénom',
                  controller: lastNameController,
                  validator: (String? input) {
                    if (input == null || input.isEmpty) {
                      return 'Votre prénom est requis.';
                    }
                    return null;
                  },
                ),
                // Champs de saisie pour le numéro de téléphone
                textField(
                  text: 'Numéro de Téléphone',
                  inputType: TextInputType.phone,
                  controller: mobileNumberController,
                  validator: (String? input) {
                    if (input == null || input.isEmpty) {
                      return 'Le numéro de téléphone est requis.';
                    }
                    if (input.length < 10) {
                      return 'Entrez un numéro de téléphone valide.';
                    }
                    return null;
                  },
                ),
                // Champs de saisie pour la date de naissance
                Container(
                  height: 48,
                  child: TextFormField(
                    controller: dob,
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _selectDate(context); // Appel de la méthode pour sélectionner la date
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 10, left: 10),
                      suffixIcon: Image.asset(
                        'assets/calender.png',
                        cacheHeight: 20,
                      ),
                      hintText: 'Date de naissance',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (String? input) {
                      if (input == null || input.isEmpty) {
                        return 'La date de naissance est requise.';
                      }
                      return null;
                    },
                  ),
                ),
                // Boutons radio pour le sexe
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          'Homme',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: AppColors.genderTextColor,
                          ),
                        ),
                        value: 0,
                        groupValue: selectedRadio,
                        onChanged: (int? val) {
                          setSelectedRadio(val!);
                        },
                      ),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: RadioListTile(
                        title: Text(
                          'Femme',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: AppColors.genderTextColor,
                          ),
                        ),
                        value: 1,
                        groupValue: selectedRadio,
                        onChanged: (int? val) {
                          setSelectedRadio(val!);
                        },
                      ),
                    ),
                  ],
                ),
                // Bouton pour enregistrer les informations de profil
                Obx(() => authController!.isProfileInformationLoading.value
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        height: 50,
                        margin: EdgeInsets.only(top: Get.height * 0.02),
                        width: Get.width,
                        child: elevatedButton(
                          text: 'Enregistrer',
                          onpress: () async {
                            // Utiliser formKey pour valider tous les champs
                            if (!formKey.currentState!.validate()) {
                              Get.snackbar(
                                'Erreur',
                                'Veuillez remplir tous les champs requis.',
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                              );
                              return;
                            }

                            if (profileImage == null) {
                              Get.snackbar(
                                'Erreur',
                                "L'image est requise. Inscription annulée.",
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                              );
                              authController?.cancelRegistration(); // Annuler l'inscription
                            Get.offAllNamed('/login');// Rediriger vers la page de login
                              return;
                            }

                            // Affichage du chargement
                            authController!.isProfileInformationLoading(true);

                            try {
                              // Upload de l'image vers Firebase Storage
                              String imageUrl = await authController!
                                  .uploadImageToFirebaseStorage(profileImage!);

                              // Envoi des données de profil à Firebase Firestore
                              await authController!.uploadProfileData(
                                imageUrl,
                                firstNameController.text.trim(),
                                lastNameController.text.trim(),
                                mobileNumberController.text.trim(),
                                dob.text.trim(),
                                selectedRadio == 0 ? "Male" : "Female",
                              );
                            } catch (error) {
                              // En cas d'erreur lors de l'upload ou de la sauvegarde
                              Get.snackbar(
                                'Erreur',
                                'Erreur lors de l\'enregistrement du profil. Inscription annulée.',
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                              );
                              authController?.cancelRegistration(); // Annuler l'inscription
                              Get.offAllNamed('/login'); // Rediriger vers la page de login
                            } finally {
                              // Désactiver l'affichage du chargement
                              authController!.isProfileInformationLoading(false);
                            }
                          },
                        ),
                      )),
                SizedBox(height: Get.height * 0.03),
                // Texte d'information sur les conditions d'utilisation
                Container(
                  width: Get.width * 0.8,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'En vous inscrivant, vous acceptez notre ',
                          style: TextStyle(
                            color: Color(0xff262628),
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: 'conditions, Politique de données et politique en matière de cookies',
                          style: TextStyle(
                            color: Color(0xff262628),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
