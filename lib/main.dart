import 'dart:developer';
import 'package:antonios/constants/color.dart';
import 'package:antonios/firebase_options.dart';
import 'package:antonios/providers/auth/authProvider.dart'
    as local_auth_provider;
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MultiProvider(
      providers: [
        Provider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => local_auth_provider.AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            prefs: prefs,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        ChangeNotifierProvider<MessageNotifier>(
          create: (_) => MessageNotifier(),
        ),
      ],
      child: const MyApp(),
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
