import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_color.dart';
import 'my_widgets.dart';

Widget CustomAppBar() {
  return Builder(
    builder: (context) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Container(
              width: 116,
              height: 17,
              child: myText(
                text: 'SGE',
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Spacer(),
            Container(
              width: 24,
              height: 22,
              child: InkWell(
                onTap: () {
                  // Action de notification à venir
                },
                child: Image.asset('assets/Frame.png'),
              ),
            ),
            SizedBox(
              width: Get.width * 0.04,
            ),
            InkWell(
              onTap: () {
                // Utilise le contexte de Builder
                print("Menu icon tapped");
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                width: 22,
                height: 20,
                child: Image.asset(
                  'assets/menu.png',
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
