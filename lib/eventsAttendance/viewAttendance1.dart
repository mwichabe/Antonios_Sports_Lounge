import 'package:antonios/screens/home/homePages/Home.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../widgets/fullProfilePage.dart';

class EventsViewAttendancePage1 extends StatefulWidget {
  const EventsViewAttendancePage1({Key? key}) : super(key: key);

  @override
  State<EventsViewAttendancePage1> createState() => _EventsViewAttendancePage1State();
}

class _EventsViewAttendancePage1State extends State<EventsViewAttendancePage1> {
  final List<dynamic> _searchList = [];
  List<dynamic> _filteredSearchList = [];
  bool _isSearching = false;
  final currentUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[400],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.indigo,
          title: _isSearching
              ? TextField(
            cursorColor: Colors.black,
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
              : const Text('People Attending',style: TextStyle(color: Colors.black),),
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
                      : CupertinoIcons.search_circle,
                  color: Colors.black,
                )),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
          FirebaseFirestore.instance.collection('eventAttendance1').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final attendanceDocs = snapshot.data!.docs;
              _searchList.clear();
              _searchList.addAll(attendanceDocs);
              // Remove attendees with passed dates
              final currentDate = DateTime.now().add(const Duration(days: 1));
              final attendeesToRemove = attendanceDocs
                  .where((attendance) =>
                  attendance['date'].toDate().isBefore(currentDate))
                  .toList();

              attendeesToRemove.forEach((attendance) {
                FirebaseFirestore.instance
                    .collection('eventAttendance1')
                    .doc(attendance.id)
                    .delete();
              });


              final updatedAttendanceDocs = snapshot.data!.docs;

              return ListView.builder(
                itemCount:  _isSearching ? _filteredSearchList.length :
                updatedAttendanceDocs.length,
                itemBuilder: (context, index) {
                  final attendance = _isSearching
                      ? _filteredSearchList[index]
                      :
                  updatedAttendanceDocs[index];
                  final profilePictureUrl = attendance['profilePictureUrl'];
                  final yourName = attendance['yourName'];
                  final date = attendance['date'];
                  final formattedDate =
                  DateFormat.yMMMd().format(date.toDate());

                  return ListTile(
                    title: Text(yourName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>FullPhotoPage(url: profilePictureUrl))),
                          child: CircleAvatar(
                            radius: 30,
                            child: ClipOval(
                              child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child:CachedNetworkImage(
                                    imageUrl: profilePictureUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  )
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Date',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.indigo),
                        ),
                        Divider(
                          color: Colors.grey[900],
                          height: 5,
                        ),
                      ],
                    ),
                  );
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