import 'package:antonios/Drawer/navigationDrawer.dart';
import 'package:antonios/constants/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/messageChat.dart';
import '../friendRequest/friendRequest.dart';
import '../members/members.dart';
import 'AntoniosHome.dart';
import 'chat/chat.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int friendRequestCount = 0;
  int unreadMessageCount = 0;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String groupChatId = '';
  MessageChat? _message;
  static bool _isLoading= false;
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    // pages
    const AntoniosHome(),
    const Chat(),
    const Members(),
    const FriendRequest()

  ];
  final User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Add a listener to the friend_requests collection
    FirebaseFirestore.instance
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        friendRequestCount = snapshot.docs.length;
      });
    });
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text('Antonios Sports Lounge')),
      ),
      drawer: const NavigationDrawer_(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        selectedItemColor: AppColor.themeColor,
        items:  <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Members',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.handshake_outlined),
                if (friendRequestCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        friendRequestCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Requests',
          ),
        ],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
