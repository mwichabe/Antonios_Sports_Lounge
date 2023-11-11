import 'package:antonios/constants/color.dart';
import 'package:antonios/widgets/fullProfilePage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class FriendRequest extends StatefulWidget {
  const FriendRequest({super.key});

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;
  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    Color linearColor = const Color.fromRGBO(237, 188, 173, 0.68);
    Color liColor = const Color.fromRGBO(217, 217, 217, 1);
    Color purpleLinearColor = const Color(0xFFCEB9B9);
    return Scaffold(
      backgroundColor: liColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.themeColor,
        title: const Text('FRIEND REQUESTS'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('receiverId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final requestDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: requestDocs.length,
              itemBuilder: (context, index) {
                final requestData =
                requestDocs[index].data() as Map<String, dynamic>;
                final senderId = requestData['senderId'];

                // Fetch the sender's user document
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(senderId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final senderSnapshot = snapshot.data;
                    if (senderSnapshot == null || !senderSnapshot.exists) {
                      return const Text('No requests received');
                    }

                    final senderData =
                    senderSnapshot.data() as Map<String, dynamic>;
                    final senderName =
                        senderData['yourName'] as String? ?? 'Unknown';
                    final profilePictureUrl = senderData['profilePictureUrl'];

                    return Column(
                      children: [
                        ListTile(
                          leading: const Text(
                            'Received From: ',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          title: Column(
                            children: [
                              Text(' $senderName'),
                              GestureDetector(
                                onTap: ()
                                {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FullPhotoPage(
                                      url: profilePictureUrl
                                  )));
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
                                          errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Ink(
                                color: Colors.indigo,
                                child: IconButton(
                                  onPressed: () => acceptFriendRequest(
                                      requestDocs[index].reference,
                                      currentUserId,
                                      currentUserEmail!),
                                  icon: const Icon(Icons.check),
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () => declineFriendRequest(
                                    requestDocs[index].reference),
                                icon: const Icon(Icons.close),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 10,
                          color: Colors.grey,
                        )
                      ],
                    );
                  },
                );
              },
            );
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }

  // Function to accept a friend request
  void acceptFriendRequest(DocumentReference requestRef, String currentUserId,
      String currentUserEmail) {
    requestRef.get().then((snapshot) {
      if (snapshot.exists) {
        final requestData = snapshot.data() as Map<String, dynamic>;

        // Get the data of the friend request
        final senderId = requestData['senderId'];
        final senderName = requestData['senderName'];
        final senderPushToken = requestData['senderPushToken'];
        final receiverPushToken = requestData['friendPushToken'];
        final senderProfilePictureUrl = requestData['senderProfilePictureUrl'];
        final senderEmail = requestData['senderEmail'];
        final receiverId = requestData['receiverId'];
        final receiverEmail = requestData['receiverEmail'];
        final friendProfilePictureUrl = requestData['friendProfilePictureUrl'];
        final friendName = requestData['friendName'];
        final status = requestData['status'];

        // Check if the receiver ID is different from the current user's ID
        if (receiverId != senderId && receiverId == currentUserId) {
          // Create a new document in the sender's friend list
          requestRef.update({'status': 'accepted'}).then((_) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUserId)
                .collection('friends')
                .doc(senderId)
                .set({
              'userId': senderId,
              'email': senderEmail,
              'friendProfilePictureUrl': senderProfilePictureUrl,
              'friendName': senderName,
              'friendToken': senderPushToken,
            }).then((_) {
              // Create a new document in the receiver's friend list
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(senderId)
                  .collection('friends')
                  .doc(currentUserId)
                  .set({
                'userId': currentUserId,
                'email': currentUserEmail,
                'friendProfilePictureUrl': friendProfilePictureUrl,
                'friendName': friendName,
                'friendToken': receiverPushToken,
              }).then((_) {
                // Remove the friend request data from the 'friend_requests' collection
                requestRef.delete().then((_) {
                  Fluttertoast.showToast(
                      msg: 'Friend Request accepted. You can now chat.');
                  print('Friend request accepted');
                  // Show a success message or perform any other actions

                  // Refresh the UI to update the list
                  setState(() {});
                }).catchError((error) {
                  print('Error deleting friend request: $error');
                  // Handle the error and display an error message
                });
              }).catchError((error) {
                print(
                    'Error adding friend to receiver\'s friends collection: $error');
                // Handle the error and display an error message
              });
            }).catchError((error) {
              print(
                  'Error adding friend to sender\'s friends collection: $error');
              // Handle the error and display an error message
            });
          });
        } else {
          // The receiver ID does not match the current user's ID or the receiver is not the current user
          Fluttertoast.showToast(
              msg: 'Cannot accept friend request from this user');
          print('Cannot accept friend request from this user');
          // Handle the error and display an error message
        }
      }
    }).catchError((error) {
      print('Error accepting friend request: $error');
      // Handle the error and display an error message
    });
  }

  // Function to decline a friend request
  void declineFriendRequest(DocumentReference requestRef) {
    requestRef.delete().then((value) {
      Fluttertoast.showToast(msg: 'Friend request declined.');
      print('Friend request declined');
      // Show a success message or perform any other actions

      // Refresh the UI to update the list
      setState(() {});
    }).catchError((error) {
      Fluttertoast.showToast(msg: 'Error declining friend request: $error');
      print('Error declining friend request: $error');
      // Handle the error and display an error message
    });
  }
}
