import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../../constants/firebaseConstants.dart';
import '../../models/messageChat.dart';
import '../../models/signUpModel.dart';


class ChatProvider {


  final FirebaseFirestore firebaseFirestore= FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage= FirebaseStorage.instance;
  final currentUserId = FirebaseAuth.instance.currentUser;
  String? myToken = '';
  UserModelOne userModelOne = UserModelOne(uid:'');


  UploadTask? uploadFile(File image, String fileName) {
    Reference? reference = firebaseStorage.ref().child(fileName);
    UploadTask? uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(String content, int type, String groupChatId, String currentUserId, String peerId, String read) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString()) ;

    MessageChat messageChat = MessageChat(
        idFrom: currentUserId,
        idTo: peerId,
        timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        type: type,
        read: read
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    }).then((value) => sendPushNotification(userModelOne,content));
  }
  Future<void> requestPermission() async {
    FirebaseMessaging fMessaging = FirebaseMessaging.instance;

    NotificationSettings settings = await fMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('provision permission granted');
    } else {
      print('Permission declined or user has not accepted permission');
    }
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      print('My token is: $myToken');
    });
  }

  Future<void>sendPushNotification(UserModelOne userModelOne, String content)async
  {
    try{
      final body =  {
        "to": myToken,
        "notification": {
          "title": userModelOne.yourName,
          "body": content
        }
      };
      var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers:
          {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=AAAALLOLOpM:APA91bHGC_C-pZmzlpXnS1c9S2qjDrzCV_AoUKC4jBfAFDxmSG2Rh9EM3qxiLh8X7x-xt2FXgT3U0KbI0qmdOQlrTeeqdMvC8o7BsBk50aAmxrLbos8vkl9aENbUxgSBej9Pvce2foQa'
          },
          body:jsonEncode(body));
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
    catch(e){
      log('\nsendPushNotificationE: $e');
    }

  }
  Future<void> updateReadStatus(MessageChat messageChat, String groupChatId) async {
    try {
      String read = 'Message is read';
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(messageChat.timestamp)
          .update({'read': read});
      print('Message Updated');
    } catch (e) {
      print('Error Updating message read: $e');
    }
  }
  Future <void> deleteMessage(MessageChat messageChat, String groupChatId)async
  {
    try {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(messageChat.content)
          .delete();
    }catch(e)
    {
      log("Error while deleting message: $e");
    }
  }
}



class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}