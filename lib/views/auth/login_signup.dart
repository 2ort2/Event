import 'dart:ui';
import 'package:event/controller/auth_controller.dart';
import 'package:event/views/bottom_nav_bar/create_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_color.dart';
import '../../widgets/my_widgets.dart';



class LoginView extends StatefulWidget {
  LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {


  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  int selectedRadio = 0;
  TextEditingController forgetEmailController = TextEditingController();

  void setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  bool isSignUp = false;

  late AuthController authController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authController = Get.put(AuthController());

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
            child: Column(
              children: [
                SizedBox(
                  height: Get.height * 0.08,
                ),
                isSignUp
                    ? myText(
                  text: 'S inscrire',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                )
                    : myText(
                  text: 'Se connecter',
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                isSignUp
                    ? Container(
                  child: myText(
                    text:
                    'Bienvenue, Inscrivez-vous pour voir les évènements d actualité !.',
                    style: GoogleFonts.roboto(
                      letterSpacing: 0,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : Container(
                  child: myText(
                    text:
                    'Bienvenue, veuillez vous connecter et continuer votre voyage avec nous.',
                    style: GoogleFonts.roboto(
                      letterSpacing: 0,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                Container(
                  width: Get.width * 0.55,
                  child: TabBar(
                    labelPadding: EdgeInsets.all(Get.height * 0.01),
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.black,
                    indicatorColor: Colors.black,
                    onTap: (v) {
                      setState(() {
                        isSignUp = !isSignUp;
                      });
                    },
                    tabs: [
                      myText(
                        text: 'Connexion',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black),
                      ),
                      myText(
                        text: 'Inscription',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.04,
                ),
                Container(
                  width: Get.width,
                  height: Get.height * 0.6,
                  child: Form(
                    key: formKey,
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        LoginWidget(),
                        SignUpWidget(),
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


  Widget LoginWidget(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              myTextField(
                  bool: false,
                  icon: 'assets/mail.png',
                  text: 'email',
                  validator: (String input){
                    if(input.isEmpty){
                      Get.snackbar('Attention', 'Email est requis.',colorText: Colors.white,backgroundColor: Colors.blue);
                      return '';
                    }

                    if(!input.contains('@')){
                      Get.snackbar('Attention', 'Email est invalide.',colorText: Colors.white,backgroundColor: Colors.blue);
                      return '';
                    }
                  },
                  controller: emailController
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              myTextField(
                  bool: true,
                  icon: 'assets/lock.png',
                  text: 'Mot de passe',
                  validator: (String input){
                    if(input.isEmpty){
                      Get.snackbar('Attention', 'Le mot de passe est requis.',colorText: Colors.white,backgroundColor: Colors.blue);
                      return '';
                    }

                    if(input.length < 6){
                      Get.snackbar('Attention', 'le mot de passe ne doit pas dépasser 6 caractères.',colorText: Colors.white,backgroundColor: Colors.blue);
                      return '';
                    }
                  },
                  controller: passwordController
              ),
              InkWell(
  onTap: () {
    Get.defaultDialog(
      title: 'Mot de passe oublié ?',
      content: Container(
        width: Get.width,
        child: Column(
          children: [
            myTextField(
              bool: false,
              icon: 'assets/lock.png',
              text: 'Entrez votre email...',
              controller: forgetEmailController,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Bouton "Annuler"
                MaterialButton(
                  color: Colors.grey,
                  onPressed: () {
                    Get.back(); // Ferme la boîte de dialogue sans envoyer l'email
                  },
                  child: Text("Annuler"),
                ),
                // Bouton "Envoi"
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    String email = forgetEmailController.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      Get.snackbar('Erreur', 'Veuillez entrer une adresse email valide.');
                    } else {
                      authController.forgetPassword(email);
                      Get.back(); // Ferme la boîte de dialogue après l'envoi de l'email
                    }
                  },
                  child: Text("Envoi"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
  child: Container(
    margin: EdgeInsets.only(
      top: Get.height * 0.02,
    ),
    child: myText(
      text: 'Mot de passe oublié?',
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w400,
        color: AppColors.black,
      ),
    ),
  ),
 ),
            ],
          ),
          Obx(()=> authController.isLoading.value? Center(child: CircularProgressIndicator(),) :Container(
            height: 50,
            margin: EdgeInsets.symmetric(
                vertical: Get.height * 0.04),
            width: Get.width,
            child: elevatedButton(
              text: 'Se connecter',
              onpress: () {

                if(!formKey.currentState!.validate()){
                  return;
                }

               authController.login(email: emailController.text.trim(),password: passwordController.text.trim());


              },
            ),
          )),
          SizedBox(
            height: Get.height * 0.02,
          ),
          myText(
            text: 'Ou Connecter Avec',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          SizedBox(
            height: Get.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialAppsIcons(
                  text: 'assets/fb.png',
                  onPressed: (){

                   Get.to(()=> CreateEventView());

                  }
              ),

              socialAppsIcons(
                  text: 'assets/google.png',
                  onPressed: (){

                   authController.signInWithGoogle();

                  }

              ),
            ],
          )
        ],
      ),
    );
  }

  Widget SignUpWidget(){
    return SingleChildScrollView(
        child: Column(
          children: [



                 SizedBox(
                 height: Get.height * 0.02,
                ),


            myTextField(
                bool: false,
                icon: 'assets/mail.png',
                text: 'Email',
                validator: (String input){
                  if(input.isEmpty){
                    Get.snackbar('Attention', 'Email est requis.',colorText: Colors.white,backgroundColor: Colors.blue);
                    return '';
                  }

                  if(!input.contains('@')){
                    Get.snackbar('Attention', 'Email est invalide.',colorText: Colors.white,backgroundColor: Colors.blue);
                    return '';
                  }
                },
                controller: emailController
            ),
            SizedBox(
              height: Get.height * 0.02,
            ),
            myTextField(
                bool: true,
                icon: 'assets/lock.png',
                text: 'password',
                validator: (String input){
                  if(input.isEmpty){
                    Get.snackbar('Attention', 'le mot de passe est requis.',colorText: Colors.white,backgroundColor: Colors.blue);
                    return '';
                  }

                  if(input.length <6){
                    Get.snackbar('attention', 'le mot de passe doit etre .',colorText: Colors.white,backgroundColor: Colors.blue);
                    return '';
                  }
                },
                controller: passwordController
            ),
            SizedBox(
              height: Get.height * 0.02,
            ),
            myTextField(
                bool: true,
                icon: 'assets/lock.png',
                text: 'Confirmer le mot de passe',
                validator: (String input){
                  if(input != passwordController.text.trim()){
                    Get.snackbar('Attention', 'le mot de passe n est pas conforme .',colorText: Colors.white,backgroundColor: Colors.blue);
                    return '';
                  }
                },
                controller: confirmPasswordController
            ),
           Obx(()=> authController.isLoading.value? Center(child: CircularProgressIndicator(),) : Container(
             height: 50,
             margin: EdgeInsets.symmetric(
               vertical: Get.height * 0.04,
             ),
             width: Get.width,
             child: elevatedButton(
               text: 'Inscription',
               onpress: () {

                 if(!formKey.currentState!.validate()){
                   return;
                 }

                 authController.signUp(email: emailController.text.trim(),password: passwordController.text.trim());



               },
             ),
           )),
           
            SizedBox(
              height: Get.height * 0.02,
            ),
            Container(
                width: Get.width * 0.8,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                        text:
                        'En vous inscrivant, vous acceptez notre ',
                        style: TextStyle(
                            color: Color(0xff262628),
                            fontSize: 12)),
                    TextSpan(
                        text:
                        'conditions, Politique de données et politique en matière de cookies',
                        style: TextStyle(
                            color: Color(0xff262628),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ]),
                )),
          ],
        )

    );
  }

}