import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event/controller/data_controller.dart';
import 'package:event/event_page/event_page_view.dart';
import 'package:event/views/control/controlDocument.dart';
import 'package:event/views/report/report_until.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/ticket_model.dart';
import '../utils/app_color.dart';
import '../views/profile/add_profile.dart';

List<AustinYogaWork> austin = [
  AustinYogaWork(rangeText: '7-8', title: 'CONCERN'),
  AustinYogaWork(rangeText: '8-9', title: 'VINYASA'),
  AustinYogaWork(rangeText: '9-10', title: 'MEDITATION'),
];

List<String> imageList = [
  'assets/#1.png',
  'assets/#2.png',
  'assets/#3.png',
  'assets/#1.png',
];

Widget EventsFeed() {
  DataController dataController = Get.find<DataController>();

  // Vérifier si l'utilisateur est connecté
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    // Rediriger vers la page de connexion ou afficher un message
    return Center(child: Text("Veuillez vous authentifier pour voir les événements."));
  }

  return Obx(() {
    if (dataController.isEventsLoading.value) {
      return Center(child: CircularProgressIndicator());
    } else if (dataController.allEvents.isEmpty) {
      return Center(child: Text("Aucun événement disponible."));
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, i) {
          return EventItem(dataController.allEvents[i]); // Affiche tous les événements
        },
        itemCount: dataController.allEvents.length,
      );
    }
  });
}

Widget buildCard({
  String? image,
  required String text,
  required Function? func,
  required DocumentSnapshot? eventData,
}) {
  DataController dataController = Get.find<DataController>();

  List joinedUsers = eventData?.get('joined') ?? [];
  List dateInformation = eventData?.get('date').toString().split('-') ?? [];
int comments = 0;

// Vérifier si eventData contient des données et si ces données sont un Map
if (eventData?.data() != null && eventData?.data() is Map<String, dynamic>) {
  Map<String, dynamic> data = eventData?.data() as Map<String, dynamic>;

  // Vérifier si le champ "comments" existe
  if (data.containsKey('comments')) {
    comments = (data['comments'] as List<dynamic>).length;
  }
}



 List userLikes = [];
// Vérifier si eventData contient des données et si ces données sont un Map
if (eventData?.data() != null && eventData?.data() is Map<String, dynamic>) {
  Map<String, dynamic> data = eventData?.data() as Map<String, dynamic>;

  // Vérifier si le champ "likes" existe
  if (data.containsKey('likes')) {
    userLikes = data['likes'] as List<dynamic>;
  }
}




 Map<String, dynamic>? eventDataMap = eventData?.data() as Map<String, dynamic>?;

List eventSavedByUsers = (eventDataMap != null && eventDataMap.containsKey('saves'))
    ? eventDataMap['saves']
    : [];
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(17),
      boxShadow: [
        BoxShadow(
          color: Color(0x393939).withOpacity(0.15),
          spreadRadius: 0.1,
          blurRadius: 2,
          offset: Offset(0, 0), // changes position of shadow
        ),
      ],
    ),
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            func?.call();
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(image ?? ''), fit: BoxFit.fill),
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            height: Get.width * 0.5,
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                width: 41,
                height: 24,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Color(0xffADD8E6))),
                child: Text(
                  dateInformation.length >= 2 ? '${dateInformation[0]}-${dateInformation[1]}' : 'N/A',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
              ),
              InkWell(
                onTap: () {
                  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                  if (eventSavedByUsers.contains(currentUserUid)) {
                    FirebaseFirestore.instance.collection('events').doc(eventData!.id).set({
                      'saves': FieldValue.arrayRemove([currentUserUid])
                    }, SetOptions(merge: true));
                  } else {
                    FirebaseFirestore.instance.collection('events').doc(eventData!.id).set({
                      'saves': FieldValue.arrayUnion([currentUserUid])
                    }, SetOptions(merge: true));
                  }
                },
                child: Container(
                  width: 20,
                  height: 19,
                  child: Image.asset(
                    'assets/boomMark.png',
                    fit: BoxFit.contain,
                    color: eventSavedByUsers.contains(FirebaseAuth.instance.currentUser!.uid) ? Colors.red : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              width: Get.width * 0.6,
              height: 50,
              child: ListView.builder(
                itemBuilder: (ctx, index) {
                  DocumentSnapshot? user = dataController.allUsers.firstWhereOrNull((e) => e.id == joinedUsers[index]);
                  String image = user?.get('image') ?? '';
                  return Container(
                    margin: EdgeInsets.only(left: 10),
                    child: CircleAvatar(
                      minRadius: 13,
                      backgroundImage: NetworkImage(image),
                    ),
                  );
                },
                itemCount: joinedUsers.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        ),
        SizedBox(height: Get.height * 0.03),
        Row(
          children: [
            SizedBox(width: 68),
            InkWell(
              onTap: () {
                String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
                if (userLikes.contains(currentUserUid)) {
                  FirebaseFirestore.instance.collection('events').doc(eventData!.id).set({
                    'likes': FieldValue.arrayRemove([currentUserUid]),
                  }, SetOptions(merge: true));
                } else {
                  FirebaseFirestore.instance.collection('events').doc(eventData!.id).set({
                    'likes': FieldValue.arrayUnion([currentUserUid]),
                  }, SetOptions(merge: true));
                }
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffD24698).withOpacity(0.02),
                    )
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  size: 20,
                  color: userLikes.contains(FirebaseAuth.instance.currentUser!.uid) ? Colors.red : Colors.black,
                ),
              ),
            ),
            SizedBox(width: 3),
            Text(
              '${userLikes.length}',
              style: TextStyle(color: AppColors.black, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 20),
            InkWell(
              onTap: () async {
                String uid = FirebaseAuth.instance.currentUser!.uid;
                DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                if (userDoc.exists) {
                  Get.to(() => EventPageView(
                        showComments: true,
                        eventData: eventData!,
                        user: userDoc,
                      ));
                } else {
                  print('Utilisateur non trouvé');
                }
              },
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(0.5),
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/message.png',
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '$comments',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.black),
                  ),
                ],
              ),
            ),
            SizedBox(width: 17),
            Container(
              padding: EdgeInsets.all(0.5),
              width: 20,
              height: 20,
              child: Image.asset(
                'assets/send.png',
                fit: BoxFit.contain,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 17),
            InkWell(
              onTap: () {
                openReportDialog(Get.context!, eventData!);
              },
              child: Container(
                padding: EdgeInsets.all(0.5),
                width: 20,
                height: 20,
                child: Image.asset(
                  'assets/nolike.png',
                  fit: BoxFit.contain,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(width: 15),
          ],
        ),
      ],
    ),
  );
}

Widget EventItem(DocumentSnapshot event) {
  DataController dataController = Get.find<DataController>();

  DocumentSnapshot? user = dataController.allUsers.firstWhereOrNull((e) => event.get('uid') == e.id);
  if (user == null) {
    print("Utilisateur non trouvé pour l'événement avec l'ID utilisateur: ${event.get('uid')}");
    return SizedBox.shrink(); // Ne rien afficher si l'utilisateur n'est pas trouvé
  }

  String image = user.get('image') ?? '';
  String eventImage = '';

  try {
    List media = event.get('media') as List;
    Map mediaItem = media.firstWhere((element) => element['isImage'] == true) as Map;
    eventImage = mediaItem['url'];
  } catch (e) {
    eventImage = '';
  }

  return Column(
    children: [
      Row(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => EventPageView(showComments: false, eventData: event, user: user));
            },
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue,
              backgroundImage: NetworkImage(image),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '${user.get('first')} ${user.get('last')}',
            style: GoogleFonts.raleway(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      SizedBox(height: Get.height * 0.01),
      buildCard(
        image: eventImage,
        text: event.get('event_name'),
        eventData: event,
        func: () {
          Get.to(() => EventPageView(showComments: false, eventData: event, user: user));
        },
      ),
      SizedBox(height: 15),
    ],
  );
}

Widget EventsIJoined() {
  DataController dataController = Get.find<DataController>();

  DocumentSnapshot? myUser = dataController.allUsers.firstWhereOrNull((e) => e.id == FirebaseAuth.instance.currentUser!.uid);
  if (myUser == null) {
    print("Utilisateur actuel non trouvé.");
    return SizedBox.shrink(); // Ne rien afficher si l'utilisateur n'est pas trouvé
  }

  String userImage = myUser.get('image') ?? '';
  String userName = '${myUser.get('first') ?? ''} ${myUser.get('last') ?? ''}';

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            padding: EdgeInsets.all(10),
            child: Image.asset(
              'assets/doneCircle.png',
              fit: BoxFit.cover,
              color: AppColors.blue,
            ),
          ),
          SizedBox(width: 15),
          Text(
            'Vos évènements!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      SizedBox(height: Get.height * 0.015),
      Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(userImage),
                  radius: 20,
                ),
                SizedBox(width: 10),
                Text(
                  userName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Divider(color: Color(0xff918F8F).withOpacity(0.2)),
            Obx(() {
              if (dataController.isEventsLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (dataController.joinedEvents.isEmpty) {
                return Center(child: Text("Aucun événement rejoint."));
              } else {
                return ListView.builder(
                  itemCount: dataController.joinedEvents.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    String name = dataController.joinedEvents[i].get('event_name');
                    String date = dataController.joinedEvents[i].get('date');
                    date = date.split('-')[0] + '-' + date.split('-')[1];
                    List joinedUsers = dataController.joinedEvents[i].get('joined') ?? [];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 41,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Color(0xffADD8E6)),
                                ),
                                child: Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              SizedBox(width: Get.width * 0.06),
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: Get.width * 0.6,
                          height: 50,
                          child: ListView.builder(
                            itemBuilder: (ctx, index) {
                              DocumentSnapshot? user = dataController.allUsers.firstWhereOrNull((e) => e.id == joinedUsers[index]);
                              String image = user?.get('image') ?? '';
                              return Container(
                                margin: EdgeInsets.only(left: 10),
                                child: CircleAvatar(
                                  minRadius: 13,
                                  backgroundImage: NetworkImage(image),
                                ),
                              );
                            },
                            itemCount: joinedUsers.length,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            }),
          ],
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}
