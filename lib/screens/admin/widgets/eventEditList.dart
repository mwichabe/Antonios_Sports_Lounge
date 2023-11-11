import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventEditList extends StatelessWidget {
  const EventEditList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final partClubs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: partClubs.length,
            itemBuilder: (context, index) {
              final eventsData = partClubs[index].data() as Map<String, dynamic>;
              final clubId = partClubs[index].id;
              final eventImageUrl= eventsData['imageUrl']??'';
              final eventName= eventsData['eventName']??'';
              final eventDesc= eventsData['eventDesc']??'';
              final eventVenue= eventsData[''];
              final eventArtist= eventsData[''];
              final eventDate= eventsData[''];


              return ListTile(
                title: Text(eventName),
                subtitle: Text(eventDesc),
                leading: CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CachedNetworkImage(
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
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,color: Colors.blue,),
                      onPressed: () {
                        // Open an edit dialog to modify the field values
                        _showEditDialog(context, clubId, eventsData);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,color: Colors.red,),
                      onPressed: () {
                        // Open an edit dialog to modify the field values
                        _showDeleteConfirmationDialog(context, clubId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
  void _showEditDialog(BuildContext context, String eventId, Map<String, dynamic> eventsData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Events'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: eventsData['eventName']??'',
                onChanged: (value) {
                  eventsData['eventName'] = value;
                },
                decoration: const InputDecoration(
                    label:  Text('Event name')
                ),
              ),
              TextFormField(
                initialValue: eventsData['eventDesc']??'',
                onChanged: (value) {
                  eventsData['eventDesc'] = value;
                },
                decoration: const InputDecoration(
                    label:  Text('Event Description')
                ),
              ),
              TextFormField(
                initialValue: eventsData['Venue']??'',
                onChanged: (value) {
                  eventsData['Venue'] = value;
                },
                decoration: const InputDecoration(
                    label:  Text('Event Venue')
                ),
              ),
              TextFormField(
                initialValue: eventsData['date']??'',
                onChanged: (value) {
                  eventsData['date'] = value;
                },
                decoration: const InputDecoration(
                    label:  Text('Event Date')
                ),
              ),
              TextFormField(
                initialValue: eventsData['mainSpeaker']??'',
                onChanged: (value) {
                  eventsData['mainSpeaker'] = value;
                },
                decoration: const InputDecoration(
                    label:  Text('Main Speaker(s)')
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the document in Firestore with the edited data
                FirebaseFirestore.instance.collection('events').doc(eventId).update(eventsData);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  void _showDeleteConfirmationDialog(BuildContext context, String eventsId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () {
                // Delete the document from Firestore
                FirebaseFirestore.instance.collection('events').doc(eventsId).delete();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}