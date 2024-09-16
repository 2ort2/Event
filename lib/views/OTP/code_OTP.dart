import 'package:flutter/material.dart';
import 'package:event/controller/auth_controller.dart';

class OtpScreen extends StatelessWidget {
  final String email;
  final TextEditingController otpController = TextEditingController();

  OtpScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vérification OTP"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Un code OTP a été envoyé à $email",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildOtpTextField(),
            SizedBox(height: 20),
            _buildVerifyButton(context),
            SizedBox(height: 20),
            _buildResendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpTextField() {
    return TextField(
      controller: otpController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Entrez le code OTP",
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final otp = otpController.text.trim();
        if (otp.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Veuillez entrer le code OTP')),
          );
          return;
        }
        AuthController().verifyOtp(
          email: email,
          enteredOtp: otp,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Utilisez backgroundColor au lieu de primary
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        "Vérifier",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: () {
        // Ajoutez la logique pour renvoyer l'OTP
      },
      child: Text(
        "Renvoyer l'OTP",
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }
}
