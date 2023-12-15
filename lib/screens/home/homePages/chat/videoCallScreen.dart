import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:antonios/models/signUpModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class VideoCallScreen extends StatefulWidget {
  final String friendName;
  final String friendUserId;

  VideoCallScreen({required this.friendName, required this.friendUserId});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  UserModelOne loggedInUser = UserModelOne(uid: '');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AgoraClient client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
          channelName: "Antonios",
          appId: 'f21d47774b0448adb21f0f897963e219',
          tempToken:
              '007eJxTYOix3lbW8Ib3Vc2cRhn5txefPZtzuf2DdJiTvNN5/i9zqvsUGFKN04yNzFLNUixSLE0MjE2TjM2SLRNNUxMNko0t0iyMOuuqUxsCGRnSu91YGBkgEMTnYHDMK8nPy8wvZmAAAFKpIk4='),
      enabledPermission: [Permission.camera, Permission.microphone]);
  RtcEngine? _engine;
  void sendVideoCallNotification() async {
    String friendUserId = widget.friendUserId;

    // Construct the notification payload
    var payload = {
      'to': '/topics/$friendUserId',
      'notification': {
        'title': 'Incoming Video Call',
        'body': 'You have an incoming video call from ${widget.friendName}',
      },
      'data': {
        'type': 'video_call',
        'caller_name': loggedInUser.yourName,
      },
    };

    // Send the notification using FCM
    await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'key=AAAAhVCX9kY:APA91bHShBvM08BZqQk7kw4SS9177xYeNMtSR3rVqODQRd3bFiBwCNI85GaL9tK3Avj4y_2VIiG-WHIIHAtH9ddmEqMpQ6xTHou_b-G30zSs1mlDXg4vpncECRMQsPvFknk7jYL-c6X7',
      },
      body: jsonEncode(payload),
    );
  }

  @override
  void initState() {
    super.initState();
    initAgora();
    sendVideoCallNotification();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModelOne.fromMap(value.data());
      setState(() {});
    });
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          widget.friendName,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // End the video call and navigate back
              Navigator.pop(context);
            },
            icon: Icon(Icons.call_end),
          ),
        ],
      ),
      body: Stack(
        children: [
          AgoraVideoViewer(
            client: client,
            layoutType: Layout.floating,
            enableHostControls: true,
            showNumberOfUsers: true,
          ),
          AgoraVideoButtons(
            client: client,
            addScreenSharing: false,
          )
        ],
      ),
    );
  }
}
