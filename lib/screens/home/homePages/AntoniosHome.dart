import 'package:antonios/eventsAttendance/bookAttendance.dart';
import 'package:antonios/eventsAttendance/bookAttendance1.dart';
import 'package:antonios/eventsAttendance/viewAttendance.dart';
import 'package:antonios/eventsAttendance/viewAttendance1.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class AntoniosHome extends StatefulWidget {
  const AntoniosHome({super.key});

  @override
  State<AntoniosHome> createState() => _AntoniosHomeState();
}

class _AntoniosHomeState extends State<AntoniosHome> {
  final List<dynamic> _searchList = [];
  List<dynamic> _filteredSearchList = [];
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    Color liColor = const Color.fromRGBO(217,217,217,1);
    return Scaffold
      (
        backgroundColor: liColor,
        appBar: AppBar
          (
          leading: IconButton(
              onPressed: ()=> Navigator.pushReplacementNamed(context, 'home'),
              icon: const Icon(CupertinoIcons.home,color: Colors.black,)
          ),
          backgroundColor: Colors.grey[400],
          centerTitle: true,
          title: _isSearching
              ? TextField(
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search event name...',
            ),
            autofocus: true,
            style:
            const TextStyle(letterSpacing: 0.5, color: Colors.black),
            onChanged: (val) {
              setState(() {
                _filteredSearchList = _searchList.where((item) {
                  return item['eventName']
                      .toLowerCase()
                      .contains(val.toLowerCase());
                }).toList();
              });
            },
          )
              : const Text(
            'EVENTS',
            style: TextStyle(color: Colors.black),
          ),
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
              ),
              color: Colors.white,
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Colors.indigo,
                  backgroundColor: Colors.black,
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Text('No Event found.');
              } else {
                final eventDoc = snapshot.data!.docs;
                _searchList.clear();
                _searchList.addAll(eventDoc);
                return Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: ListView.builder(
                      itemCount: _isSearching
                          ? _filteredSearchList.length
                          : eventDoc.length,
                      itemBuilder: (context, index) {
                        final events = _isSearching
                            ? _filteredSearchList[index]
                            : eventDoc[index];
                        final eventImageUrl = events['imageUrl'];
                        final eventName = events['eventName'];
                        final eventDescription =
                        events['eventDesc'];
                        final Date = events['date'];
                        final mainSpeaker =
                        events['mainSpeaker'];
                        final venue =
                        events['Venue'];
                        final eventOrganiserContact =
                        events['eventOrganiser'];

                        return Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)
                                ),
                                color: Colors.white,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection:
                                          Axis.horizontal,
                                          child: Card(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(8.0),
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                        'Event :',
                                                        style:  TextStyle(
                                                            fontSize:
                                                            18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                      const SizedBox(height: 5,),
                                                      Text(
                                                        eventName,
                                                        style: const TextStyle(
                                                            fontSize:
                                                            18,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: screenWidth*0.1,),
                                                const Text(
                                                    'UpComing \n'
                                                        'Part/Events'),
                                                SizedBox(width: screenWidth*0.1,),
                                                const Padding(
                                                  padding:
                                                  EdgeInsets.only(
                                                      left: 10,
                                                      right: 18.0,
                                                      bottom: 12.0,
                                                      top: 6.0),
                                                  child: CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor:
                                                      Colors.black,
                                                      child: Padding(
                                                        padding:
                                                        EdgeInsets
                                                            .all(
                                                            8.0),
                                                        child: Icon(
                                                          Icons
                                                              .calendar_month_outlined,
                                                          color: Colors
                                                              .white,
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Card(
                                          child: CachedNetworkImage(
                                            height: 300,
                                            imageUrl: eventImageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context,
                                                url) =>
                                            const CircularProgressIndicator(
                                              color: Colors.indigo,
                                            ),
                                            errorWidget: (context,
                                                url, error) =>
                                            const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Container(
                                            color: Colors.white,
                                            child:
                                            SingleChildScrollView(
                                              scrollDirection:
                                              Axis.vertical,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        left: 18.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 150,
                                                          width: 250,
                                                          child: Column(
                                                            children: [
                                                              const Text(
                                                                'Event Description:\n ',
                                                                style: TextStyle(fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Text(eventDescription,
                                                                  maxLines: 5,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.justify,),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  CupertinoIcons
                                                      .music_mic,
                                                  color: Colors.red,
                                                ),
                                                const Text(
                                                  'Main Artist(s): ',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                const SizedBox(width: 8,),
                                                Card(
                                                  color: Colors.black,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(4.0),
                                                    child: Text(
                                                      mainSpeaker,
                                                      style: const TextStyle(
                                                          color: Colors
                                                              .white,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const Divider(height: 10,
                                              color: Colors.grey,),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    const Text(
                                                      'Venue: \n',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors
                                                              .black),
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    const Icon(
                                                      Icons
                                                          .location_on,
                                                      color: Colors.red,
                                                    ),
                                                    const SizedBox(
                                                      width: 3,
                                                    ),
                                                    Text(
                                                      venue,
                                                      style: const TextStyle(
                                                        color: Colors
                                                            .black,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(0.0),
                                                      child: SizedBox(
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                              'Date: \n',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            const Icon(
                                                              Icons
                                                                  .date_range,
                                                              color: Colors.red,
                                                            ),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            SizedBox(
                                                              height: 50,
                                                              width: 100,
                                                              child: Text(
                                                                Date,
                                                                maxLines: 2,
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                              height: 10,
                                              color: Colors.grey,
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                  Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          if (index == 0) {
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                               MaterialPageRoute(builder: (context)=>const EventBookAttendance()));
                                                          } else if (index ==
                                                              1) {
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                               MaterialPageRoute(builder: (context)=>const EventBookAttendance1()));
                                                          }
                                                        },
                                                        splashColor:
                                                        Colors.red,
                                                        child: const Card(
                                                          color: Colors.black,
                                                          child: Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(
                                                                8.0),
                                                            child: Text(
                                                                'Click to book attendance',style: TextStyle(color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          if (index == 0) {
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(builder: (context)=>const EventsViewAttendancePage()));
                                                          } else if (index ==
                                                              1) {
                                                            Navigator
                                                                .pushReplacement(
                                                                context,
                                                                MaterialPageRoute(builder: (context)=>const EventsViewAttendancePage1()));
                                                          }
                                                        },
                                                        splashColor:
                                                        Colors.red,
                                                        child: const Card(
                                                          color: Colors.black,
                                                          child: Padding(
                                                            padding:
                                                            EdgeInsets
                                                                .all(
                                                                8.0),
                                                            child: Text(
                                                              'Click to see \n'
                                                                  'who is attending',style: TextStyle(color: Colors.white),),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              height: 50,
                            )
                          ],
                        );
                      }),
                );
              }
            })
    );
  }
}

