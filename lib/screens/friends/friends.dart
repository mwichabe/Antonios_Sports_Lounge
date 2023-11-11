import 'dart:developer';

import 'package:antonios/screens/home/homePages/Home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Friends extends StatefulWidget {
  const Friends({Key? key}) : super(key: key);

  @override
  State<Friends> createState() => _FriendsState();
}

final List<dynamic> _searchList = [];
List<dynamic> _filteredSearchList = [];
bool _isSearching = false;
final currentUserId = FirebaseAuth.instance.currentUser!.uid;
Future<int> getFriendCount() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('friends')
      .get();
  return snapshot.docs.length;
}
class _FriendsState extends State<Friends> {
  Future<void> _refreshUI() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .get();

    setState(() {
      _searchList.clear();
      _searchList.addAll(snapshot.docs);
    });
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async
      {
        final shouldPop= await showDialog<bool>(

            context: context,
            builder: (context)
            {
              return AlertDialog
                (
                title: const Text('Do you want to exit this App?'),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions:
                [
                  TextButton
                    (
                    onPressed: (){Navigator.pop(context,true);},
                    child: const Text('Yes',style: TextStyle(color: Colors.black),),
                  ),
                  TextButton
                    (
                    onPressed: (){Navigator.pop(context,false);},
                    child: const Text('No',style: TextStyle(color: Colors.green),),
                  )
                ],
              );
            }
        );
        return shouldPop!;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[400],
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Friends',
                style: TextStyle(color: Colors.black),
              ),
              FutureBuilder<int>(
                future: getFriendCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final int friendCount = snapshot.data!;
                    return Text(
                      'Total Friends: $friendCount',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[400],
          elevation: 1.0,
          actions:
          [
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
                )),
            IconButton(onPressed:()=>
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home())),
                icon: const Icon(Icons.close,color: Colors.black,)),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('friends')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final friendDocs = snapshot.data!.docs;
              _searchList.clear();
              _searchList.addAll(friendDocs);
              return RefreshIndicator(
                onRefresh: _refreshUI,
                color: Colors.grey,
                strokeWidth: 5,
                displacement: 0,
                edgeOffset: 0,
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                child: ListView.builder(
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

                    return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.grey.shade100,
                          elevation: 0.5,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              radius: 30,
                              child: ClipOval(
                                child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CachedNetworkImage(
                                      imageUrl: friendProfilePictureUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    )),
                              ),
                            ),
                            title: Text(friendName),
                            trailing:
                            ElevatedButton.icon
                              (
                              onPressed: (){
                                deleteFriend(friendUserId);
                              },
                              icon: const Icon(CupertinoIcons.delete_solid,color: Colors.black),
                              label: const Text('Unfriend',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[600],
                                  shape: RoundedRectangleBorder
                                    (
                                      borderRadius: BorderRadius.circular(10)
                                  )
                              ),
                            ),
                          ),
                        )
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
  Future<void> deleteFriend(String friendUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final friendRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendUserId);

    try {
      await friendRef.delete().then((value) => Fluttertoast.showToast(msg: 'Friend is successfully deleted'));
      setState(() {
        _isSearching = false;
      });
    } catch (e) {
      log('Failed to delete friend: $e');
    }
  }
}