import 'package:antonios/screens/admin/adminEvents.dart';
import 'package:antonios/screens/forgotPassword/forgotPass.dart';
import 'package:antonios/screens/home/homePages/Home.dart';
import 'package:antonios/screens/signUp/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/color.dart';
class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  void initState()
  {
    super.initState();

  }
  bool isLoading = false;
  bool _passwordVisible = true;
  bool isCheckedRememberMe = false;
  final _formKey = GlobalKey<FormState>();
  //firebase
  final _auth = FirebaseAuth.instance;
  //form key
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold
      (
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints)
          {
            return Container(
              height: constraints.maxHeight,
              decoration: const BoxDecoration
                (
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end:  Alignment.centerRight,
                      colors: [AppColor.primaryColor, AppColor.buttonColor])
              ),
              child: SingleChildScrollView
                (
                child: Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                  child: Column
                    (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [
                      const Padding(
                        padding: EdgeInsets.only(top:200),
                        child: Center(
                          child: Column(
                            children: [
                              Text('Hey Good to see you again\n',
                                style: TextStyle(color: Colors.black,fontSize: 20),
                                textAlign: TextAlign.center,),
                              Text('Welcome Back To Antonios App!\n',
                                style: TextStyle(color: Colors.white,fontSize: 22,),
                                textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30,),
                      Form(
                          key: _formKey,
                          child: Column
                            (
                            children:
                            [
                              TextFormField
                                (
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                textInputAction: TextInputAction.next,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                maxLines: 1,
                                validator: (value)
                                {
                                  if(value!.isEmpty)
                                  {
                                    return('Email field is required');
                                  }
                                  //regEx for email
                                  if(!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)){return("Please Enter a valid  email");}
                                  return null;
                                },
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  hoverColor: Colors.white,
                                  labelText: 'Email',labelStyle: TextStyle(color: Colors.black),
                                  enabledBorder: UnderlineInputBorder
                                    (
                                      borderSide: BorderSide
                                        (
                                          color: Colors.white
                                      )
                                  ),
                                  focusedBorder:UnderlineInputBorder
                                    (
                                      borderSide: BorderSide
                                        (
                                          color: Colors.white
                                      )
                                  ),
                                  prefixIcon: Align(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Icon(
                                      Icons.email,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20,),
                              TextFormField
                                (
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.text,
                                obscureText: _passwordVisible,
                                controller: _passwordController,
                                textInputAction: TextInputAction.done,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value)
                                {
                                  RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!$@#&*~]).{6,}$');
                                  if(value!.isEmpty)
                                  {
                                    return('Password field cannot be null');
                                  }
                                  //regEx for password field
                                  if(!regex.hasMatch(value)){
                                    return ('Password should: \n'
                                        ' Have at least 6 characters\n '
                                        'Have a symbol \n'
                                        'Have an uppercase \n'
                                        'Have a numeric number \n'
                                        'eg. Sherehe@1');
                                  }
                                  return null;
                                },
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  enabledBorder: const UnderlineInputBorder
                                    (
                                      borderSide: BorderSide
                                        (
                                          color: Colors.white
                                      )
                                  ),
                                  focusedBorder:const UnderlineInputBorder
                                    (
                                      borderSide: BorderSide
                                        (
                                          color: Colors.white
                                      )
                                  ),
                                  labelText: 'Enter Password',labelStyle: const TextStyle(color: Colors.black),
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
                                      _passwordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 25,),
                      GestureDetector
                        (
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Forgot password?', style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,),
                          ],
                        ),
                        onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const ResetPassword()));},
                      ),
                      const SizedBox(height: 30,),
                      SizedBox(
                        height: 40,
                        width: 160,
                        child: ElevatedButton(
                          onPressed: ()
                          {

                            signIn(_emailController.text,_passwordController.text);

                          },
                          style: ElevatedButton.styleFrom
                            (
                              backgroundColor: AppColor.buttonColor,
                              shape: RoundedRectangleBorder
                                (
                                  borderRadius: BorderRadius.circular(10)
                              )
                          ),
                          child: const Text('Login',style: TextStyle(color: Colors.black),),
                        ),
                      ),
                      const SizedBox(height: 40,),
                      const Text('New to Antonios App?',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10,),
                      Stack(
                        alignment: Alignment.center,
                        children:
                        [
                          ElevatedButton(
                            onPressed: ()
                            {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const SignUp()));
                            },
                            style: ElevatedButton.styleFrom
                              (
                                backgroundColor: AppColor.buttonColor,
                                shape: RoundedRectangleBorder
                                  (
                                    borderRadius: BorderRadius.circular(30)
                                )
                            ),
                            child: const Text('Create Account',style: TextStyle(color: Colors.black),),
                          ),
                          if (isLoading)
                            const CircularProgressIndicator(),
                        ],
                      ),
                    ],
                  ),

                ),
              ),
            );
          }

      ),
    );
  }
  void signIn(String email, String password) async {
    if(_emailController.text=='antoniosadmin@gmail.com'&& _passwordController.text=='Avator@2')
    {
      try {
        // Perform sign-in
        var userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save login state using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        setState(() {
          isLoading = false;
        }
        );

        // Navigate to home screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Events()));

        // Show success message
        Fluttertoast.showToast(
            msg: 'Admin Credentials are Successful'
        );
      } catch (e) {
        print(e.toString());

        setState(() {
          isLoading = false;
        });

        // Show error message
        Fluttertoast.showToast(
          msg: 'Invalid admin credentials',
        );
      }
    }
    else if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Perform sign-in
        var userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Save login state using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

        setState(() {
          isLoading = false;
        }
        );

        // Navigate to home screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Home()));

        // Show success message
        Fluttertoast.showToast(
          msg: 'Login Successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          timeInSecForIosWeb: 1,
          fontSize: 16,
        );
      } catch (e) {
        print(e.toString());

        setState(() {
          isLoading = false;
        });

        // Show error message
        String errorMessage = 'An error occurred during sign-in.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'invalid-email':
              errorMessage = 'Invalid email address.';
              break;
            case 'user-not-found':
              errorMessage = 'User not found. Please check your credentials.';
              break;
            case 'wrong-password':
              errorMessage = 'Invalid password. Please check your password and try again.';
              break;
          // Add more cases for other possible error codes
            default:
              errorMessage = 'An error occurred during sign-in. Please try again later.';
          }
        } Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          timeInSecForIosWeb: 1,
          fontSize: 16,
        );
      }
    }
  }

}
