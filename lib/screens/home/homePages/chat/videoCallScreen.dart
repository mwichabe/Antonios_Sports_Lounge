import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final String friendName;

  VideoCallScreen({required this.friendName});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AgoraClient client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
          channelName: "Antonios", appId: 'f21d47774b0448adb21f0f897963e219',
      tempToken: '007eJxTYOix3lbW8Ib3Vc2cRhn5txefPZtzuf2DdJiTvNN5/i9zqvsUGFKN04yNzFLNUixSLE0MjE2TjM2SLRNNUxMNko0t0iyMOuuqUxsCGRnSu91YGBkgEMTnYHDMK8nPy8wvZmAAAFKpIk4='),
      enabledPermission: [Permission.camera, Permission.microphone]);
  RtcEngine? _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          widget.friendName,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // End the video call and navigate back
              Navigator.pop(context);
            },
            icon: Icon(Icons.call_end),
          ),
        ],
      ),
      body: Stack(
        children: [
          AgoraVideoViewer(
            client: client,
            layoutType: Layout.floating,
            enableHostControls: true,
          ),
          AgoraVideoButtons(
            client: client,
            addScreenSharing: false,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle mute/unmute
          // Implement logic to mute/unmute the microphone
        },
        child: Icon(Icons.mic), // Toggle microphone icon
      ),
    );
  }
}
