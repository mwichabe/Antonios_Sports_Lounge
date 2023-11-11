import 'dart:io';
import 'package:antonios/constants/color.dart';
import 'package:antonios/screens/home/homePages/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/signUpModel.dart';

class CompleteSetup extends StatefulWidget {
  const CompleteSetup({Key? key}) : super(key: key);

  @override
  State<CompleteSetup> createState() => _CompleteSetupState();
}

class _CompleteSetupState extends State<CompleteSetup> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;

  UserModelOne loggedInUser = UserModelOne(uid: '');
  bool isImageSelected = false;

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
  TextEditingController hobbiesEditingController = TextEditingController();
  TextEditingController favDrinkEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        height: constraints.maxHeight,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.centerRight,
                colors: [AppColor.primaryColor, AppColor.buttonColor])),
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
                      color: Colors.black,
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
                            'Complete Your Profile',
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
                                        'https://firebasestorage.googleapis.com/v0/b/shereheapp-7a725.appspot.com/o/uploadImage.jpg?alt=media&token=31082b8c-739d-4793-a5fb-51945b4c20db',
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
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                 Row(
                  children: [
                    const Icon(
                      Icons.person_2_outlined,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      '${loggedInUser.yourName}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Text(
                      '${loggedInUser.phoneNumber}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 10,
                ),
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: residentEditingController,
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field required';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              helperText:
                                  "Kanduyi, Kibabii, Bungoma, Kitale, Webuye...",
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              hoverColor: Colors.white,
                              label: const Text(
                                'Resident',
                                style: TextStyle(color: Colors.white),
                              ),
                              prefixIcon: const Icon(
                                Icons.home_outlined,
                                color: Colors.black,
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: hobbiesEditingController,
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field required';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              helperText: "Dancing, Swimming , Partying...",
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              hoverColor: Colors.white,
                              label: const Text(
                                'Hobbies',
                                style: TextStyle(color: Colors.white),
                              ),
                              prefixIcon: const Icon(
                                Icons.headphones,
                                color: Colors.black,
                              )),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          style: const TextStyle(color: Colors.black),
                          controller: favDrinkEditingController,
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Field required';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              //helperText: "Enter your favourite drink",
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10)),
                              hoverColor: Colors.white,
                              label: const Text(
                                'Favourite Drink',
                                style: TextStyle(color: Colors.white),
                              ),
                              prefixIcon: const Icon(
                                Icons.local_drink,
                                color: Colors.black,
                              )),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                      ],
                    )),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
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
                            String imageUrl =
                                await referenceImageToUpload.getDownloadURL();
                            loggedInUser.profilePictureUrl = imageUrl;
                            loggedInUser.resident =
                                residentEditingController.text;
                            loggedInUser.hobbies =
                                hobbiesEditingController.text;
                            loggedInUser.favouriteDrink =
                                favDrinkEditingController.text;
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .update(loggedInUser.toMap());
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()));
                            Fluttertoast.showToast(
                              msg:
                                  'Profile photo and information updated successfully',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.green,
                              timeInSecForIosWeb: 1,
                              fontSize: 16,
                            );
                          } catch (err) {
                            Fluttertoast.showToast(
                                msg:
                                    'No image selected, please update your profile photo.');
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg:
                                'Unable to upload your data Please fill the required fields',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            timeInSecForIosWeb: 1,
                            fontSize: 16,
                          );
                          //Fluttertoast.showToast(msg: 'No image selected, please update your profile photo.');
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.themeColor,
                      ),
                      child: const Text(
                        'SAVE',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }));
  }
}
