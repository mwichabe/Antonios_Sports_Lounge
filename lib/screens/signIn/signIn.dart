import 'package:antonios/constants/color.dart';
import 'package:antonios/screens/signUp/signUp.dart';
import 'package:flutter/material.dart';

import '../../widgets/waveWidgets.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  //controller
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  //final _auth = FirebaseAuth.instance;
  @override
  void dispose() {
    _emailEditingController.dispose();
    _passwordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          backgroundColor: AppColor.buttonColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  const Text(
                    'LOG IN',
                    style: TextStyle(
                        color: AppColor.primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Stack(
                    children: [
                      Container(
                        height: size.height - 200,
                        color: AppColor.buttonColor,
                      ),
                      WaveWidgets(
                        size: size,
                        yOffset: size.height / 3.0,
                        color: AppColor.themeColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _emailEditingController,
                                cursorColor: Colors.black,
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  prefixIcon: const Icon(
                                    Icons.mail_lock_outlined,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                  filled: true,
                                  enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.white38),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.white60),
                                  focusColor: Colors.white60,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ('Please enter your email');
                                  }
                                  //reg expression
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return ("Please enter a valid email");
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _passwordEditingController,
                                cursorColor: Colors.black,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  prefixIcon: const Icon(
                                    Icons.mail_lock_outlined,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                  filled: true,
                                  enabledBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.white38),
                                  ),
                                  labelStyle:
                                      const TextStyle(color: Colors.white60),
                                  focusColor: Colors.white60,
                                ),
                                validator: (value) {
                                  RegExp regex = RegExp(
                                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#&*~]).{6,}$');
                                  if (value!.isEmpty) {
                                    return ("Password is required");
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return ' Password must be at least 6 characters \n'
                                        ' Include: \n '
                                        'Uppercase. \n'
                                        'Number & symbol.\n'
                                        'eg Antonios@1';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    //signIn(_emailEditingController.text,_passwordEditingController.text,);
                                  },
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(color: AppColor.buttonColor),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignUp()));
                                      },
                                      child: Text('SIGN UP')))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
