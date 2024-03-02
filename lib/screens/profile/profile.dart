import 'dart:io';

import 'package:antonios/screens/friends/friends.dart';
import 'package:antonios/screens/home/homePages/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/signUpModel.dart';

//ProfilePage
class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;

  UserModelOne loggedInUser = UserModelOne(uid: '');
  bool isImageSelected = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModelOne.fromMap(value.data());
      setState(() {});
    });
  }

  //pick image
  File? _image;
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        isImageSelected = true;
      });
    }
    print('$_image');
  }

  //controllers
  TextEditingController residentEditingController = TextEditingController();
  TextEditingController yourNameEditingController = TextEditingController();
  TextEditingController favDrinkEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Color buttonColor = const Color.fromRGBO(206, 185, 185, 1);
    Color liColor = const Color.fromRGBO(217, 217, 217, 1);
    Color linearColor = const Color.fromRGBO(237, 188, 173, 0.10);
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Do you want to exit this App?'),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.green),
                    ),
                  )
                ],
              );
            });
        return shouldPop!;
      },
      child: Scaffold(
          //backgroundColor: Colors.indigo,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0.0,
            backgroundColor: liColor,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Home()));
                },
              ),
            ],
          ),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.centerRight,
                      colors: [linearColor, liColor])),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    60,
                    20,
                    40,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 200,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(2, 2, 10, 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Profile',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 64,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: SizedBox(
                                  height: 180,
                                  width: 180,
                                  child: _image != null
                                      ? Image.file(
                                          _image!,
                                          fit: BoxFit.fill,
                                          height: 180,
                                          width: 180,
                                        )
                                      : Image.network(
                                          loggedInUser.profilePictureUrl ??
                                              'https://static.vecteezy.com/system/resources/thumbnails/002/318/271/small/user-profile-icon-free-vector.jpg',
                                          fit: BoxFit.cover,
                                          width: 140,
                                          height: 140,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(Icons.error),
                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                              onPressed: _pickImage,
                              icon: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //username
                              TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Username Update required';
                                  }
                                  return null;
                                },
                                controller: yourNameEditingController,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    hintText: 'Update your name',
                                    prefixIcon: const Icon(
                                      Icons.person_2,
                                      color: Colors.white,
                                    )),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              //phoneNumber
                              TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Phone update required';
                                  }
                                  return null;
                                },
                                controller: phoneEditingController,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    hintText: 'Update your phone number',
                                    prefixIcon: const Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    )),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // residential area
                              TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Residential area update required.';
                                  }
                                  return null;
                                },
                                controller: residentEditingController,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    hintText: 'Update your resident',
                                    prefixIcon: const Icon(
                                      Icons.house_outlined,
                                      color: Colors.white,
                                    )),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              // favourite drink
                              TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Confirm your registration number';
                                  }
                                  return null;
                                },
                                controller: favDrinkEditingController,
                                cursorColor: Colors.white,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    hintText:
                                        'Confrim your registration number',
                                    prefixIcon: const Icon(
                                      Icons.app_registration_rounded,
                                      color: Colors.white,
                                    )),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Friends()));
                              },
                              child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'View your friends',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  isImageSelected) {
                                setState(() {
                                  isLoading = true;
                                });
                                String UniqueFileName =
                                    DateTime.now().millisecond.toString();
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImage =
                                    referenceRoot.child('images');
                                Reference referenceImageToUpload =
                                    referenceDirImage.child(UniqueFileName);
                                try {
                                  await referenceImageToUpload.putFile(_image!);
                                  String imageUrl = await referenceImageToUpload
                                      .getDownloadURL();
                                  loggedInUser.profilePictureUrl = imageUrl;
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user!.uid)
                                      .update({
                                    'yourName': yourNameEditingController.text,
                                    'phoneNumber': phoneEditingController.text,
                                    'favouriteDrink':
                                        favDrinkEditingController.text,
                                    'resident': residentEditingController.text,
                                    'profilePictureUrl': imageUrl,
                                  });
                                  Fluttertoast.showToast(
                                    msg: 'profile photo updated successfully',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.green,
                                    timeInSecForIosWeb: 1,
                                    fontSize: 16,
                                  ).then((value) =>
                                      Navigator.pushReplacementNamed(
                                          context, 'home'));
                                } catch (err) {
                                  print('Firebase Firestore error: $err');
                                  Fluttertoast.showToast(
                                      msg:
                                          'An error occurred while updating your profile\n'
                                          ' if the error persist contact admin');
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg:
                                      'No image selected, please update your profile photo.',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 16,
                                );
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                            ),
                            child: const Text('UPDATE PROFILE'),
                          ),
                          if (isLoading) const CircularProgressIndicator(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          })),
    );
  }
}
