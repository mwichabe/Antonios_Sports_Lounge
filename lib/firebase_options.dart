// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcNAoOWqe3Qinv3b_ZYmCiVhSjtyYyrPA',
    appId: '1:572582786630:web:4556b910ab643a1ef9fc47',
    messagingSenderId: '572582786630',
    projectId: 'antonios-34b68',
    authDomain: 'antonios-34b68.firebaseapp.com',
    storageBucket: 'antonios-34b68.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbQZibGL2IGPFOD5-k8tk2Vj6-AWn2LUs',
    appId: '1:572582786630:android:577723413aa3d9e7f9fc47',
    messagingSenderId: '572582786630',
    projectId: 'antonios-34b68',
    storageBucket: 'antonios-34b68.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCff6g5fnGtGqF6lQ8agFWXu9Ja2KWOwDc',
    appId: '1:572582786630:ios:cfaedb0d72dd6328f9fc47',
    messagingSenderId: '572582786630',
    projectId: 'antonios-34b68',
    storageBucket: 'antonios-34b68.appspot.com',
    iosBundleId: 'com.example.antonios',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCff6g5fnGtGqF6lQ8agFWXu9Ja2KWOwDc',
    appId: '1:572582786630:ios:2077eaa8a0d78275f9fc47',
    messagingSenderId: '572582786630',
    projectId: 'antonios-34b68',
    storageBucket: 'antonios-34b68.appspot.com',
    iosBundleId: 'com.example.antonios.RunnerTests',
  );
}
