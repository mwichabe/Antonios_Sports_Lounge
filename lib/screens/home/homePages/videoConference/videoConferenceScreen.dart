import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VideoConferenceScreen extends StatelessWidget {
  const VideoConferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
              'Welcome to the Video conferencing \n Here you can for a video chat with your friends!'),
          ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(
                    msg: 'This will be implemented soon, be patient!');
              },
              child: const Text('Click To Proceed')),
        ],
      ),
    );
  }
}
