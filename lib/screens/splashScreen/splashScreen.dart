import 'package:antonios/constants/color.dart';
import 'package:antonios/providers/authStateManagement.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _containerSize = 100.0;
  @override
  void initState() {
    super.initState();
    // Start the animation when the widget is first built.
    _startAnimation();
  }
  void _startAnimation()async{
    await Future.delayed(const Duration(seconds: 2)); // Adjust the delay duration
    setState(() {
      _containerSize = 300.0;
    });

    await Future.delayed(const Duration(seconds: 1)); // Adjust the delay duration
    // Navigate to the next screen when the animation is done.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.centerRight,
                  colors: [AppColor.primaryColor, AppColor.secondaryColor])),
          child:  Center(child: AnimatedContainer(
            duration: const Duration(seconds: 1), // Adjust the duration
            width: _containerSize,
            height: _containerSize,
            child: ClipOval(child: Image.asset('assets/appLogo.jpg')), // Replace with your image
          ),));
    }));
  }
}
