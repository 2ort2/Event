import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:event/controller/data_controller.dart';
import 'package:event/model/event_media_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../utils/app_color.dart';
import '../../widgets/my_widgets.dart';

class CreateEventView extends StatefulWidget {
  CreateEventView({Key? key}) : super(key: key);

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  DateTime? date = DateTime.now();

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  TextEditingController maxEntries = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController frequencyEventController = TextEditingController();
  TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 0, minute: 0);


  // Variables pour stocker les dates de début et de fin
  DateTime? startDate;
  DateTime? endDate;


// Nouvelle variable d'état pour le prix sélectionné
  String? selectedPrice;


// Variables d'état pour les types de tickets
  bool isStandardSelected = false;
  bool isVipSelected = false;


  // Variables pour les prix des tickets
  TextEditingController standardPriceController = TextEditingController();
  TextEditingController vipPriceController = TextEditingController();

  var selectedFrequency = -2;

  void resetControllers() {
    dateController.clear();
    timeController.clear();
    titleController.clear();
    locationController.clear();
    priceController.clear();
    descriptionController.clear();
    tagsController.clear();
    maxEntries.clear();
    endTimeController.clear();
    startTimeController.clear();
    frequencyEventController.clear();
    startTime = TimeOfDay(hour: 0, minute: 0);
    endTime = TimeOfDay(hour: 0, minute: 0);
    setState(() {});
  }

  var isCreatingEvent = false.obs;

   _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      date = DateTime(picked.year, picked.month, picked.day, date!.hour,
          date!.minute, date!.second);
      dateController.text = '${date!.day}-${date!.month}-${date!.year}';
    }
    setState(() {});
  }

  startTimeMethod(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      startTime = picked;
      startTimeController.text =
      '${startTime.hourOfPeriod > 9 ? "" : '0'}${startTime.hour > 12 ? '${startTime.hour - 12}' : startTime.hour}:${startTime.minute > 9 ? startTime.minute : '0${startTime.minute}'} ${startTime.hour > 12 ? 'PM' : 'AM'}';
      // Mise à jour de la date de fin avec l'heure sélectionnée
       startDate = DateTime(
        date!.year,
        date!.month,
        date!.day,
        startTime.hour,
        startTime.minute,
      );
      validateDates(); // Appel de la validation des dates après mise à jour
    }
   // print("start ${startTimeController.text}");
    setState(() {});
  }

   endTimeMethod(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      endTime = picked;
      endTimeController.text =
      '${endTime.hourOfPeriod > 9 ? "" : "0"}${endTime.hour > 9 ? "" : "0"}${endTime.hour > 12 ? '${endTime.hour - 12}' : endTime.hour}:${endTime.minute > 9 ? endTime.minute : '0${endTime.minute}'} ${endTime.hour > 12 ? 'PM' : 'AM'}';
      // Mise à jour de la date de fin avec l'heure sélectionnée
      endDate = DateTime(
        date!.year,
        date!.month,
        date!.day,
        endTime.hour,
        endTime.minute,
      );
      validateDates(); // Appel de la validation des dates après mise à jour
    }

    //print(endTime.hourOfPeriod);
    setState(() {});
  }


     // Méthode pour valider les dates de début et de fin
  void validateDates() {
    if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
      // Affichage d'un message d'erreur si la date de fin est antérieure à la date de début
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La date de fin ne peut pas être antérieure à la date de début.'),
          backgroundColor: Colors.red,
        ),
      );
      endTimeController.clear();
      endDate = null;
    }
  }



  String event_type = 'Concert';
  List<String> list_item = ['Concert', 'Conference' ,'Mariage','formation','fete'];



  // Listes pour le ticket et les prix
  List<String> ticketTypes = ['Standard', 'VIP'];
  Map<String, List<String>> ticketPrices = {
    'Standard': ['10€', '15€'],
    'VIP': ['50€', '100€'],
  };


  String accessModifier = 'Standard';
  List<String> close_list = [
    'Standard',
    'VIP',
  ];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> mediaUrls = [];

  List<EventMediaModel> media = [];

 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeController.text = '${date!.hour}:${date!.minute}:${date!.second}';
    dateController.text = '${date!.day}-${date!.month}-${date!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                iconWithTitle(text: 'Créer un Evènement', func: () {}),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      width: 90,
                      height: 33,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.black.withOpacity(0.6),width: 0.6)
                          )
                      ),
                      child: DropdownButton(
                        isExpanded: true,
                        underline: Container(
                          // decoration: BoxDecoration(
                          //   border: Border.all(
                          //     width: 0,
                          //     color: Colors.white,
                          //   ),
                          // ),
                        ),

                        // borderRadius: BorderRadius.circular(10),
                        icon: Image.asset('assets/arrowDown.png'),
                        elevation: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                        value: event_type,
                        onChanged: (String? newValue) {
                          setState(
                                () {
                              event_type = newValue!;
                            },
                          );
                        },
                        items: list_item
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),

                  ],
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                Container(
                  height: Get.width * 0.6,
                  width: Get.width * 0.9,
                  decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: DottedBorder(
                    color: AppColors.border,
                    strokeWidth: 1.5,
                    dashPattern: [6, 6],
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: Get.height * 0.05,
                          ),
                          Container(
                            width: 76,
                            height: 59,
                            child: Image.asset('assets/uploadIcon.png'),
                          ),
                          myText(
                            text: 'Cliquer et télécharger image/video',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          elevatedButton(
                              onpress: () async {
                                mediaDialog(context);
                              },
                              text: 'Télécharger')
                        ],
                      ),
                    ),
                  ),
                ),
                media.length == 0
                    ? Container()
                    : SizedBox(
                  height: 20,
                ),

                media.length == 0
                    ? Container()
                    : Container(
                  width: Get.width,
                  height: Get.width * 0.3,
                  child: ListView.builder(
                      itemBuilder: (ctx, i) {
                        return
                            media[i].isVideo!
                          //!isImage[i]
                            ? Container(
                          width: Get.width * 0.3,
                          height: Get.width * 0.3,
                          margin: EdgeInsets.only(
                              right: 15, bottom: 10, top: 10),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: MemoryImage(media[i].thumbnail!),
                                fit: BoxFit.fill),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: CircleAvatar(
                                      child: IconButton(
                                        onPressed: () {
                                          media.removeAt(i);
                                          // media.removeAt(i);
                                          // isImage.removeAt(i);
                                          // thumbnail.removeAt(i);
                                          setState(() {});
                                        },
                                        icon: Icon(Icons.close),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.slow_motion_video_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              )
                            ],
                          ),
                        )
                            : Container(
                          width: Get.width * 0.3,
                          height: Get.width * 0.3,
                          margin: EdgeInsets.only(
                              right: 15, bottom: 10, top: 10),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(media[i].image!),
                                fit: BoxFit.fill),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5),
                                child: CircleAvatar(
                                  child: IconButton(
                                    onPressed: () {
                                      media.removeAt(i);
                                      // isImage.removeAt(i);
                                      // thumbnail.removeAt(i);
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.close),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: media.length,
                      scrollDirection: Axis.horizontal),
                ),

                SizedBox(
                  height: 20,
                ),
                myTextField(
                    bool: false,
                    icon: 'assets/4DotIcon.png',
                    text: 'Nom de l\'évènement',
                    controller: titleController,
                    validator: (String input) {
                      if (input.isEmpty) {
                        Get.snackbar('Desolé', "Le nom de l'évènement est requis.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }

                      if (input.length < 3) {
                        Get.snackbar(
                            'Desolé', "le nom  de l\'évènement doit dépasser 3 caractères.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    }),

                SizedBox(
                  height: 20,
                ),
                myTextField(
                    bool: false,
                    icon: 'assets/location.png',
                    text: 'Adresse ou lien',
                    controller: locationController,
                    validator: (String input) {
                      if (input.isEmpty) {
                        Get.snackbar('Désolé', "L\'adresse est réquise.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }

                      if (input.length < 3) {
                        Get.snackbar('Désolé', "Adresse est invalide.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    }),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    iconTitleContainer(
                      isReadOnly: true,
                      path: 'assets/Frame1.png',
                      text: 'Date',
                      controller: dateController,
                      validator: (input) {
                        if (date == null) {
                          Get.snackbar('Désolé', "La date est réquise.",
                              colorText: Colors.white,
                              backgroundColor: Colors.blue);
                          return '';
                        }
                        return null;
                      },
                      onPress: () {
                        _selectDate(context);
                      },
                    ),
                    iconTitleContainer(
                        path: 'assets/#.png',
                        text: 'places',
                        controller: maxEntries,
                        type: TextInputType.number,
                        onPress: () {},
                        validator: (String input) {
                          if (input.isEmpty) {
                            Get.snackbar('Désolé', "le nombre de places est réquis.",
                                colorText: Colors.white,
                                backgroundColor: Colors.blue);
                            return '';
                          }
                          return null;
                        }),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),

                iconTitleContainer(
                    path: 'assets/#.png',
                    text: 'Entrez des tags qui iront avec l’événement.',
                    width: double.infinity,
                    controller: tagsController,
                    type: TextInputType.text,
                    onPress: () {},
                    validator: (String input) {
                      if (input.isEmpty) {
                        Get.snackbar('Désolé', "Ces entrées sont réquises.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    }),

                SizedBox(
                  height: 20,
                ),

                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1, color: AppColors.genderTextColor),
                  ),
                  child: TextFormField(
                    readOnly: true,
                    onTap: () {
                      Get.bottomSheet(StatefulBuilder(builder: (ctx, state) {
                        return Container(
                          width: double.infinity,
                          height: Get.width * 0.6,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceAround,
                                children: [
                                  selectedFrequency == 10
                                      ? Container()
                                      : SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          selectedFrequency = -1;

                                          state(() {});
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: selectedFrequency == -1
                                                ? Colors.blue
                                                : Colors.black.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Une fois",
                                              style: TextStyle(
                                                  color: selectedFrequency != -1
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          selectedFrequency = 0;

                                          state(() {});
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: selectedFrequency == 0
                                                ? Colors.blue
                                                : Colors.black.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Quotidiene",
                                              style: TextStyle(
                                                  color: selectedFrequency != 0
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          state(() {
                                            selectedFrequency = 1;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: selectedFrequency == 1
                                                ? Colors.blue
                                                : Colors.black.withOpacity(0.1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "hebdomadaire",
                                              style: TextStyle(
                                                  color: selectedFrequency != 1
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : SizedBox(
                                    width: 10,
                                  ),

                                ],
                              ),
                              Row(
                               
                                children: [

                                  selectedFrequency == 10
                                      ? Container()
                                      : SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          state(() {
                                            selectedFrequency = 2;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: selectedFrequency == 2
                                                ? Colors.blue
                                                : Colors.black.withOpacity(0.1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Mensuelle",
                                              style: TextStyle(
                                                  color: selectedFrequency != 2
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                      )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: InkWell(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: selectedFrequency == 3
                                                ? Colors.blue
                                                : Colors.black.withOpacity(0.1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Annuelle",
                                              style: TextStyle(
                                                  color: selectedFrequency != 3
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          state(() {
                                            selectedFrequency = 3;
                                          });
                                        },
                                      )),
                                  selectedFrequency == 10
                                      ? Container()
                                      : SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  MaterialButton(
                                    minWidth: Get.width * 0.8,
                                    onPressed: () {
                                      frequencyEventController.text =
                                      selectedFrequency == -1
                                          ? 'Once':
                                      selectedFrequency == 0
                                          ? 'Daily'
                                          : selectedFrequency == 1
                                          ? 'Weekly'
                                          : selectedFrequency == 2
                                          ? 'Monthly'
                                          : 'Yearly';
                                      Get.back();
                                    },
                                    child: Text(
                                      "Sélection",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: Colors.blue,
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      }));
                    },
                    validator: (String? input) {
                      if (input!.isEmpty) {
                        Get.snackbar('Désolé', "La fréquence est requis.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    },
                    controller: frequencyEventController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 3),
                      errorStyle: TextStyle(fontSize: 0),
                      hintStyle: TextStyle(
                        color: AppColors.genderTextColor,
                      ),
                      border: InputBorder.none,
                      hintText: 'La fréquence de l\'évènement',
                      prefixIcon: Image.asset(
                        'assets/repeat.png',
                        cacheHeight: 20,
                      ),
                      // border: OutlineInputBorder(
                      //     borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                ),

               
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    iconTitleContainer(
                        path: 'assets/time.png',
                        text: 'Heure début',
                        controller: startTimeController,
                        isReadOnly: true,
                        validator: (input) {},
                        onPress: () {
                          startTimeMethod(context);
                        }),
                    iconTitleContainer(
                        path: 'assets/time.png',
                        text: 'Heure fin',
                        isReadOnly: true,
                        controller: endTimeController,
                        validator: (input) {},
                        onPress: () {
                          endTimeMethod(context);
                        }),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    myText(
                        text: 'Description/Instruction',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 149,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1, color: AppColors.genderTextColor),
                  ),
                  child: TextFormField(
                    maxLines: 5,
                    controller: descriptionController,
                    validator: (input) {
                      if (input!.isEmpty) {
                        Get.snackbar('Désolé', "Description est réquis.",
                            colorText: Colors.white,
                            backgroundColor: Colors.blue);
                        return '';
                      }
                      return null;
                    },
                    decoration: InputDecoration(border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.only(top: 25, left: 15, right: 15),
                      hintStyle: TextStyle(
                        color: AppColors.genderTextColor,
                      ),
                      hintText:
                      'Rédigez un résumé et tous les détails que votre invité doit connaître sur l’événement...',
                      
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: myText(
                    text: 'Ticket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.005,
                ),
              Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Cases à cocher pour sélectionner les types de tickets
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: isStandardSelected,
          onChanged: (bool? value) {
            setState(() {
              isStandardSelected = value ?? false;
            });
          },
        ),
        Text('Standard'),
        Checkbox(
          value: isVipSelected,
          onChanged: (bool? value) {
            setState(() {
              isVipSelected = value ?? false;
            });
          },
        ),
        Text('VIP'),
      ],
    ),
    SizedBox(
      height: Get.height * 0.01,
    ),
    // Alignement des champs de texte pour les prix
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Affiche le champ de texte pour le prix Standard si sélectionné
        if (isStandardSelected)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 40,
              margin: EdgeInsets.only(right: 10), // Espacement entre les champs
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.genderTextColor),
              ),
              child: TextFormField(
                controller: standardPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Prix Standard',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prix Standard est requis';
                  }
                  return null;
                },
              ),
            ),
          ),
        // Affiche le champ de texte pour le prix VIP si sélectionné
        if (isVipSelected)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: AppColors.genderTextColor),
              ),
              child: TextFormField(
                controller: vipPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Prix VIP',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prix VIP est requis';
                  }
                  return null;
                },
              ),
            ),
          ),
      ],
    ),
  ],
),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                Obx(() => isCreatingEvent.value
                    ? Center(
                  child: CircularProgressIndicator(),
                )
                    : Container(
                  height: 42,
                  width: double.infinity,

                  child: elevatedButton(

                      onpress: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        if (media.isEmpty) {
                          Get.snackbar('Désolé', "Le media est réquis.",
                              colorText: Colors.white,
                              backgroundColor: Colors.blue);

                          return;
                        }

                        if (tagsController.text.isEmpty) {
                          Get.snackbar('Désolé', "Les tags sont réquis.",
                              colorText: Colors.white,
                              backgroundColor: Colors.blue);

                          return;
                        }

                        isCreatingEvent(true);


                        DataController dataController = Get.find();

                        if(media.isNotEmpty){
                          for(int i=0;i<media.length;i++){
                            if(media[i].isVideo!){
                              /// if video then first upload video file and then upload thumbnail and
                              /// store it in the map

                        String thumbnailUrl= await dataController.uploadThumbnailToFirebase(media[i].thumbnail!);

                        String videoUrl = await dataController.uploadImageToFirebase(media[i].video!);


                        mediaUrls.add({
                          'url': videoUrl,
                          'thumbnail': thumbnailUrl,
                          'isImage': false
                        });

                            }else{
                              /// just upload image

                             String imageUrl = await dataController.uploadImageToFirebase(media[i].image!);
                            mediaUrls.add({
                              'url': imageUrl,
                              'isImage': true
                            });
                            }

                          }
                        }

                        List<String> tags =
                        tagsController.text.split(',');

                        Map<String, dynamic> eventData = {
                          'event': event_type,
                          'event_name': titleController.text,
                          'location': locationController.text,
                          'date':
                          '${date!.day}-${date!.month}-${date!.year}',
                          'start_time': startTimeController.text,
                          'end_time': endTimeController.text,
                          'max_entries': int.parse(maxEntries.text),
                          'frequency_of_event':
                          frequencyEventController.text,
                          'ticketType': isStandardSelected && isVipSelected ? 'Standard & VIP' : (isStandardSelected ? 'Standard' : 'VIP'),
                          'standardPrice': isStandardSelected ? standardPriceController.text : null, // Prix Standard
                          'vipPrice': isVipSelected ? vipPriceController.text : null, // Prix VIP
                          'description': descriptionController.text,
                          'who_can_invite': accessModifier,
                          'joined': [
                            FirebaseAuth.instance.currentUser!.uid
                          ],
                          'price': priceController.text,
                          'media': mediaUrls,
                          'uid': FirebaseAuth.instance.currentUser!.uid,
                          'tags': tags,
                          'inviter':[
                            FirebaseAuth.instance.currentUser!.uid
                          ]
                        };

                        await dataController.createEvent(eventData)
                        .then((value) {
                          print("l'évenement est crée avec succès");
                          isCreatingEvent(false);
                          resetControllers();
                        });


                      },
                      text: 'Créer '),
                )),
                SizedBox(
                  height: Get.height * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getImageDialog(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(
      source: source,
    );

    if (image != null) {
      media.add(EventMediaModel(
        image: File(image.path),
        video: null,
        isVideo: false
      ));

    }

    setState(() {});
    Navigator.pop(context);
  }

  getVideoDialog(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    
    final XFile? video = await _picker.pickVideo(
      source: source,
    );

    if (video != null) {


    

      Uint8List? uint8list = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );

      media.add(EventMediaModel(
          thumbnail: uint8list!,
          video: File(video.path),
          isVideo: true
      ));
      
    }

    
    setState(() {});

    Navigator.pop(context);
  }

  void mediaDialog(BuildContext context) {
    showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Selection du type de média"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      imageDialog(context, true);
                    },
                    icon: Icon(Icons.image)),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      imageDialog(context, false);
                    },
                    icon: Icon(Icons.slow_motion_video_outlined)),
              ],
            ),
          );
        },
        context: context);
  }

  void imageDialog(BuildContext context, bool image) {
    showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("La source de média"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {
                      if (image) {
                        getImageDialog(ImageSource.gallery);
                      } else {
                        getVideoDialog(ImageSource.gallery);
                      }
                    },
                    icon: Icon(Icons.image)),
                IconButton(
                    onPressed: () {
                      if (image) {
                        getImageDialog(ImageSource.camera);
                      } else {
                        getVideoDialog(ImageSource.camera);
                      }
                    },
                    icon: Icon(Icons.camera_alt)),
              ],
            ),
          );
        },
        context: context);
  }
}