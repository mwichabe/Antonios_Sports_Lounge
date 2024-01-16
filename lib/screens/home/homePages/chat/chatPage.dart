import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:antonios/constants/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../constants/firebaseConstants.dart';
import '../../../../models/messageChat.dart';
import '../../../../models/signUpModel.dart';
import '../../../../providers/auth/authProvider.dart' as local_auth_provider;
import '../../../../providers/chat/chatProvider.dart';
import '../../../../widgets/fullProfilePage.dart';
import '../../../../widgets/loadingView.dart';

class ChatPage3 extends StatefulWidget {
  final ChatPageArguments arguments;

  const ChatPage3({
    super.key,
    required this.arguments,
  });
  @override
  ChatPage3State createState() => ChatPage3State();
}

class ChatPage3State extends State<ChatPage3> {
  late final String currentUserId;
  String? myToken = '';

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = "";

  File? imageFile;
  bool isLoading = false;
  bool isShowEmoji = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
//PROBLEM
  late final ChatProvider chatProvider = context.read<ChatProvider>();
  late final local_auth_provider.AuthProvider authProvider =
      context.read<local_auth_provider.AuthProvider>();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModelOne.fromMap(value.data());
      setState(() {});
    });
  }

  User? user = FirebaseAuth.instance.currentUser;
  UserModelOne loggedInUser = UserModelOne(uid: '');

  //
  Future<void> sendPushNotification(String content) async {
    String? friendToken;
    String? friendName;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .where('userId', isEqualTo: groupChatId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final friendDoc = snapshot.docs.first;
        friendToken = friendDoc['friendToken'];
        friendName = friendDoc['friendName'];
      }
    }).catchError((error) {
      log('Error: $error');
    });

    if (friendToken != null) {
      try {
        final body = {
          "to": friendToken,
          "notification": {
            "title": friendName,
            "body": content,
          },
        };
        var response = await post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAALLOLOpM:APA91bHGC_C-pZmzlpXnS1c9S2qjDrzCV_AoUKC4jBfAFDxmSG2Rh9EM3qxiLh8X7x-xt2FXgT3U0KbI0qmdOQlrTeeqdMvC8o7BsBk50aAmxrLbos8vkl9aENbUxgSBej9Pvce2foQa',
          },
          body: jsonEncode(body),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      } catch (e) {
        print('\nsendPushNotificationE: $e');
      }
    }
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowEmoji = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    }
    String peerId = widget.arguments.friendUserId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupChatId = '$currentUserId-$peerId';
    } else {
      groupChatId = '$peerId-$currentUserId';
    }

    chatProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
      return null;
    });
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  void getEmoji() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowEmoji = !isShowEmoji;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask? uploadTask = chatProvider.uploadFile(imageFile!, fileName);
    try {
      TaskSnapshot? snapshot = await uploadTask;
      imageUrl = await snapshot!.ref.getDownloadURL();

      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image, '');
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type, String read) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(content, type, groupChatId, currentUserId,
          widget.arguments.friendUserId, read);
      if (listScrollController.hasClients) {
        listScrollController
            .animateTo(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut)
            .then((value) => sendPushNotification(content));
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: AppColor.primaryColor);
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      String read = messageChat.read;
      // Check if the message is from the current user or the peer
      bool isCurrentUserMessage = messageChat.idFrom == currentUserId;
      /*void showBottomSheet()
      {
        showModalBottomSheet(
            context: context,
            shape:const  RoundedRectangleBorder
              (
              borderRadius: BorderRadius.only
                (
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              )
            ),
            builder: (_){
              return ListView
                (
                shrinkWrap: true,
                children:
                 [
                   InkWell(
                     onTap: ()
                     {
                       chatProvider.deleteMessage(messageChat, groupChatId).then((value) => Navigator.pop(context));
                     },
                     child: const Padding(
                       padding: EdgeInsets.all(18.0),
                       child: Row(
                         children: [
                           Padding(
                             padding: EdgeInsets.only(right: 20),
                             child: Icon(Icons.delete_forever,color: Colors.red),
                           ),
                           Text('Delete Text',style: TextStyle(color: Colors.black))
                         ],
                       ),
                     ),
                   )
                ],
              );
            }
        );
      }*/

      if (isCurrentUserMessage) {
        // Right (my message)
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            messageChat.type == TypeMessage.text
                // Text
                ? Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    width: 200,
                    decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: Text(
                      messageChat.content,
                      style: const TextStyle(color: AppColor.themeColor),
                    ),
                  )
                : messageChat.type == TypeMessage.image
                    // Image
                    ? Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullPhotoPage(
                                  url: messageChat.content,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.all(0))),
                          child: Material(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              messageChat.content,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: AppColor.primaryColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  width: 200,
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.buttonColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(
                                    'assets/img_not_available.jpeg',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    // Sticker
                    : Container(
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20 : 10,
                            right: 10),
                        child: Image.asset(
                          'assets/gifs/${messageChat.content}.gif',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: read.isNotEmpty,
                  replacement: const Icon(
                    Icons.done_all,
                    color: Colors.grey,
                  ),
                  child: const Icon(
                    Icons.done_all,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        // Left (peer message)
        if (read.isEmpty &&
            !isCurrentUserMessage &&
            messageChat.idFrom == widget.arguments.friendUserId) {
          chatProvider.updateReadStatus(messageChat, groupChatId);
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(
                                          url: widget.arguments
                                              .friendProfilePictureUrl)));
                            },
                            child: Image.network(
                              widget.arguments.friendProfilePictureUrl,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.themeColor,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return const Icon(
                                  Icons.account_circle,
                                  size: 35,
                                  color: AppColor.primaryColor,
                                );
                              },
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(width: 35),
                  messageChat.type == TypeMessage.text
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          width: 200,
                          decoration: BoxDecoration(
                              color: AppColor.themeColor,
                              borderRadius: BorderRadius.circular(8)),
                          margin: const EdgeInsets.only(left: 10),
                          child: Text(
                            messageChat.content,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullPhotoPage(
                                          url: messageChat.content),
                                    ),
                                  );
                                },
                                style: ButtonStyle(
                                    padding:
                                        MaterialStateProperty.all<EdgeInsets>(
                                            const EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: AppColor.primaryColor,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColor.buttonColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, object, stackTrace) =>
                                            Material(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.only(
                                  bottom: isLastMessageRight(index) ? 20 : 10,
                                  right: 10),
                              child: Image.asset(
                                'images/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                ],
              ),

              // Time and Read status
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //time
                  isLastMessageLeft(index)
                      ? Container(
                          margin: const EdgeInsets.only(
                              left: 50, top: 5, bottom: 5),
                          child: Text(
                            DateFormat('dd MMM kk:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(messageChat.timestamp))),
                            style: const TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: 12,
                                fontStyle: FontStyle.italic),
                          ),
                        )
                      : const SizedBox.shrink(),
                  //read status

                  /*Visibility(
                    visible: read.isNotEmpty,
                    child: const Icon(
                      Icons.done_all,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),*/
                ],
              ),
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowEmoji) {
      setState(() {
        isShowEmoji = false;
      });
    } else {
      chatProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: Text(
          widget.arguments.friendName,
          style: const TextStyle(color: AppColor.themeColor),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: [
              Column(
                children: [
                  // List of messages
                  buildListMessage(),

                  // Input content
                  buildInput(),
                ],
              ),

              // Loading
              buildLoading()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? LoadingView() : const SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border:
              Border(top: BorderSide(color: AppColor.primaryColor, width: 0.5)),
          color: Colors.white),
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: getImage,
                color: AppColor.buttonColor,
              ),
            ),
          ), // Edit text
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, TypeMessage.text, '');
              },
              style: const TextStyle(color: AppColor.themeColor, fontSize: 15),
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: AppColor.primaryColor),
              ),
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.multiline,
            ),
          ),

          // Button send message
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onSendMessage(
                    textEditingController.text, TypeMessage.text, ''),
                color: AppColor.buttonColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId, _limit),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return Center(
                        child: Image.asset('assets/noMessages.jpg',
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height / 2.5,
                            width: MediaQuery.of(context).size.height / 2.5));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.themeColor,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: AppColor.themeColor,
              ),
            ),
    );
  }
}

class ChatPageArguments {
  final String friendUserId;
  final String friendProfilePictureUrl;
  final String friendName;

  ChatPageArguments({
    required this.friendUserId,
    required this.friendProfilePictureUrl,
    required this.friendName,
  });
}
