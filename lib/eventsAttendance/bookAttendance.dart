import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/home/homePages/Home.dart';
class EventBookAttendance extends StatefulWidget {
  const EventBookAttendance({Key? key}) : super(key: key);

  @override
  State<EventBookAttendance> createState() => _EventBookAttendanceState();
}

class _EventBookAttendanceState extends State<EventBookAttendance> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  Color buttonColor = const Color.fromRGBO(206, 185,185,1);
  final _formKey = GlobalKey<FormState>();
  //
  final TextEditingController _dateEditingController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading=false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light().copyWith(
              primary: Colors.indigo,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateEditingController.text = selectedDate.toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    _dateEditingController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold
        (
        backgroundColor: Colors.grey[400],
        body: SingleChildScrollView(
          child: Column
            (
            children:
            [
              Stack
                (
                children:
                [
                  Container(
                    decoration: const BoxDecoration
                      (
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                    ),
                    child: const Image(
                      image: AssetImage('assets/SplashScreen.jpg'),
                      fit: BoxFit.cover,),
                  ),
                  Positioned(
                    top: 20,
                    right: 10,
                    child: Container(
                      decoration: const BoxDecoration
                        (
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconButton(
                          onPressed: (){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
                            },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0,8.0,5,20),
                child: Row
                  (
                  children:
                  [
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white)),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    const Text('Filter out Attendee Bookings'),
                    const SizedBox(width: 10,),
                    InkWell(
                        splashColor: Colors.grey,
                        onTap: ()
                        {
                          setState(() {
                            _dateEditingController.text = '';

                          });
                        },
                        child: const Icon(Icons.refresh))
                  ],
                ),
              ),
              Form(
                  key: _formKey,
                  child: Column
                    (
                    children:
                    [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField
                          (
                          textInputAction: TextInputAction.done,
                          controller: _dateEditingController,
                          onTap: ()
                          {
                            _selectDate(context);
                          },
                          decoration: const InputDecoration
                            (
                              hintText: ' Choose date',
                              label: Text('Tap to book date ',style: TextStyle(color: Colors.black),),
                              enabledBorder: OutlineInputBorder()
                          ),
                          validator: (value)
                          {
                            if(value!.isEmpty)
                            {
                              return('This field is required');
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom
                            (
                            backgroundColor: buttonColor,
                          ),
                          onPressed: ()
                          {
                            if (_formKey.currentState!.validate()) {
                              String selectedDate = _dateEditingController.text;
                              saveDateToFirestore(selectedDate);
                            }
                          },
                          child: isLoading
                              ? const CircularProgressIndicator() // Show loading indicator
                              : const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
  Future<void> saveDateToFirestore(String date) async {
    try {
      setState(() {
        isLoading = true; // Show loading indicator
      });
      // Get the current user's data from the 'users' collection
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      final profilePictureUrl = userData?['profilePictureUrl'];
      final yourName = userData?['yourName'];

      // Convert the selected date to a Timestamp
      final selectedDate = DateTime.parse(date);
      final timestamp = Timestamp.fromDate(selectedDate);

      // Create a new document in the 'attendance' collection with the combined data
      await _firestore.collection('eventAttendance').add({
        'date': timestamp, // Save the date as a Timestamp
        'email': currentUser.email,
        'profilePictureUrl': profilePictureUrl,
        'yourName': yourName,
      }).then((value) =>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home())));

      Fluttertoast.showToast(msg: 'Attendance Successfully Booked',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        timeInSecForIosWeb: 1,
        fontSize: 16,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error occurred while booking attendance: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 1,
        fontSize: 16,
      );
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}