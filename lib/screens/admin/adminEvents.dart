import 'dart:io';

import 'package:antonios/screens/signIn/signIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _mainSpeakerController =
  TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _eventOrganiserController =
  TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadData() async {
    if (_eventNameController.text.isEmpty ||
        _dateController.text.isEmpty||
        _eventDescriptionController.text.isEmpty ||
        _mainSpeakerController.text.isEmpty ||
        _venueController.text.isEmpty||
        _eventOrganiserController.text.isEmpty||
        _imageFile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incomplete Form'),
            content:
            const Text('Please fill in all fields and select an image.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Upload image to Firebase Storage
    firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref().child('event_images');
    firebase_storage.UploadTask uploadTask =
    storageRef.child('${DateTime.now()}.jpg').putFile(_imageFile!);
    firebase_storage.TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    // Save data to Firestore
    await _firestore.collection('events').add({
      'eventName': _eventNameController.text,
      'mainSpeaker': _mainSpeakerController.text,
      'imageUrl': imageUrl,
      'date': _dateController.text,
      'eventDesc': _eventDescriptionController.text,
      'Venue': _venueController.text,
      'eventOrganiser': _eventOrganiserController.text,
    });

    // Reset the form
    _eventNameController.clear();
    _mainSpeakerController.clear();
    _dateController.clear();
    _eventDescriptionController.clear();
    _venueController.clear();
    _eventOrganiserController.clear();
    setState(() {
      _imageFile = null;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Event data has been uploaded successfully.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _mainSpeakerController.dispose();
    _dateController.dispose();
    _eventDescriptionController.dispose();
    _venueController.dispose();
    _eventOrganiserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        title: const Text("Event Page"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, (MaterialPageRoute(builder: (context)=>LogIn())));
          }, icon: const Icon(Icons.close))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                textInputAction: TextInputAction.next,
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                textInputAction: TextInputAction.next,
                controller: _eventDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                textInputAction: TextInputAction.next,
                controller: _mainSpeakerController,
                decoration: const InputDecoration(
                  labelText: 'Main Speaker',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _dateController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Date ',
                ),
              ),
              TextField(
                controller: _venueController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Venue ',
                ),
              ),
              TextField(
                controller: _eventOrganiserController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'event organiser contact ',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo
                ),
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 16),
              _imageFile != null
                  ? Image.file(
                _imageFile!,
                height: 200,
              )
                  : const SizedBox(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadData,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo
                ),
                child: const Text('Upload Data'),
              ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, 'adminHotelPage');
                  },
                  child: const Text('BACK',style: TextStyle(color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),)),
              const SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}