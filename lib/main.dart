import 'dart:developer';

import 'package:antonios/constants/color.dart';
import 'package:antonios/providers/auth/authProvider.dart';
import 'package:antonios/providers/chat/chatProvider.dart';
import 'package:antonios/providers/chat/messageNotifier.dart';
import 'package:antonios/screens/splashScreen/splashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage rMessage) async {
  log('Handling a background message ${rMessage.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
      /*options: const FirebaseOptions(
          apiKey: "AIzaSyDcNAoOWqe3Qinv3b_ZYmCiVhSjtyYyrPA",
          authDomain: "antonios-34b68.firebaseapp.com",
          projectId: "antonios-34b68",
          storageBucket: "antonios-34b68.appspot.com",
          messagingSenderId: "572582786630",
          appId: "1:572582786630:web:4556b910ab643a1ef9fc47")*/
  );
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        Provider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            prefs: prefs,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        ChangeNotifierProvider<MessageNotifier>(
          create: (_) => MessageNotifier(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColor.themeColor),
          useMaterial3: true,
        ),
        home: const SplashScreen());
  }
}
