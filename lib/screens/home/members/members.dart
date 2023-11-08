import 'package:antonios/constants/color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/signUpModel.dart';
import '../../../widgets/fullProfilePage.dart';
class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  UserModelOne loggedInUser = UserModelOne(uid: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModelOne.fromMap(value.data());
      setState(() {});
    });
  }

  final List<dynamic> _searchList = [];
  List<dynamic> _filteredSearchList = [];
  bool _isSearching = false;
  Map<String, String> friendRequestStatus = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColor.themeColor,
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
                  return item['yourName']
                      .toLowerCase()
                      .contains(val.toLowerCase());
                }).toList();
              });
            },
          )
              : const Text('People you may know'),
          centerTitle: true,
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
              ),
              color: Colors.white,
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final usersDocs = snapshot.data!.docs;

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUserId)
                    .collection('friends')
                    .get(),
                builder: (context, friendsSnapshot) {
                  if (friendsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return  const Center(child:  Text('Loading your request...'));
                  } else if (friendsSnapshot.hasError) {
                    return Text(
                        'Error retrieving friends collection: ${friendsSnapshot.error}');
                  } else {
                    final friendsUserIds = friendsSnapshot.data!.docs
                        .map((friendDoc) => friendDoc.id)
                        .toList();

                    // Filter out users who are already friends
                    final filteredUsersDocs = usersDocs.where((userDoc) {
                      final userId = userDoc['uid'];
                      return !friendsUserIds.contains(userId)&&currentUser!.uid != userId && userId !='lf6ZUQeBo6RGZKQ5SPXNrniJmdr1';
                    }).toList();

                    _searchList.clear();
                    _searchList.addAll(filteredUsersDocs);

                    return ListView.builder(
                      itemCount: _isSearching
                          ? _filteredSearchList.length
                          : filteredUsersDocs.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final usersInCollection = _isSearching
                            ? _filteredSearchList[index]
                            : filteredUsersDocs[index];
                        final profilePictureUrl =
                            usersInCollection['profilePictureUrl'] ?? '';
                        final yourName = usersInCollection['yourName'];
                        final resident = usersInCollection['resident'] ?? '';
                        final usersId = usersInCollection['uid'] ?? '';
                        final email = usersInCollection['uid']?? '';
                        bool isFriend = friendsUserIds.contains(usersId);

                        String currentFriendRequestStatus =
                            friendRequestStatus[yourName] ?? '';
                        bool isRequestSent =
                            currentFriendRequestStatus.isNotEmpty;

                        void withdrawFriendRequest(String friendName) {
                          FirebaseFirestore.instance
                              .collection('friend_requests')
                              .where('senderId', isEqualTo: currentUser!.uid)
                              .where('senderName',
                              isEqualTo: loggedInUser.yourName)
                              .where('friendName', isEqualTo: friendName)
                              .get()
                              .then((querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              final friendRequestDocument =
                                  querySnapshot.docs.first;
                              final friendRequestId = friendRequestDocument.id;

                              // Remove the friend request
                              FirebaseFirestore.instance
                                  .collection('friend_requests')
                                  .doc(friendRequestId)
                                  .delete()
                                  .then((value) {
                                setState(() {
                                  friendRequestStatus[friendName] = '';
                                });
                                Fluttertoast.showToast(
                                    msg: 'Friend request withdrawn');
                                print('Friend request withdrawn');
                                // Show a success message or perform any other actions
                              }).catchError((error) {
                                Fluttertoast.showToast(
                                    msg:
                                    'Error withdrawing friend request: $error');
                                // Handle the error and display an error message
                              });
                            }
                          }).catchError((error) {
                            print(
                                'Error retrieving friend request document: $error');
                            // Handle the error and display an error message
                          });
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.blue.shade100,
                          elevation: 0.5,
                          child: InkWell(
                            onTap: () {},
                            child: ListTile(
                                leading: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FullPhotoPage(
                                                url: profilePictureUrl)));
                                  },
                                  child: CircleAvatar(
                                    radius: 30,
                                    child: ClipOval(
                                      child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CachedNetworkImage(
                                            imageUrl: profilePictureUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                            const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          )),
                                    ),
                                  ),
                                ),
                                title: Text(yourName),
                                subtitle: Text(resident),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.themeColor,
                                  ),
                                  onPressed: currentUser!.uid == usersId
                                      ? null
                                      : isRequestSent
                                      ? () {
                                    withdrawFriendRequest(yourName);
                                  }
                                      : () {
                                    if (currentUser != null && currentUser!.uid != usersId) {
                                      final friendEmail =
                                      usersInCollection['email'];

                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .where('email',
                                          isEqualTo: friendEmail)
                                          .get()
                                          .then((querySnapshot) {
                                        if (querySnapshot
                                            .docs.isNotEmpty) {
                                          final friendDocument =
                                              querySnapshot
                                                  .docs.first;
                                          final friendId =
                                              friendDocument.id;

                                          // Retrieve friend's profile picture and name
                                          final friendProfilePictureUrl =
                                              friendDocument[
                                              'profilePictureUrl'] ??
                                                  '';
                                          final friendName =
                                              friendDocument[
                                              'yourName'] ??
                                                  '';

                                          // Send friend request
                                          FirebaseFirestore.instance
                                              .collection(
                                              'friend_requests')
                                              .add({
                                            'senderId':
                                            currentUser!.uid,
                                            'senderName':
                                            loggedInUser.yourName,
                                            'senderEmail':
                                            currentUser!.email,
                                            'senderProfilePictureUrl':
                                            loggedInUser
                                                .profilePictureUrl,
                                            'receiverId': friendId,
                                            'receiverEmail':
                                            friendEmail,
                                            'status': 'pending',
                                            'timestamp':
                                            DateTime.now(),
                                            'friendProfilePictureUrl':
                                            friendProfilePictureUrl,
                                            'friendName': friendName,
                                          }).then((value) {
                                            setState(() {
                                              friendRequestStatus[
                                              friendName] =
                                              'Friend request sent \n '
                                                  'Tap to cancel';
                                            });
                                            Fluttertoast.showToast(
                                                msg:
                                                'Friend request sent successfully');
                                            print(
                                                'Friend request sent successfully');
                                            // Show a success message or perform any other actions
                                          }).catchError((error) {
                                            Fluttertoast.showToast(
                                                msg:
                                                'Error sending friend request: $error');
                                            // Handle the error and display an error message
                                          });
                                        }
                                      }).catchError((error) {
                                        print(
                                            'Error retrieving friend document: $error');
                                        // Handle the error and display an error message
                                      });
                                    }
                                    else {

                                      Fluttertoast.showToast(msg:'Cannot send friend request to your own account');
                                    }
                                  },
                                  child: Text(
                                    isRequestSent
                                        ? currentFriendRequestStatus
                                        : 'Add Friend',
                                    style:
                                    const TextStyle(color: Colors.white60),
                                  ),
                                )),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ));
  }
}
