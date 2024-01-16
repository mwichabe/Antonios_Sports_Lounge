import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_video/stream_video.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({super.key});

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final client = StreamVideo(
    'hd8szvscpxvd',
    user: User.regular(userId: 'vasil', role: 'admin', name: 'Willard Hessel'),
    userToken:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidmFzaWwifQ.N44i27-o800njeSlcvH2HGlBfTl8MH4vQl0ddkq5BVI',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Create Call'),
          onPressed: () async {
            try {
              var call = StreamVideo.instance.makeCall(
                type: 'default',
                id: 'demo-call-123',
              );

              await call.getOrCreate();
            } catch (e) {
              debugPrint('Error joining or creating call: $e');
              debugPrint(e.toString());
            }
          },
        ),
      ),
    );
  }
}
