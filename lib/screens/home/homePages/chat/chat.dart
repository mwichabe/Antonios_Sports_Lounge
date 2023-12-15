import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/messageChat.dart';
import '../../../../widgets/fullProfilePage.dart';
import 'chatPage.dart';
class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final List<dynamic> _searchList = [];
  List<dynamic> _filteredSearchList = [];
  bool _isSearching = false;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  get authProvider => null;
  String groupChatId = '';
  MessageChat? _message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[400],
        title: _isSearching
            ? TextField(
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search...',
          ),
          autofocus: true,
          style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
          onChanged: (val) {
            setState(() {
              _filteredSearchList = _searchList.where((item) {
                return item['friendName']
                    .toLowerCase()
                    .contains(val.toLowerCase());
              }).toList();
            });
          },
        )
            : const Text(
          'Chat With Your Friends',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              icon: Icon(
                _isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search_rounded,
                color: Colors.black,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.indigo,
              backgroundColor: Colors.black,
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                height: MediaQuery.of(context).size.height/2,
                color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Image.asset('assets/9264885.jpg',fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height/2.5,
                              width: MediaQuery.of(context).size.height/2.5,),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'Oops! You have no one to chat with\n '
                                  'Move to Members tab to find friends'),
                        ),
                      ],
                    ),
                  )),
            );
          } else {
            final friendDocs = snapshot.data!.docs;
            _searchList.clear();
            _searchList.addAll(friendDocs);
            return ListView.builder(
              itemCount:
              _isSearching ? _filteredSearchList.length : friendDocs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final friendDoc = _isSearching
                    ? _filteredSearchList[index]
                    : friendDocs[index];
                final friendProfilePictureUrl =
                friendDoc['friendProfilePictureUrl'];
                final friendName = friendDoc['friendName'];
                final friendUserId = friendDoc['userId'];
                String peerId = friendUserId;
                if (currentUserId.compareTo(peerId) > 0) {
                  groupChatId = '$currentUserId-$peerId';
                } else {
                  groupChatId = '$peerId-$currentUserId';
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.grey.shade100,
                  elevation: 0.5,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage3(
                            arguments: ChatPageArguments(
                              friendUserId: friendUserId,
                              friendProfilePictureUrl: friendProfilePictureUrl,
                              friendName: friendName,
                            ),
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullPhotoPage(
                                      url: friendProfilePictureUrl)));
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade100,
                          child: ClipOval(
                            child: SizedBox(
                                height: 50,
                                width: 50,
                                child: CachedNetworkImage(
                                  imageUrl: friendProfilePictureUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                  const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      title: Text(friendName),
                      subtitle: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .doc(groupChatId)
                            .collection(groupChatId)
                            .orderBy("timestamp", descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Loading...');
                          } else if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            final lastMessageDoc = snapshot.data!.docs.first;
                            final lastMessageType = lastMessageDoc['type'];

                            if (lastMessageType == 0) {
                              final lastMessageContent =
                              lastMessageDoc['content'];

                              return Text(
                                lastMessageContent,
                                maxLines: 1,
                                style: const TextStyle(color: Colors.black54),
                              );
                            } else {
                              return const Align(
                                alignment: Alignment.bottomLeft,
                                child: Icon(CupertinoIcons.photo),
                              );
                            }
                          } else if (snapshot.hasError) {
                            return const Text('No messages yet');
                          } else {
                            return const Text('No messages found');
                          }
                        },
                      ),
                      trailing: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .doc(groupChatId)
                            .collection(groupChatId)
                            .orderBy("timestamp", descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasData) {
                            final documents = snapshot.data!.docs;
                            if (documents.isNotEmpty) {
                              final lastTimeDoc = documents.first;
                              final lastTime = lastTimeDoc['timestamp'];
                              final idFrom = lastTimeDoc['idFrom'];
                              final read = _message?.read;
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;

                              if ((read == null || read.isEmpty) &&
                                  idFrom != currentUser!.uid) {
                                return Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              } else {
                                return Text(
                                  DateFormat('dd MMM kk:mm').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(lastTime))),
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.black54),
                                );
                              }
                            }
                          }

                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
