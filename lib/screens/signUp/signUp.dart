import 'dart:developer';

import 'package:antonios/constants/color.dart';
import 'package:antonios/screens/completeSignUp/completeSignUp.dart';
import 'package:antonios/screens/signIn/signIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/signUpModel.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  final _auth = FirebaseAuth.instance;
  //form key
  final _formKey = GlobalKey<FormState>();
  //editing Controllers
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController phoneEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordEditingController =
      TextEditingController();
  //
  bool _passwordVisible = false;
  bool _confirmPassVisible = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.centerRight,
                      colors: [AppColor.primaryColor, AppColor.buttonColor])),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Welcome To Kibu App!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 11.0),
                      child: Text(
                        'Feels Good to see you',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Please create an account',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.text,
                                controller: _nameEditingController,
                                textInputAction: TextInputAction.next,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Required");
                                  }
                                  if (!RegExp("^[A-Za-z]{3,}")
                                      .hasMatch(value)) {
                                    return ("Name cannot be less than 3 characters.");
                                  }
                                  return null;
                                },
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  hoverColor: Colors.white,
                                  labelText: 'Your name',
                                  labelStyle: TextStyle(color: Colors.black),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  prefixIcon: Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.person_2_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailEditingController,
                                textInputAction: TextInputAction.next,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ('Email field is required');
                                  }
                                  //regEx for email
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return ("Please Enter a valid email");
                                  }
                                  return null;
                                },
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  hoverColor: Colors.white,
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.black),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  prefixIcon: Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.email,
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.phone,
                                controller: phoneEditingController,
                                textInputAction: TextInputAction.next,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Your phone number is required");
                                  }
                                  return null;
                                },
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  hoverColor: Colors.white,
                                  labelText: 'Phone no',
                                  labelStyle: TextStyle(color: Colors.black),
                                  prefixIcon: Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.phone_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.text,
                                obscureText: _passwordVisible,
                                controller: _passwordEditingController,
                                textInputAction: TextInputAction.next,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  RegExp regex = RegExp(
                                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!$@#&*~]).{6,}$');
                                  if (value!.isEmpty) {
                                    return ('Password field cannot be null');
                                  }
                                  //regEx for password field
                                  if (!regex.hasMatch(value)) {
                                    return ('Password should: \n'
                                        ' Have at least 6 characters\n '
                                        'Have a symbol \n'
                                        'Have an uppercase \n'
                                        'Have a numeric number \n'
                                        'eg. Kibabii@1');
                                  }
                                  return null;
                                },
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  hoverColor: Colors.white,
                                  labelText: 'Create password',
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  prefixIcon: const Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.key,
                                      color: Colors.white,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                controller: _confirmPasswordEditingController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ('Password field cannot be null');
                                  }
                                  //regEx for password field
                                  if (value !=
                                      _passwordEditingController.text) {
                                    return 'Your password does not match';
                                  }
                                  return null;
                                },
                                obscureText: _confirmPassVisible,
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  hoverColor: Colors.white,
                                  labelText: 'Confirm password',
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  prefixIcon: const Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.key,
                                      color: Colors.white,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _confirmPassVisible =
                                            !_confirmPassVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _confirmPassVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 40,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () {
                          register(_emailEditingController.text,
                              _passwordEditingController.text);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.buttonColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('Already have an Account?',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(
                      height: 10,
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LogIn()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.buttonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text(
                            'Log in',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        if (isLoading) const CircularProgressIndicator(),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('About'),
                              content: const Text(
                                  'Welcome to Kibu App, a social networking and entertainment facilitating App that'
                                  ' connects Kibabii members together in their school events. This platform allows you to discover '
                                  'events in school, connect with attendees, and chat with potential new friends.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2.0, bottom: 20.0),
                        child: Text(
                          'About \n'
                          'Kibu App',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Column(
                                children: [
                                  Text('Terms and Conditions'),
                                  Text(
                                    'By signing up you agree to our terms and conditions and',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                ],
                              ),
                              content: SingleChildScrollView(
                                  child: Container(
                                padding: const EdgeInsets.all(
                                    16.0), // Add padding for spacing
                                child: const SingleChildScrollView(
                                  child: Text(
                                    'The following are the terms and policies of Kibu App:\n\n'
                                    'Personal Information:\n'
                                    'This App collects and stores your personal information when you register. We will use this information (your name, email address, and phone number) to create your account, enhance your experience, and communicate with you about events and promotions. We are committed to protecting your personal data and will not share it with third-party entities without your consent, except where necessary to comply with legal obligations.\n\n'
                                    'User Conduct:\n'
                                    'We expect all users to conduct themselves in a respectful and appropriate manner when using this App. You should not engage in illegal, harmful, or offensive activities towards other users. We reserve the right to terminate your account if we believe that you have violated our user conduct policies.\n\n'
                                    'Content Creation:\n'
                                    'Users are encouraged to create and share appropriate, informative, and entertaining content on our app. We reserve the right to remove any content that is offensive or violates our community guidelines.\n\n'
                                    'We reserve the right to modify our terms and policies at any time. We will notify our users of any changes via email or within the app. Sherehe App is committed to protecting the privacy and security of our users. We comply with the Data Protection Policy Act of Kenya, as well as the laws and regulations of Europe and America.\n\n'
                                    'By using our App, you agree to our terms and conditions.',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              )),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2.0, bottom: 20.0),
                        child: Text(
                          'Terms and Conditions',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 140,
                      width: double.infinity,
                    )
                  ],
                ),
              ));
        }),
      ),
    );
  }

  postDetailsToFirestore() async {
    // calling firestore
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    //calling usermodel
    UserModelOne userModel = UserModelOne(uid: '');
    // sending content
    userModel.email = user!.email;
    userModel.uid = user.uid;
    //userModel.phoneNumber= _phoneNumberController.text as int?;
    userModel.yourName = _nameEditingController.text;
    userModel.phoneNumber = phoneEditingController.text;
    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
    Navigator.pushReplacement((context),
        MaterialPageRoute(builder: (context) => const CompleteSetup()));
    Fluttertoast.showToast(
      msg: 'Account created successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      timeInSecForIosWeb: 1,
      fontSize: 16,
    );
  }

  void register(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await _auth
          .createUserWithEmailAndPassword(
              email: _emailEditingController.text,
              password: _passwordEditingController.text)
          .then((value) => {postDetailsToFirestore()})
          .catchError((e) {
        log(e!.message);
        // Show error message
        String errorMessage = 'An error occurred during sign-up.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'weak-password':
              errorMessage =
                  'The password is too weak. Please use a stronger password.';
              break;
            case 'email-already-in-use':
              errorMessage =
                  'The email address is already in use. Please choose a different email.';
              break;
            // Add more cases for other possible error codes
            default:
              errorMessage =
                  'An error occurred while creating your account. Check your internet connectivity and try again later.';
          }
        }
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          timeInSecForIosWeb: 1,
          fontSize: 16,
        );
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
