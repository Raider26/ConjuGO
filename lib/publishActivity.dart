// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PublishArticlePage extends StatefulWidget {
  const PublishArticlePage({Key? key}) : super(key: key);

  @override
  _PublishArticlePageState createState() => _PublishArticlePageState();
}

class _PublishArticlePageState extends State<PublishArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une publication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: null, //Aucune limite de ligne dans le texte de description
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      labelText: "Date"),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  // Check if a date is picked
                  if (pickedDate != null) {
                    // Get the time
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      }
                    );

                    // Check if a time is picked
                    if (pickedTime != null) {
                      // Combine date and time
                      DateTime combinedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      // Format date and time as desired
                      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime);

                      // Update the text field
                      _dateController.text = formattedDateTime;
                    }
                  }
                }
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: 'Lieu'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Nombre de places'),
                keyboardType: TextInputType.number, //Ouvre un clavier numérique uniquement
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], //Ne permet qu'un nombre entier
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  onSubmit();
                },
                child: const Text('Publier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    //Récupère les valeurs des controlleurs du formulaire
    String title = _titleController.text;
    String description = _descriptionController.text;
    DateTime date = DateTime.parse(_dateController.text);
    String place = _placeController.text;
    int number = int.parse(_numberController.text);

    CollectionReference users = FirebaseFirestore.instance.collection('ACTIVITYDATA');

    // Add a new document with a generated ID
    await users.add({
      "name": title,
      "description": description,
      "date": date,
      "place": place,
      "maxNumber": number,
      "numberOfRemainingEntries": number,
      "Participants": [],
    });
    
    //Supprime les valeur des controlleurs
    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _placeController.clear();
    _numberController.clear();

    //affiche un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Publication ajoutée avec succès'),
      duration: Duration(seconds: 5),
    ));
  }
}