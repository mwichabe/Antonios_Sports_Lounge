import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/signUpModel.dart';
import '../widgets/fullProfilePage.dart';
class NavigationDrawer_ extends StatefulWidget {
  const NavigationDrawer_({Key? key}) : super(key: key);

  @override
  State<NavigationDrawer_> createState() => _NavigationDrawer_State();
}

class _NavigationDrawer_State extends State<NavigationDrawer_> {
  User? user = FirebaseAuth.instance.currentUser;

 UserModelOne loggedInUser = UserModelOne(uid: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModelOne.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              accountName: const Text('{loggedInUser.yourName}',
                  style: TextStyle(color: Colors.white)),
              accountEmail: const Text('{loggedInUser.email}',
                  style: TextStyle(color: Colors.white)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 70,
                child: ClipOval(
                  child: GestureDetector(
                    onTap: ()
                    {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const FullPhotoPage(url: 'loggedInUser.profilePictureUrl' ??'')));
                    },
                    child: CachedNetworkImage(
                      imageUrl: 'loggedInUser.profilePictureUrl' ?? '',
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Colors.indigo,
                        size: 20,
                      ),
                      fit: BoxFit.cover,
                      width: 140,
                      height: 140,
                    ),
                  ),
                ),
              )),
          const Divider(
            height: 10,
            color: Colors.grey,
          ),
          ListTile(
            leading: const Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pushReplacementNamed(context, 'home'),
          ),
          ListTile(
            leading: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pushReplacementNamed(context, 'profNav'),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text('Friends', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pushReplacementNamed(context, 'friends'),
          ),
          ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Log out', style: TextStyle(color: Colors.white)),
              onTap: () =>showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logging Out'),
                    content:
                    const Text('Are you sure you want to proceed?'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {

                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Sign out from FirebaseAuth
                          await FirebaseAuth.instance.signOut();

                          // Remove email from SharedPreferences
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs
                              .remove('isLoggedIn')
                              .then((value) => Navigator.pushReplacementNamed(context, 'signIn'));

                          // Navigate to the login screen


                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )

            /**/
          ),
          const Divider(
            height: 10,
            color: Colors.grey,
          ),
          ListTile(
              leading: Icon(Icons.delete, color: Colors.red[400]),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.white)),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Deleting Account'),
                    content:
                    const Text('Are you sure you want to proceed?'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {

                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          user?.delete().then((value) =>
                              Fluttertoast.showToast(
                                  msg: 'Account deleted Successfully')
                                  .then((value) =>
                                  Navigator.pushReplacementNamed(
                                      context, 'signIn')));
                          Navigator.of(context).pop();



                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )),
          ListTile(
            leading: const Icon(
              Icons.admin_panel_settings,
              color: Colors.black,
            ),
            title: const Text('Admin', style: TextStyle(color: Colors.black)),
            onTap: () => Navigator.pushReplacementNamed(context, 'adminLogIn'),
          ),
        ],
      ),
    );
  }
}